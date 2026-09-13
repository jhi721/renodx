#ifndef SRC_GAMES_MASSEFFECTLE_SHARED_H_
#define SRC_GAMES_MASSEFFECTLE_SHARED_H_

struct ShaderInjectData {
  float peak_white_nits;      // display peak nits; defaults to the swapchain's reported peak
  float diffuse_white_nits;   // game brightness nits
  float graphics_white_nits;  // UI brightness nits
  float tone_map_type;        // 0 = Vanilla, 1 = PsychoV-30
  float tone_map_exposure;    // PsychoV exposure scale (1.0 = neutral)
  float tone_map_highlights;  // 1.0 = neutral
  float tone_map_shadows;     // 1.0 = neutral
  float tone_map_contrast;    // 1.0 = neutral
  float tone_map_saturation;  // PsychoV purity scale (1.0 = neutral)
  float custom_bloom;         // bloom blend weight scale (1.0 = vanilla)
  float custom_vignette;      // vignette strength (1.0 = vanilla, 0 = off)
  float custom_film_grain;    // film grain strength (0 = off)
  float custom_lut_sampling;  // 0 = Trilinear (vanilla), 1 = Tetrahedral
  float custom_lut_strength;  // 0 = LUT off, 1.0 = vanilla
  float custom_random;        // per-frame random seed for film grain
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
#define CUSTOM_BLOOM                (RENODX_TONE_MAP_TYPE == 0.f ? 1.f : shader_injection.custom_bloom)
#define CUSTOM_VIGNETTE             (RENODX_TONE_MAP_TYPE == 0.f ? 1.f : shader_injection.custom_vignette)
#define CUSTOM_LUT_SAMPLING         (RENODX_TONE_MAP_TYPE == 0.f ? 0.f : shader_injection.custom_lut_sampling)
#define CUSTOM_LUT_STRENGTH         (RENODX_TONE_MAP_TYPE == 0.f ? 1.f : shader_injection.custom_lut_strength)
#define CUSTOM_FILM_GRAIN           shader_injection.custom_film_grain
#define CUSTOM_RANDOM               shader_injection.custom_random

#include "../../shaders/renodx.hlsl"

#include "./psycho_test30.hlsli"

static const float MELE_MIDGRAY_SCENE = 0.18f;

// Native per-channel tone curve of the ME1/ME2 exponential permutations.
float MELENativeCurve(float color) {
  return 1.f - exp2(-1.70000005f * color);
}

float3 MELENativeCurve(float3 color) {
  return 1.f - exp2(-1.70000005f * color);
}

static const float MELE_MIDGRAY_NATIVE_CURVE = MELENativeCurve(MELE_MIDGRAY_SCENE);

// The native curve's derivative at scene mid grey: a * ln2 * 2^(-a * p) = a * ln2 * (1 - F(p)).
static const float MELE_EXP_SLOPE = 1.70000005f * 0.693147181f * (1.f - MELE_MIDGRAY_NATIVE_CURVE);

// PsychoV anchor of the exponential families: ImageAdjustments maps neutral mid grey to 0.81756 of the curve value.
static const float MELE_EXP_ANCHOR = MELE_MIDGRAY_NATIVE_CURVE * 0.81756f;

// The game's filmic LUT is addressed through this scale; its domain covers scene linear to about 16.2.
static const float MELE_FILMIC_LUT_SCALE = 0.0616082214f;

float MELEFilmicLookup(Texture2D<float4> filmic_lut, SamplerState filmic_sampler, float z) {
  return filmic_lut.SampleLevel(filmic_sampler, float2(MELE_FILMIC_LUT_SCALE * z, 0.5f), 0).x;
}

// SV_Target1 luma for CMAA: clamped like vanilla's 8-bit target, with the UI brightness transport divided out.
float MELEOutputLuma(float3 encoded_output) {
  const float transport = (RENODX_TONE_MAP_TYPE == 0.f)
                              ? 1.f
                              : pow(RENODX_GRAPHICS_WHITE_NITS / RENODX_DIFFUSE_WHITE_NITS, 1.f / 2.2f);
  return dot(saturate(encoded_output * transport), float3(0.212670997f, 0.715160012f, 0.0721689984f));
}

// PsychoV-30 display map. hdr is linear BT.709 relative to game brightness; vignette_tint is the game's encoded white-point tint.
float3 CustomToneMapPass(float3 hdr, float anchor, float3 vignette_tint) {
  return renodx_custom::tonemap::psycho30::psychotm_test30(
      hdr * renodx::math::SignPow(vignette_tint, 2.2f),
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

// Encoded white-point tint of each game's vignette.
static const float3 MELE_VIGNETTE_TINT_ME1 = float3(1.0103630004f, 1.00000575f, 1.0130924946f);
static const float3 MELE_VIGNETTE_TINT_ME2 = float3(1.0103630004f, 1.00000575f, 1.163092494f);
static const float3 MELE_VIGNETTE_TINT_ME3 = float3(1.01036298f, 1.00000572f, 1.16309249f);

// HDR reconstruction ahead of PsychoV, one model per colour family: MELEToneMapME12 (ME1/ME2 exponential curve + colour
// LUT), MELEToneMapAnalytic (ME1/ME2 exponential curve + analytic grade), MELEToneMapFilmic (filmic + colour LUT) and
// MELEToneMapME3Analytic (ME3 analytic hard clip). All but the hard clip keep the native SDR grade's RGB ratios at the
// working luminance; the hard clip takes only hue from it. Invalid input keeps the native result for the whole triple,
// and a working value that failed is carried as -1.

// True when no channel is Inf or NaN, read from the exponent bits.
bool MELEIsFinite(float3 v) {
  return all((asuint(v) & 0x7F800000) != 0x7F800000);
}

bool MELEIsFiniteNonNegative(float3 v) {
  return MELEIsFinite(v) && all(v >= 0.f);
}

// Bounded native SDR in linear. The game's gamma and the 2.2 decode are both omitted, so the transfer is the scale alone.
float3 MELENativeLinear(float3 graded, float3 scale, bool black_floor) {
  const float3 color = saturate(scale * graded);
  return black_floor ? max(9.99999975e-05f, color) : color;
}

// ME1/ME2 highlight desaturation and ImageAdjustments, in RGB and unclamped.
float3 MELEImageAdjustME12(float3 color) {
  float4 r0, r1, r2;
  r0.xyz = color;
  r1.xyz = float3(0.98082906, 0.980000436, 0.993047416) * r0.xyz;
  r0.w = (1.10000002 < dot(r0.xyz, float3(0.333000004, 0.333000004, 0.333000004))) ? 1 : 0;
  r2.x = dot(r1.xyz, float3(0.300000012, 0.589999974, 0.109999999));
  r2.xyz = -r0.xyz * float3(0.98082906, 0.980000436, 0.993047416) + r2.xxx;
  r1.xyz = r2.xyz * float3(0.5, 0.5, 0.5) + r1.xyz;
  r0.xyz = r0.w * r1.xyz + (1 - r0.w) * r0.xyz;
  r0.w = dot(r0.xyz, float3(0.300000012, 0.589999974, 0.109999999));
  r1.xyz = float3(0.400000006, 0.400000006, 0.400000006) * r0.xyz;
  r1.xyz = r0.www * float3(0.600000024, 0.600000024, 0.600000024) + r1.xyz;
  r1.xyz = r1.xyz * float3(0.00658500008, 0.0199180003, 1) + -r0.xyz;
  return r1.xyz * float3(0.200000003, 0.200000003, 0.200000003) + r0.xyz;
}

// Working value of the exponential families: the native curve up to scene mid grey and its tangent beyond, per channel,
// plus bloom after the curve as vanilla adds it. -1 when scene or bloom alone is negative or non-finite.
float3 MELEExpWork(float3 scene, float3 bloom) {
  const float3 continued = scene <= MELE_MIDGRAY_SCENE
                               ? MELENativeCurve(scene)
                               : MELE_MIDGRAY_NATIVE_CURVE + MELE_EXP_SLOPE * (scene - MELE_MIDGRAY_SCENE);
  return (MELEIsFiniteNonNegative(scene) && MELEIsFiniteNonNegative(bloom)) ? continued + bloom : -1.f;
}

// Max-channel scale q for all three channels: identity up to 0.75, a C1 Reinhard shoulder asymptotic to 1 above it.
// Divide the graded result by q to undo it.
bool MELETryGradeProxy(float3 work, out float q, out float3 proxy) {
  const float k = 0.75f;
  const float m = renodx::math::Max(work);
  q = m <= k ? 1.f : (k + renodx::tonemap::Reinhard(m - k, 1.f - k)) / m;
  proxy = work * q;
  return MELEIsFiniteNonNegative(work);
}

// native_linear's RGB ratios at target_y. A black target or reference gives black; invalid input returns native_linear.
float3 MELENativeColorAtLuminance(float3 native_linear, float target_y) {
  const float native_y = renodx::color::y::from::BT709(native_linear);
  const float3 result = native_linear * (target_y / native_y);
  if (!MELEIsFiniteNonNegative(native_linear) || !MELEIsFiniteNonNegative(target_y)) return native_linear;
  if (target_y == 0.f || all(native_linear == 0.f)) return 0.f;
  if (native_y < 1e-6f || !MELEIsFiniteNonNegative(result)) return native_linear;
  return result;
}

// Continues the bound filmic LUT past its mid-grey node along the secant of its 0.16 / 0.20 probes, per channel, in the
// LUT's input domain z (after the exponential curve when has_precurve). Below the node the native sample stays; -1 when
// z, native or the probe window is invalid.
float3 MELEFilmicExtended(Texture2D<float4> filmic_lut, SamplerState filmic_sampler, float3 z, float3 native,
                          bool has_precurve) {
  const float z_lo = has_precurve ? MELENativeCurve(0.16f) : 0.16f;
  const float z_mid = has_precurve ? MELE_MIDGRAY_NATIVE_CURVE : MELE_MIDGRAY_SCENE;
  const float z_hi = has_precurve ? MELENativeCurve(0.20f) : 0.20f;
  const float y_lo = MELEFilmicLookup(filmic_lut, filmic_sampler, z_lo);
  const float y_mid = MELEFilmicLookup(filmic_lut, filmic_sampler, z_mid);
  const float y_hi = MELEFilmicLookup(filmic_lut, filmic_sampler, z_hi);
  const float slope = (y_hi - y_lo) / (z_hi - z_lo);
  const bool valid = MELEIsFiniteNonNegative(z) && MELEIsFiniteNonNegative(native) && y_lo <= y_mid && y_mid <= y_hi
                     && slope > (has_precurve ? 0.f : 1e-5f);
  return valid ? (z > z_mid ? y_mid + slope * (z - z_mid) : native) : -1.f;
}

#endif

#endif  // SRC_GAMES_MASSEFFECTLE_SHARED_H_
