// Yakuza: Like a Dragon - tone map + color grade + output encode pass.
// Restores the verified live/default Dragon Engine grade path:
// scene HDR -> curve -> exposure -> 3x 32^3 LUT blend -> YCbCr/HSL grade -> gamma 2.2 working space.

#include "./common.hlsl"

StructuredBuffer<uint> modeBuffer : register(t19);

Texture2D<float4> sceneTexture : register(t0);
Texture3D<float4> gradeLUT0 : register(t2);
Texture3D<float4> gradeLUT1 : register(t3);
Texture3D<float4> gradeLUT2 : register(t4);
Texture2D<float4> gradeMaskTexture : register(t5);

SamplerState sceneSampler_s : register(s0);
SamplerState gradeLUT0Sampler_s : register(s2);
SamplerState gradeLUT1Sampler_s : register(s3);
SamplerState gradeLUT2Sampler_s : register(s4);
SamplerState gradeMaskSampler_s : register(s5);

cbuffer cb1 : register(b1) {
  float4 cb1[54];
}

cbuffer cb9 : register(b9) {
  float4 cb9[3];
}

cbuffer cb12 : register(b12) {
  float4 cb12[30];
}

float3 PowSafe3(float3 color, float power) {
  return exp2(log2(max(color, 1e-7f)) * power);
}

float RgbHue(float3 color) {
  float max_channel = max(max(color.r, color.g), color.b);
  float min_channel = min(min(color.r, color.g), color.b);
  float delta = max_channel - min_channel;
  if (delta <= 1e-7f) return 0.f;

  float hue;
  if (max_channel == color.r) {
    hue = (color.g - color.b) / delta;
  } else if (max_channel == color.g) {
    hue = 2.f + (color.b - color.r) / delta;
  } else {
    hue = 4.f + (color.r - color.g) / delta;
  }
  return frac(hue / 6.f);
}

float HueToRgb(float p, float q, float t) {
  t = frac(t);
  if (t < (1.f / 6.f)) return p + (q - p) * 6.f * t;
  if (t < 0.5f) return q;
  if (t < (2.f / 3.f)) return p + (q - p) * ((2.f / 3.f) - t) * 6.f;
  return p;
}

float3 RgbToHsl(float3 color) {
  float max_channel = max(max(color.r, color.g), color.b);
  float min_channel = min(min(color.r, color.g), color.b);
  float lightness = (max_channel + min_channel) * 0.5f;
  float delta = max_channel - min_channel;

  float hue = 0.f;
  float saturation = 0.f;
  if (delta > 1e-7f) {
    saturation = lightness < 0.5f
                     ? delta / max(1e-7f, max_channel + min_channel)
                     : delta / max(1e-7f, 2.f - max_channel - min_channel);
    hue = RgbHue(color);
  }

  return float3(hue, saturation, lightness);
}

float3 HslToRgb(float3 hsl) {
  if (hsl.y <= 1e-7f) return hsl.zzz;

  float q = hsl.z < 0.5f ? hsl.z * (1.f + hsl.y) : hsl.z + hsl.y - hsl.z * hsl.y;
  float p = 2.f * hsl.z - q;
  return float3(
      HueToRgb(p, q, hsl.x + 1.f / 3.f),
      HueToRgb(p, q, hsl.x),
      HueToRgb(p, q, hsl.x - 1.f / 3.f));
}

float3 HsvToRgb(float hue, float saturation, float value) {
  float3 p = abs(frac(hue + float3(0.f, 2.f / 3.f, 1.f / 3.f)) * 6.f - 3.f);
  return value * lerp(1.f.xxx, saturate(p - 1.f), saturation);
}

