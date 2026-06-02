#ifndef SRC_GAMES_DEADSPACE2023_SHARED_H_
#define SRC_GAMES_DEADSPACE2023_SHARED_H_

// Must be 32-bit aligned. Canonical renodx::draw contract (modeled on kingdomcome2/shared.h):
// the shader runs renodx::draw::ToneMapPass -> RenderIntermediatePass -> SwapChainPass, all driven
// by the RENODX_* macros below. Native swapchain is scRGB fp16, so SWAP_CHAIN_OUTPUT_PRESET = SCRGB.
struct ShaderInjectData {
  float tone_map_mode;                  // 0 = SDR (RenoDRT NeutralSDR look), 1 = Vanilla, 2 = Vanilla+ (RenoDRT HDR)
  float peak_white_nits;
  float diffuse_white_nits;
  float graphics_white_nits;
  float tone_map_exposure;
  float tone_map_highlights;
  float tone_map_shadows;
  float tone_map_contrast;
  float tone_map_saturation;
  float tone_map_highlight_saturation;
  float tone_map_blowout;
  float tone_map_flare;
  float tone_map_hue_shift;
  float gamma_correction;               // 0 = None, 1 = 2.2, 2 = BT.1886 (SDR EOTF emulation)
  float fxFilmGrainType;                // 0 = Vanilla (game grain), 1 = Monochrome, 2 = Colored
  float fxFilmGrain;                    // perceptual grain strength (0 = off)
  float customRandom;                   // per-frame random seed for perceptual grain
  float fxBloom;                        // bloom scale (1.0 = vanilla, 0 = off) - pass 0x8744747A
  float fxVignette;                     // vignette strength (1.0 = vanilla, 0 = off) - pass 0xBA22203B
};

#ifndef __cplusplus

