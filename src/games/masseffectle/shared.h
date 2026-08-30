#ifndef SRC_GAMES_MASSEFFECTLE_SHARED_H_
#define SRC_GAMES_MASSEFFECTLE_SHARED_H_

struct ShaderInjectData {
  float peak_white_nits;
  float diffuse_white_nits;
  float graphics_white_nits;
  float scene_grade_strength;
  float tone_map_type;
  float tone_map_exposure;
  float tone_map_highlights;
  float tone_map_shadows;
  float tone_map_contrast;
  float tone_map_saturation;
  float custom_bloom;
  float custom_vignette;
  float custom_film_grain;
  float custom_lut_sampling;
  float custom_random;
};

#ifndef __cplusplus
#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
cbuffer shader_injection : register(b13, space50) {
#elif (__SHADER_TARGET_MAJOR < 5) || ((__SHADER_TARGET_MAJOR == 5) && (__SHADER_TARGET_MINOR < 1))
cbuffer shader_injection : register(b13) {
#endif
  ShaderInjectData shader_injection : packoffset(c0);
}

#define RENODX_TONE_MAP_TYPE        shader_injection.tone_map_type
#define RENODX_PEAK_WHITE_NITS      shader_injection.peak_white_nits
#define RENODX_DIFFUSE_WHITE_NITS   shader_injection.diffuse_white_nits
#define RENODX_GRAPHICS_WHITE_NITS  shader_injection.graphics_white_nits
#define RENODX_GAMMA_CORRECTION     0
#define RENODX_TONE_MAP_EXPOSURE    shader_injection.tone_map_exposure
#define RENODX_TONE_MAP_HIGHLIGHTS  shader_injection.tone_map_highlights
#define RENODX_TONE_MAP_SHADOWS     shader_injection.tone_map_shadows
#define RENODX_TONE_MAP_CONTRAST    shader_injection.tone_map_contrast
#define RENODX_TONE_MAP_SATURATION  shader_injection.tone_map_saturation
#define RENODX_COLOR_GRADE_STRENGTH shader_injection.scene_grade_strength
#define CUSTOM_BLOOM                (RENODX_TONE_MAP_TYPE == 0.f ? 1.f : shader_injection.custom_bloom)
#define CUSTOM_VIGNETTE             (RENODX_TONE_MAP_TYPE == 0.f ? 1.f : shader_injection.custom_vignette)
#define CUSTOM_LUT_SAMPLING         (RENODX_TONE_MAP_TYPE == 0.f ? 0.f : shader_injection.custom_lut_sampling)
#define CUSTOM_FILM_GRAIN           shader_injection.custom_film_grain
#define CUSTOM_RANDOM               shader_injection.custom_random

#include "../../shaders/renodx.hlsl"

#include "./psycho_test30.hlsli"

static const float MELE_MIDGRAY_SCENE = 0.18f;

float MELENativeCurve(float color) {
  return 1.f - exp2(-1.70000005f * color);
}

static const float MELE_MIDGRAY_NATIVE_CURVE = MELENativeCurve(MELE_MIDGRAY_SCENE);

// ImageAdjustments mixes neutral mid grey to this fraction of the curve value before the LUT; luminance only, since a chromatic anchor would adapt away the tint the game applies on purpose.
static const float MELE_MIDGRAY_ANCHOR_SCALE = 0.81756f;

// The game's filmic LUT is addressed through this scale; its domain covers scene linear to about 16.2.
static const float MELE_FILMIC_LUT_SCALE = 0.0616082214f;

float MELEFilmicCoord(float scene, bool has_precurve) {
  return MELE_FILMIC_LUT_SCALE * (has_precurve ? MELENativeCurve(scene) : scene);
}

// Feeds SV_Target1, which CMAA reads as its luma: clamp like vanilla's 8-bit target and cancel the nits transport, or Game/UI Brightness moves edge detection. No-op in Vanilla.
float MELEOutputLuma(float3 encoded_output) {
  const float transport = (RENODX_TONE_MAP_TYPE == 0.f)
                              ? 1.f
                              : pow(RENODX_GRAPHICS_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS, 1.f / 2.2f);
  return dot(saturate(encoded_output * transport), float3(0.212670997f, 0.715160012f, 0.0721689984f));
}

float3 CustomToneMapPass(float3 untonemapped, float3 graded_sdr_color, float expand, float anchor,
                         float3 vignette_tint) {
  return renodx_custom::tonemap::psycho30::psychotm_test30(
      lerp(untonemapped, graded_sdr_color * expand, RENODX_COLOR_GRADE_STRENGTH)
          * renodx::math::SignPow(vignette_tint, 2.2f),
      RENODX_PEAK_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS,
      RENODX_TONE_MAP_EXPOSURE,
      RENODX_TONE_MAP_HIGHLIGHTS,
      RENODX_TONE_MAP_SHADOWS,
      RENODX_TONE_MAP_CONTRAST,
      RENODX_TONE_MAP_SATURATION,   // purity_scale
      1.f, 100.f, 1.f,              // bleaching / clip / hue_restore - placeholders
      1.f,                          // encoded_response_power - placeholder
      0,                            // white_curve_mode - placeholder
      1.f,                          // cone_response_exponent
      anchor.xxx, anchor.xxx);  // anchors; the four trailing arguments keep their defaults
}

static const float3 MELE_VIGNETTE_TINT_ME1 = float3(1.0103630004f, 1.00000575f, 1.0130924946f);
static const float3 MELE_VIGNETTE_TINT_ME2 = float3(1.0103630004f, 1.00000575f, 1.163092494f);
static const float3 MELE_VIGNETTE_TINT_ME3 = float3(1.01036298f, 1.00000572f, 1.16309249f);

// Exact inverse of the curve vanilla applied, normalised so 0.18 scene grey stays put.
float3 MELEToneMapAnalytic(float3 untonemapped, float3 graded_sdr_color, float mid_gray,
                           float3 vignette_tint = 1.f) {
  const float mch = renodx::math::Max(untonemapped);
  return CustomToneMapPass(
      untonemapped, graded_sdr_color,
      max(1.f, renodx::math::DivideSafe(mch * (mid_gray / MELE_MIDGRAY_SCENE), MELENativeCurve(mch))),
      mid_gray * MELE_MIDGRAY_ANCHOR_SCALE, vignette_tint);
}

// ME3's analytic scene pass carries no tone curve, only the clip its grade opens with, so mid grey is identity and the reconstruction is that clip's plain inverse.
float3 MELEToneMapClipped(float3 untonemapped, float3 graded_sdr_color, float3 vignette_tint = 1.f) {
  return CustomToneMapPass(untonemapped, graded_sdr_color, max(1.f, renodx::math::Max(untonemapped)),
                           MELE_MIDGRAY_SCENE, vignette_tint);
}

float3 MELEToneMapFilmic(float3 untonemapped, float3 graded_sdr_color,
                         Texture2D<float4> filmic_lut, SamplerState filmic_sampler, bool has_precurve,
                         float3 vignette_tint = 1.f) {
  const float mch = max(renodx::math::Max(untonemapped), 1e-6f);

  const float u_mid = MELEFilmicCoord(MELE_MIDGRAY_SCENE, has_precurve);
  const float u_lo = MELEFilmicCoord(0.16f, has_precurve);
  const float u_hi = MELEFilmicCoord(0.20f, has_precurve);
  const float u_mch = MELEFilmicCoord(mch, has_precurve);
  // Sample the last texel centre, not u = 1, so the game's sampler addressing cannot affect the read.
  const float u_top = min(4095.5f / 4096.f, MELEFilmicCoord(1e4f, has_precurve));

  const float y_mid = filmic_lut.SampleLevel(filmic_sampler, float2(u_mid, 0.5f), 0).x;
  const float g_lo = filmic_lut.SampleLevel(filmic_sampler, float2(u_lo, 0.5f), 0).x;
  const float g_hi = filmic_lut.SampleLevel(filmic_sampler, float2(u_hi, 0.5f), 0).x;
  const float g_mch = filmic_lut.SampleLevel(filmic_sampler, float2(u_mch, 0.5f), 0).x;
  const float g_top = filmic_lut.SampleLevel(filmic_sampler, float2(u_top, 0.5f), 0).x;

  const float tm_tan = y_mid + ((g_hi - g_lo) / 0.04f) * (mch - MELE_MIDGRAY_SCENE);

  const float progress = saturate((g_mch - y_mid) / max(g_top - y_mid, 1e-4f));
  const float tm = lerp(g_mch, tm_tan, progress * progress);

  // tm + 0.1 is the closed form of tm / ReinhardPiecewise(tm, 1, 0.9): shoulder exposure is 1 / (1 - 0.9) = 10, and max() replaces its seam test at 0.9.
  return CustomToneMapPass(untonemapped, graded_sdr_color, max(1.f, tm + 0.1f), y_mid, vignette_tint);
}

#endif

#endif  // SRC_GAMES_MASSEFFECTLE_SHARED_H_