float3 ApplyVanilla4096Grade(float3 scene, float3 curved) {
  float input_max = max(max(scene.r, scene.g), scene.b);
  input_max = max(input_max, 1e-4f);
  float3 input_normalized = scene / input_max;

  float input_norm_max = max(max(input_normalized.r, input_normalized.g), input_normalized.b);
  float input_norm_min = min(min(input_normalized.r, input_normalized.g), input_normalized.b);
  float input_saturation = (input_norm_max - input_norm_min) / max(input_norm_max, 1e-7f);

  float curved_luma = saturate(dot(curved, float3(0.299f, 0.587f, 0.114f)));
  float curved_max = max(max(curved.r, curved.g), curved.b);
  float curved_min = min(min(curved.r, curved.g), curved.b);
  float curved_saturation = (curved_max - curved_min) / max(curved_max, 1e-7f);
  float curved_hue = RgbHue(curved);

  float saturation_power = cb1[52].w / max(1e-7f, 1.f + cb1[52].y);
  float powered_input_saturation = pow(max(input_saturation, 1e-7f), saturation_power);
  float luma_mask = pow(max(curved_luma, 1e-7f), cb1[52].z * cb1[52].z);
  float target_saturation = powered_input_saturation * (1.f - luma_mask);
  target_saturation = pow(max(target_saturation, 1e-7f), 1.f / max(cb1[52].w, 1e-7f));

  float3 reinhard_scene = scene / (scene + 1.f);
  float reinhard_max = max(max(reinhard_scene.r, reinhard_scene.g), reinhard_scene.b);
  float reinhard_min = min(min(reinhard_scene.r, reinhard_scene.g), reinhard_scene.b);
  float reinhard_saturation = (reinhard_max - reinhard_min) / max(reinhard_max, 1e-7f);

  float saturation = max(max(target_saturation, reinhard_saturation), curved_saturation);
  return HsvToRgb(curved_hue, saturate(saturation), curved_max);
}

float3 ApplyVanillaDefaultCurve(float3 scene, uint mode_flags, float peak_ratio = 1.f) {
  // The verified live path uses the default branch. Branches for bits 4/8/256 stay intentionally
  // unported until a fresh snapshot proves they are active in gameplay/cutscene paths.
  // peak_ratio > 1 raises the curve's ceiling (asymptote 1/y -> peak_ratio/y) by relaxing the
  // denominator's compression term, so the SAME curve carries highlight detail above paper white
  // while shadows/mids (denominator dominated by cb1[53].z) stay identical. Used by Vanilla+ HDR.
  float3 log_color = log2(max(scene, 1e-7f)) * cb1[53].x;
  float3 numerator = exp2(log_color);
  float3 denominator = exp2(log_color * cb1[53].w) * (cb1[53].y / peak_ratio) + cb1[53].z;
  float3 color = numerator / denominator;

  if ((mode_flags & 4096u) != 0u) {
    color = ApplyVanilla4096Grade(scene, color);
  }

  return color;
}

float3 ApplyVanillaLUT(float3 color) {
  float3 lut_coords = min(1.f.xxx, color);
  lut_coords = (0.5f.xxx - lut_coords) * 0.03125f + lut_coords;

  float3 lut0 = gradeLUT0.Sample(gradeLUT0Sampler_s, lut_coords).rgb;
  float3 lut1 = gradeLUT1.Sample(gradeLUT1Sampler_s, lut_coords).rgb;
  float3 lut2 = gradeLUT2.Sample(gradeLUT2Sampler_s, lut_coords).rgb;

  float3 blended = lerp(lerp(lut0, lut1, cb9[2].x), lut2, cb9[2].y);
  return blended;
}

float3 ApplyVanillaYCbCrGrade(float3 color) {
  float2 strong_offset = -cb9[1].xy * cb9[1].z;
  float2 weak_offset = -cb9[1].xy * (1.f - cb9[1].z);

  float3 sat_color = saturate(color);
  float3 sat2 = sat_color * sat_color;
  float3 sat3 = sat2 * sat_color;
  float3 smooth = sat_color - 2.f * sat2 + sat3;
  float3 smooth_delta = sat3 - sat2;
  float3 channel_offset = weak_offset.x * smooth + weak_offset.y * smooth_delta;

  float y = dot(color, float3(0.299f, 0.587f, 0.114f));
  float cb = dot(color, float3(-0.16874f, -0.33126f, 0.5f));
  float cr = dot(color, float3(0.5f, -0.41869f, -0.08131f));

  float luma_sat = saturate(y);
  float luma2 = luma_sat * luma_sat;
  float luma3 = luma2 * luma_sat;
  float luma_smooth = luma_sat - 2.f * luma2 + luma3;
  float luma_delta = luma3 - luma2;
  float y_offset = strong_offset.x * luma_smooth + strong_offset.y * luma_delta;

  float3 adjusted_ycbcr = float3(y + y_offset * 3.f, cb, cr);
  float3 ycbcr_rgb = float3(
      adjusted_ycbcr.x + 1.402f * adjusted_ycbcr.z,
      adjusted_ycbcr.x - 0.34414f * adjusted_ycbcr.y - 0.71414f * adjusted_ycbcr.z,
      adjusted_ycbcr.x + 1.772f * adjusted_ycbcr.y);

  float3 delta = ycbcr_rgb - color;
  return color + channel_offset * 3.f + delta;
}

