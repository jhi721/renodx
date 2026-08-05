#ifndef SRC_GAMES_HORIZONZDR_FWCE_COMMON_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_COMMON_HLSLI_

#include "./shared.h"
#include "./psycho_test24.hlsli"

// Color pipeline shared by every replaced pass of both games: the invertible max-channel LUT
// bridge and per-channel display map the scene compose runs, the HDR10 encode they all end on,
// and the native expansion the FMV decode keeps.
//
// Luma is Rec.709-weighted throughout, not the Decima 0.3086/0.6094/0.0820 set.

float3 ApplyRenoDXGrade(float3 color) {
  renodx::color::grade::Config cg = renodx::color::grade::config::Create();
  cg.exposure = injectedData.color_grade_exposure;
  cg.highlights = injectedData.color_grade_highlights;
  cg.shadows = injectedData.color_grade_shadows;
  cg.contrast = injectedData.color_grade_contrast;
  cg.flare = injectedData.color_grade_flare;
  cg.saturation = injectedData.color_grade_saturation;
  cg.dechroma = injectedData.color_grade_dechroma;
  cg.blowout = -1.f * (injectedData.color_grade_highlight_saturation - 1.f);
  cg.hue_correction_strength = 0.f;  // No hue correction; Create() would default this to 1.

  return renodx::color::grade::config::ApplyUserColorGrading(color, cg);
}

// The exponent behind each Gamma Correction setting. Read by both the EOTF emulation and
// InternalPeakRatio, so a new mode needs an entry here and nowhere else.
float GammaCorrectionExponent() {
  if (injectedData.gamma_correction == HORIZON_GAMMA_CORRECTION_2_2) return 2.2f;
  if (injectedData.gamma_correction == HORIZON_GAMMA_CORRECTION_BT1886) return 2.4f;
  return 0.f;  // Off
}

// Emulates the per-channel display EOTF used by the game's own encode.
float3 ApplyEotfEmulation(float3 color) {
  const float gamma = GammaCorrectionExponent();
  if (gamma == 0.f) return color;

  return renodx::color::correct::GammaSafe(color, false, gamma);
}

// Display headroom over Game Brightness, and the output ceiling.
float PeakRatio() {
  return injectedData.peak_white_nits / max(injectedData.diffuse_white_nits, 1.f);
}

// PeakRatio inverted through the gamma emulation. The native FMV expansion and PsychoV cap on this
// one rather than on PeakRatio, so that running the forward gamma on their output lands highlights
// back exactly on PeakRatio instead of past it.
float InternalPeakRatio() {
  const float gamma = GammaCorrectionExponent();
  if (gamma == 0.f) return PeakRatio();
  return renodx::color::correct::GammaSafe(PeakRatio(), true, gamma);
}

// The shoulder the game uses for its own highlight expansion, reused as a display map: 1:1 below
// the knee, rolling above it. Reaches the peak at cap * cap / knee - cap + knee and is clipped
// past that, the way the vanilla expansion clamps to its own cap.
//
// The knee is held at 0.75 * cap above cap = 24, where the native fraction would otherwise reach
// the cap itself: that leaves the roll-off with no room and puts the zero of (cap - knee) + color
// inside the input range, which resolves to a NaN. Peak / Game Brightness reaches 83 on the
// sliders, so this is reachable, not theoretical.
float3 KneeDisplayMap(float3 color, float cap) {
  const float knee = min(cap * cap * 0.03125f, cap * 0.75f);
  const float3 rolled = (knee + cap) - ((cap * cap) / ((cap - knee) + color));
  return min(lerp(rolled, color, step(color, knee.xxx)), cap.xxx);
}

// The space the game runs its own per-channel tone curve in - the flag&2 block wraps its
// compressor in this pair and samples the LUT only after the inverse, so the space exists for the
// curve alone. Rows sum to 1 and the pair is luminance-preserving against BT.709; the primaries
// sit slightly outside it at R (0.655, 0.325), G (0.294, 0.619), B (0.145, 0.049). Identical in
// both games and in all six compose passes.
static const float3x3 HORIZON_TONE_CURVE_SPACE_FROM_BT709 = float3x3(
    0.9455959796905518f, 0.045505501329898834f, 0.008898990228772163f,
    0.014694600366055965f, 0.967956006526947f, 0.017349300906062126f,
    0.005567430052906275f, 0.020142799243330956f, 0.9742900133132935f);

// Not derived with renodx::math::Invert3x3, deliberately. The game ships both matrices as
// independently rounded 7-digit constants
static const float3x3 HORIZON_BT709_FROM_TONE_CURVE_SPACE = float3x3(
    1.058359980583191f, -0.049572598189115524f, -0.008784100413322449f,
    -0.015964500606060028f, 1.0342400074005127f, -0.01827090047299862f,
    -0.00571777019649744f, -0.021098900586366653f, 1.0268199443817139f);

// Must come after PeakRatio: SelectResolverSharpening uses it for the RCAS normalization.
#include "./resolver_sharpening.hlsli"