#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
cbuffer shader_injection : register(b13, space50) {
#elif (__SHADER_TARGET_MAJOR < 5) || ((__SHADER_TARGET_MAJOR == 5) && (__SHADER_TARGET_MINOR < 1))
cbuffer shader_injection : register(b13) {
#endif
  ShaderInjectData shader_injection : packoffset(c0);
}

#define TONE_MAP_MODE_SDR 0.f
#define TONE_MAP_MODE_VANILLA 1.f
#define TONE_MAP_MODE_VANILLA_PLUS 2.f

#define FILM_GRAIN_VANILLA 0.f
#define FILM_GRAIN_MONOCHROME 1.f
#define FILM_GRAIN_COLORED 2.f

#define RENODX_PEAK_WHITE_NITS               shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS            shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS           shader_injection.graphics_white_nits
#define RENODX_TONE_MAP_TYPE                 renodx::draw::TONE_MAP_TYPE_RENO_DRT
#define RENODX_TONE_MAP_EXPOSURE             shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_HIGHLIGHTS           shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS              shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST             shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION           shader_injection.tone_map_saturation
#define RENODX_TONE_MAP_HIGHLIGHT_SATURATION shader_injection.tone_map_highlight_saturation
#define RENODX_TONE_MAP_BLOWOUT              shader_injection.tone_map_blowout
#define RENODX_TONE_MAP_FLARE                shader_injection.tone_map_flare
#define RENODX_TONE_MAP_HUE_SHIFT            shader_injection.tone_map_hue_shift
// EOTF emulation is applied by hand in ToneMapDeadSpace (ApplyEotfEmulation). Keep the library's
// own gamma correction OFF, otherwise RenderIntermediatePass would re-apply it (double gamma:
// mode 1 -> 2.2 twice; mode 2 -> our luminance-2.2 + a per-channel 2.4 on top). NOT
// shader_injection.gamma_correction.
#define RENODX_GAMMA_CORRECTION              renodx::draw::GAMMA_CORRECTION_NONE
#define RENODX_SWAP_CHAIN_OUTPUT_PRESET      renodx::draw::SWAP_CHAIN_OUTPUT_PRESET_SCRGB
#define RENODX_INTERMEDIATE_ENCODING         renodx::draw::GAMMA_CORRECTION_NONE
// Only Vanilla+ pins highlights to Peak; SwapChainPass clamps the max channel to swap_chain_clamp_nits.
// Clamp at Peak ONLY in Vanilla+. In Vanilla (untouched/uncapped native) AND SDR (already range-bound
// by NeutralSDR; Peak slider is disabled there and could hold a stale/low value), raise the clamp far
// out of range so the Peak slider can't crush them.
#define RENODX_SWAP_CHAIN_CLAMP_NITS (shader_injection.tone_map_mode == TONE_MAP_MODE_VANILLA_PLUS ? shader_injection.peak_white_nits : 100000.f)

#include "../../shaders/renodx.hlsl"

// SDR EOTF emulation, hue-preserving (gamma on luminance; chrominance from the per-channel result
// via ICtCp, so blacks deepen without an SDR hue shift). Mirrors MEA / GoW Ragnarok. Gamma 2.2.
float3 GammaCorrectHuePreserving(float3 color) {
  float3 ch = renodx::color::correct::GammaSafe(color);
  const float y_in = renodx::color::y::from::BT709(color);
  const float y_out = max(0.f, renodx::color::correct::Gamma(y_in));
  const float3 lum = color * (y_in > 0.f ? (y_out / y_in) : 0.f);
  return renodx::color::correct::ChrominanceICtCp(lum, ch);
}

// SDR EOTF emulation selector: 0 = Off, 1 = 2.2 per-channel, 2 = 2.2 luminance (hue-preserving).
float3 ApplyEotfEmulation(float3 color) {
  if (shader_injection.gamma_correction == 1.f) {
    return renodx::color::correct::GammaSafe(color, false, 2.2f);
  }
  if (shader_injection.gamma_correction == 2.f) {
    return GammaCorrectHuePreserving(color);
  }
  return color;
}

// Grade-preserving HDR finalize for the fused node 0x2F62371D.
// `graded` = the game's authored analytic grade (linear, 0.18 = mid-gray, 1.0 = diffuse-white ref;
// vanilla wrote o0 = graded*1.25, and 1.25*80 = 100 nits). The authored grade has NO tone curve, so
// we PRESERVE it: optional user grade, then a luminance roll-off that leaves mids/shadows at slope 1
// (untouched) and only rolls highlights to the user peak (kills the vanilla 4000-nit clip). Output is
// linear; RenderIntermediatePass + SwapChainPass apply nits scaling (x diffuse_white_nits / 80) + scRGB.
float3 ToneMapDeadSpace(float3 graded) {
  graded = max(0.f, graded);
  const float mode = shader_injection.tone_map_mode;

  if (mode == TONE_MAP_MODE_VANILLA) {
    // Untouched native passthrough: cancel the pipeline's diffuse-nits scaling so the result is
    // exactly the vanilla graded*1.25 (== graded*100/80 scRGB, 100-nit diffuse), uncapped.
    return graded * (100.f / max(shader_injection.diffuse_white_nits, 1.f));
  }
  if (mode == TONE_MAP_MODE_SDR) {
    // Canonical SDR look: RenoDRT NeutralSDR (tone map to 100 nits, highlights rolled into SDR range
    // with desaturation). Same as atlasfallen's "RenoDRT NeutralSDR" option.
    return renodx::tonemap::renodrt::NeutralSDR(graded);
  }

  // Vanilla+ : optional user color grade (neutral sliders = no-op), preserving the authored grade.
  renodx::color::grade::Config cg = renodx::color::grade::config::Create(
      shader_injection.tone_map_exposure,
      shader_injection.tone_map_highlights,
      shader_injection.tone_map_shadows,
      shader_injection.tone_map_contrast,
      shader_injection.tone_map_flare,
      shader_injection.tone_map_saturation,
      shader_injection.tone_map_blowout,  // dechroma
      0.f,                                 // hue_correction_strength
      float3(0.f, 0.f, 0.f),
      renodx::color::grade::config::hue_correction_type::INPUT,
      -1.f * (shader_injection.tone_map_highlight_saturation - 1.f));  // blowout (highlight saturation)
  float3 color = renodx::color::grade::config::ApplyUserColorGrading(graded, cg);

  // Optional SDR EOTF emulation (default Off; this title has no sRGB/2.2 mismatch in HDR).
  color = ApplyEotfEmulation(color);

  // Highlight roll-off pinned to Peak (relative to diffuse white). Slope 1 below the knee so
  // mids/shadows stay exactly as authored; only highlights compress to [0, peak). Luminance-preserving
  // base (keeps highlight color, no hue-shift); Hue Shift blends toward the per-channel SDR-display hue.
  const float paper_white = max(shader_injection.diffuse_white_nits, 1.f);
  const float peak = max(shader_injection.peak_white_nits / paper_white, 1.f + 1e-3f);
  // Knee at diffuse white (1.0): shadows/mids (<= 1.0) stay slope-1 (authored grade preserved), only
  // highlights (> 1.0) roll to peak. peak is always > 1 here, so 0.999*peak >= 1.0 -> knee = 1.0 and
  // is always < peak (valid shoulder). (The old min(1, peak*0.5) dropped the knee into mids when
  // peak < 2x diffuse, darkening midtones.)
  const float rolloff_start = min(1.f, 0.999f * peak);
  const float3 pre_rolloff = color;
  const float y = renodx::color::y::from::BT709(color);
  const float y_new = renodx::tonemap::ExponentialRollOff(y, rolloff_start, peak);
  color = renodx::color::correct::Luminance(color, y, y_new);
  if (shader_injection.tone_map_hue_shift > 0.f) {
    const float3 per_channel = renodx::tonemap::ExponentialRollOff(pre_rolloff, rolloff_start, peak);
    color = renodx::color::correct::Hue(color, per_channel, shader_injection.tone_map_hue_shift);
  }
  return color;
}

// Perceptual film grain (Monochrome / Colored), applied in paper-white-relative units (1.0 = diffuse)
// on the tonemapped scene. Vanilla type keeps the game's own grain (no-op here). Mirrors MEA
// present_core.hlsli. `customRandom` is reseeded per frame on the host (OnPresent).
float3 ApplyFilmGrainDeadSpace(float3 color, float2 texcoord) {
  if (shader_injection.fxFilmGrain <= 0.f) return color;
  const float strength = shader_injection.fxFilmGrain * 0.03f;
  if (shader_injection.fxFilmGrainType == FILM_GRAIN_MONOCHROME) {
    return renodx::effects::ApplyFilmGrain(color, texcoord, shader_injection.customRandom, strength, 1.f);
  }
  if (shader_injection.fxFilmGrainType == FILM_GRAIN_COLORED) {
    const float r = shader_injection.customRandom;
    const float3 seed = float3(r, frac(r * 1.6180339887f + 0.5f), frac(r * 3.1415926535f + 0.25f));
    return renodx::effects::ApplyFilmGrainColored(color, texcoord, seed, strength, 1.f);
  }
  return color;
}

#endif

#endif  // SRC_GAMES_DEADSPACE2023_SHARED_H_