float3 ApplyVanillaFinalHslGrade(float3 color) {
  color = PowSafe3(saturate(color), 2.2f);

  float3 hsl = RgbToHsl(color);
  float lightness_power = 1.f / max(1e-7f, cb9[2].w + 0.5f);
  hsl.z = pow(max(hsl.z, 1e-7f), lightness_power);

  color = HslToRgb(hsl);
  return PowSafe3(saturate(color), 1.f / 2.2f);
}

float3 ApplyVanillaPostGrade(float3 color, float2 uv, float3 mask_base_working) {
  color = max(0.f.xxx, color);
  color = PowSafe3(color * cb9[0].xyz, cb9[2].z);

  uint grade_flags = asuint(cb9[1].w);
  if ((grade_flags & 2u) != 0u) {
    color = ApplyVanillaLUT(color);
  }
  if ((grade_flags & 1u) != 0u) {
    color = ApplyVanillaYCbCrGrade(color);
  }

  color = ApplyVanillaFinalHslGrade(color);

  float mask = gradeMaskTexture.Sample(gradeMaskSampler_s, uv).w;
  return lerp(mask_base_working, color, mask);
}

// Vanilla+ : the game's OWN tone curve + grade, highlights extended to HDR. Reproduces the SDR look
// exactly below paper white (UpgradeToneMap delta -> 0 there), and extends highlights using the same
// vanilla curve re-evaluated with a raised ceiling (peak/game), so detail survives instead of clamping.
// The grade is applied in SDR space (where its internal saturates are fine) then transplanted onto the
// extended luminance by UpgradeToneMap.
float3 ApplyVanillaPlusHDR(float3 scene, float2 uv, uint mode_flags, float3 scene_raw) {
  float peak_ratio = max(injectedData.toneMapPeakNits / injectedData.toneMapGameNits, 1.0001f);
  float3 sdr_tone = ApplyVanillaDefaultCurve(scene, mode_flags);                  // ceiling ~1
  float3 sdr_graded = ApplyVanillaPostGrade(sdr_tone, uv, scene_raw);             // gamma-2.2 encoded
  float3 hdr_tone = ApplyVanillaDefaultCurve(scene, mode_flags, peak_ratio);      // ceiling ~peak/game
  float3 hdr = renodx::tonemap::UpgradeToneMap(
      hdr_tone,
      sdr_tone,
      DecodeGameWorkingSpace(sdr_graded),
      saturate(injectedData.colorGradeLUTStrength));
  return EncodeGameWorkingSpace(hdr);
}

void main(
    float4 v0 : SV_POSITION0,
    out float4 o0 : SV_Target0) {
  float2 uv = cb12[29].zw * v0.xy;
  float4 scene_sample = sceneTexture.Sample(sceneSampler_s, uv);
  float3 scene = max(0.f.xxx, scene_sample.rgb);
  uint mode_flags = modeBuffer[1];

  if (injectedData.toneMapType == TONE_MAP_TYPE__SDR) {
    float3 vanilla_curve = ApplyVanillaDefaultCurve(scene, mode_flags);
    o0.rgb = ApplyVanillaPostGrade(vanilla_curve, uv, scene_sample.rgb);
  } else {  // Vanilla+ (only remaining HDR mapper)
    o0.rgb = ApplyVanillaPlusHDR(scene, uv, mode_flags, scene_sample.rgb);
  }
  o0.a = scene_sample.a;
}