// The add-on's only display map and HDR10 encode. Every replaced pass ends here: scene
// compose, the menu/FMV/loading encoder, and - through that encoder - the FMV decode.
//
// Input is scene-relative linear BT.709 where 1.0 is Game Brightness, already graded and
// EOTF-emulated. The scene is mapped per channel in the space the game's own tone curve used;
// menus and FMV arrive display-mapped already and only need the peak clamp.
// Never reads the game's Constant_176.x gamma or .y paper-white scale.
float3 FinalizeOutput(float3 color, bool apply_display_map = false) {
  color = max(0.f, color);
  const float3 source_bt709 = color;

  if (apply_display_map) {
    float3 curve_space = mul(HORIZON_TONE_CURVE_SPACE_FROM_BT709, color);
    curve_space = KneeDisplayMap(curve_space, PeakRatio());

    color = max(0.f, mul(HORIZON_BT709_FROM_TONE_CURVE_SPACE, curve_space));
  }

  color = renodx::color::bt2020::from::BT709(color);

  if (apply_display_map
      && (injectedData.tone_map_hue_shift != 1.f || injectedData.tone_map_blowout != 1.f)) {
    const float3 mb_source = renodx::color::macleod_boynton::from::BT709(source_bt709);
    const float3 mb_mapped = renodx::color::macleod_boynton::from::BT2020(color);
    const float2 white = renodx::color::macleod_boynton::from::D65XY();

    const float2 dir_source = mb_source.xy - white;
    const float2 dir_mapped = mb_mapped.xy - white;
    const float len_source = length(dir_source);
    const float len_mapped = length(dir_mapped);

    // Neutral in either frame: no direction to steer and no purity to restore.
    if (len_source > 1e-6f && len_mapped > 1e-6f) {
      // Hue Shift only turns the vector - both terms carry the mapped purity.
      const float2 dir = lerp(
          dir_source * (len_mapped / len_source), dir_mapped, injectedData.tone_map_hue_shift);
      const float len_dir = length(dir);
      // Blowout picks the purity: 1 keeps what the map produced, 0 puts the source's back.
      const float len_final = lerp(len_source, len_mapped, injectedData.tone_map_blowout);

      if (len_dir > 1e-6f) {
        // Purity restored at the mapped luminance can leave a channel negative; the ceiling is
        // held by the clamp below.
        color = max(0.f, renodx::color::bt2020::from::MacLeodBoynton(
                             white + dir * (len_final / len_dir), mb_mapped.z));
      }
    }
  }

  // The mapped path clamped per channel in the curve space, and its inverse lifts the dominant
  // channel back up, so the ceiling has to be held again in the output primaries.
  color = min(color, PeakRatio());

  // scaling carries Game Brightness: Encode multiplies by scaling/10000 internally.
  return renodx::color::pq::EncodeSafe(color, injectedData.diffuse_white_nits);
}

float3 ApplyRenoDXStandardOutput(float3 color, bool apply_display_map = false) {
  color = ApplyRenoDXGrade(color);
  color = ApplyEotfEmulation(color);
  return FinalizeOutput(color, apply_display_map);
}

// PsychoV replaces both the user grade and the display map: test24 applies exposure, highlights,
// shadows, contrast and purity itself, then compresses to peak in cone space. Peak is the internal
// one because the gamma emulation is inverted into it - running the forward gamma on the output is
// what lands highlights back on peak_ratio.
float3 ApplyPsychoVOutput(float3 color) {
  color = renodx_custom::tonemap::psychov::psychotm_test24(
      color, InternalPeakRatio(),
      injectedData.color_grade_exposure,
      injectedData.color_grade_highlights,
      injectedData.color_grade_shadows,
      injectedData.color_grade_contrast,
      injectedData.color_grade_saturation,  // purity_scale; test24 divides it by contrast
      1.f, 100.f, 1.f,                      // bleaching / clip / hue_restore - unread
      1.f,                                  // adaptation_contrast
      0,                                    // white_curve_mode - unread
      1.f,                                  // cone_response_exponent
      0.18f.xxx, 0.18f.xxx,                 // adaptive and background state at mid grey
      1.f,                                  // gamut_compression, always full
      1,                                    // gamut bound = BT.2020, matches the output
      1.f,                                  // adaptive_normalization - unread
      0.f,                                  // compression = PSYCHO24_AUTO_COMPRESSION_SENTINEL
      1.f,                                  // highlight_saturation - unread
      0.f);                                 // gamut_hue_restore off

  return FinalizeOutput(ApplyEotfEmulation(color), false);
}

// Samples the game's gamma-2 LUT. Input and output are both gamma 2, hence the closing square.
float3 SampleHzdrLut(Texture3D<float3> lut, SamplerState samp,
                     float3 gamma2_color, float lut_scale, float lut_bias) {
  float3 lutted;
  if (injectedData.custom_lut_tetrahedral != 0.f) {
    lutted = renodx::lut::SampleTetrahedral(lut, gamma2_color);
  } else {
    lutted = lut.SampleLevel(samp, gamma2_color * lut_scale + lut_bias, 0.f);
  }
  return lutted * lutted;
}

struct NativeExpansionLuma {
  float source;   // Input luma, clamped to 0..1
  float boosted;  // After the highlight boost, before the shoulder; drives chroma reconstruction
  float mapped;   // After the shoulder, clamped to source..cap
  float cap;      // Ceiling in the pre-gamma domain
};

// Luma core of the game's native highlight expansion, with the cap recalibrated against
// Peak / Game Brightness instead of the in-game HDR sliders. The boost stays the vanilla
// cHDROutputControl.y: the shoulder saturates at boosted = 32 - cap + knee for any cap, and a
// boost derived from the cap lands video white exactly on that point - a flat clipped band.
// Used by the FMV decode of both games, which keeps its own soft knee and chroma reconstruction
// around this shoulder.
//
// source_luma is the Rec.709 luma of abs() of the decoded channels, not of the channels
// themselves: the game squares each channel and takes the root of the result, which is abs, and
// YUV -> sRGB can land a channel below zero out of gamut, so the two are not the same thing.
NativeExpansionLuma EvaluateNativeExpansionLuma(float source_luma, float weight, float native_boost) {
  NativeExpansionLuma result;
  result.source = saturate(source_luma);
  result.cap = InternalPeakRatio();

  const float knee = result.cap * result.cap * 0.03125f;
  const float boost = max(1.f, native_boost);
  const float shoulder_mask = saturate(result.source - 0.5f);
  const float boost_curve = (shoulder_mask * shoulder_mask * (weight * 100.f))
                            + (1.f / (1.f - (result.source * 0.5f)));
  result.boosted = result.source
                   + ((boost - 1.f) * 0.03846153989434242f  // = 1/26, from the vanilla block
                      * max(0.f, (boost_curve * result.source) - result.source));

  result.mapped = result.boosted;
  if (result.boosted > knee) {
    result.mapped = (knee + result.cap)
                    - ((result.cap * result.cap)
                       / ((result.cap - knee) + result.boosted));
  }

  result.mapped = clamp(result.mapped, result.source, result.cap);
  return result;
}

// Compresses the linear BT.709 scene into the game's SDR gamma-2 LUT domain by one max-channel
// scale, samples the grade there, then divides that same scale back out. The reconstructed HDR is
// display-mapped only once, either by FinalizeOutput's per-channel branch or by test24.
float3 ApplyRenoDXSceneOutput(
    float3 pre_compressor,  // linear scene color before the flag&2 compressor
    Texture3D<float3> lut, SamplerState lut_sampler,
    float lut_scale, float lut_bias) {  // Constant_072.x/.y
  pre_compressor = max(pre_compressor, 0.f);
 
  const float scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(pre_compressor);
  const float3 neutral_sdr = pre_compressor * scale;
  const float3 lutted = SampleHzdrLut(lut, lut_sampler, sqrt(neutral_sdr),
                                      lut_scale, lut_bias);
  const float3 graded_sdr = lerp(neutral_sdr, lutted, injectedData.color_grade_lut_strength);
  const float3 graded_hdr = renodx::math::DivideSafe(graded_sdr, scale.xxx, graded_sdr);

  if (injectedData.tone_map_type == HORIZON_TONE_MAP_TYPE_PSYCHOV) {
    return ApplyPsychoVOutput(graded_hdr);
  }
  return ApplyRenoDXStandardOutput(graded_hdr, true);
}

// Menus, loading screens and video reach the output encoder already display-mapped - by the game
// for UI, by the intercepted FMV decode for video - so they take the clamp-only path, never the
// scene-referred one. Runs in every active tone mapper, PsychoV included: the scene picks its
// mapper in ApplyRenoDXSceneOutput, this path has nothing left to map either way.
float3 ApplyEncodeOnlyOutput(float3 color) {
  return ApplyRenoDXStandardOutput(color);
}

// Rewrites the gamma exponent, paper white and peak that the AA/upscale resolvers use to decode
// and re-encode their history. Gated on the same condition that makes compose take the RenoDX
// branch, so the resolve can never read our fixed PQ output with the game's transform.
//
// This is the only change all ten resolver variants share, the one that never sharpens included:
// it swaps the game's output-space HDR cap for the RenoDX PQ cap, so temporal sharpening overshoot
// is bounded by Peak Brightness instead of being re-clipped at the in-game HDR Max Luminance.
// Optional RCAS rides on top of it in resolver_sharpening.hlsli and is a separate decision.
float4 GetResolverOutputParams(float4 game_output_params) {
  if ((injectedData.tone_map_type == HORIZON_TONE_MAP_TYPE_VANILLA)
      || (int(game_output_params.w) != 2)) {
    return game_output_params;
  }

  const float peak_nits = injectedData.peak_white_nits;
  game_output_params.x = renodx::color::pq::M1;
  game_output_params.y = injectedData.diffuse_white_nits / 10000.f;
  game_output_params.z = renodx::color::pq::EncodeSafe(peak_nits.xxx, 1.f).x;
  return game_output_params;
}

#endif  // SRC_GAMES_HORIZONZDR_FWCE_COMMON_HLSLI_
