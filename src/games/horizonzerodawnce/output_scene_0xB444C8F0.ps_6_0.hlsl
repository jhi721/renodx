#include "./common.hlsl"

// Decima scene-final output transform: composites scene + DOF + bloom + flare + light shafts +
// grain + vignette, applies the local-luminance HDR compression, the 3D LUT, and the OETF.
// Rebuilt 1:1 from the decompiled original; the only change is the non-Vanilla HDR10 branch on
// output_mode 2.

Texture2D<float4> SceneTexture : register(t0, space8);
Texture2D<float4> CoCTexture : register(t1, space8);
Texture2D<float4> NearDOFTexture : register(t2, space8);
Texture2D<float4> SmallDOFTexture : register(t3, space8);
Texture2D<float4> BloomAndGrainWeightTexture : register(t4, space8);
Texture2D<float4> LightShaftTexture : register(t5, space8);
Texture2D<float4> FlareTexture : register(t6, space8);
Texture2D<float4> GrainTexture : register(t7, space8);
Texture3D<float4> Rgb3dLookupTexture : register(t8, space8);
Texture2D<float4> LocalLuminanceTexture : register(t9, space8);

RWBuffer<float> rwRenderInfo : register(u0, space8);

cbuffer ShaderInstance_PerInstance : register(b0, space8) {
  float4 cShaderInstance_PerInstance_Constants[15] : packoffset(c0);
};

SamplerState SceneSampler : register(s0, space8);
SamplerState CoCSampler : register(s1, space8);
SamplerState NearDOFSampler : register(s2, space8);
SamplerState SmallDOFSampler : register(s3, space8);
SamplerState BloomAndGrainWeightSampler : register(s4, space8);
SamplerState LightShaftSampler : register(s5, space8);
SamplerState FlareSampler : register(s6, space8);
SamplerState GrainSampler : register(s7, space8);
SamplerState Rgb3dLookupSampler : register(s8, space8);
SamplerState LocalLuminanceSampler : register(s9, space8);

#define Rgb3dLookupScaleBias (cShaderInstance_PerInstance_Constants[0].xy)
#define LightShaftIntensity (cShaderInstance_PerInstance_Constants[0].z)
#define LightShaftColor (cShaderInstance_PerInstance_Constants[1].rgb)
#define GrainWeightScale (cShaderInstance_PerInstance_Constants[2].x)
#define VignetteScale (cShaderInstance_PerInstance_Constants[3].xyz)
#define VignetteBias (cShaderInstance_PerInstance_Constants[4].x)
#define VignetteColor (cShaderInstance_PerInstance_Constants[5])
#define HdrCompressionControl (cShaderInstance_PerInstance_Constants[6])
#define HdrDebugControl (cShaderInstance_PerInstance_Constants[7])
#define HdrOutputControl (cShaderInstance_PerInstance_Constants[8])
#define OETFSettings0 (cShaderInstance_PerInstance_Constants[9])
#define OETFSettings1 (cShaderInstance_PerInstance_Constants[10])
#define OETFSettings2 (cShaderInstance_PerInstance_Constants[11])
#define OETFSettings3 (cShaderInstance_PerInstance_Constants[12])
#define UVClamp0 (cShaderInstance_PerInstance_Constants[13])
#define UVClamp1 (cShaderInstance_PerInstance_Constants[14])

struct PSInput {
  float4 position : SV_Position;
  float2 texcoord : TEXCOORD0;
  float2 grain_texcoord : TEXCOORD1;
};

struct PSOutput {
  float4 color : SV_Target0;
  float luma : SV_Target1;
};

// Exact vanilla LUT sample: preserve scale/bias, the coordinate-derived LOD, and
// trilinear filtering for Vanilla+ regardless of stale user LUT settings.
float3 SampleVanillaHzdLut(float3 pre_lut_color) {
  const float3 coord = pre_lut_color * Rgb3dLookupScaleBias.x + Rgb3dLookupScaleBias.y;
  return Rgb3dLookupTexture.SampleLevel(Rgb3dLookupSampler, coord, coord.z).rgb;
}

// Alternative modes retain the existing opt-in tetrahedral interpolation.
float3 SampleConfiguredHzdLut(float3 pre_lut_color) {
  if (injectedData.custom_lut_tetrahedral == 1.f) {
    return renodx::lut::SampleTetrahedral(Rgb3dLookupTexture, pre_lut_color, 0.f);
  }
  return SampleVanillaHzdLut(pre_lut_color);
}

float3 ApplyNativeHighlightExpansion(float3 color, float highlight_weight, float debug_mask) {
  const float luma = saturate(LumaDecima(color));
  const float shoulder = (log2(1.f - (luma * 0.9816843271255493f)) * -0.6931471824645996f) / (luma + 0.000009999999747378752f);
  const float weight = saturate(highlight_weight);
  const float smooth_weight = weight * weight * (3.f - (weight * 2.f));
  const float native_peak = (highlight_weight * 24.f) + 1.f;
  const float expansion = smooth_weight * (native_peak - shoulder) + shoulder;
  const float expansion_scaled = expansion * 0.03999999910593033f;
  const float expansion_curve = 1.f + (1.f - expansion_scaled) * expansion_scaled;
  const float scale = (((expansion * 0.7999999523162842f) * expansion_curve) - 1.f) * debug_mask + 1.f;
  return color * scale;
}

float3 ApplyVanillaHDRCompression(float3 color, float highlight_weight, float debug_mask) {
  color = pow(EncodeSRGB(color), 2.200000047683716f);
  return ApplyNativeHighlightExpansion(color, highlight_weight, debug_mask);
}

float3 ApplyDebugRamp(float3 color, float2 texcoord, out float debug_mask) {
  debug_mask = 1.f;

  if (HdrDebugControl.x < -0.009999999776482582f) {
    return color;
  }

  debug_mask = texcoord.x < HdrDebugControl.x ? 0.f : 1.f;

  if (HdrDebugControl.y >= 0.f && abs(HdrDebugControl.y * (texcoord.y - 0.5f)) < 0.05000000074505806f) {
    float ramp = exp2(floor(17.5f - (((HdrDebugControl.y * (texcoord.x - 0.5f)) + 0.5f) * 30.f)) * -2.f);
    ramp = (ramp < 0.001953125f || ramp > 1.f) ? 0.f : ramp;

    float encoded = pow(ramp, 0.4545454680919647f);
    float decoded = encoded < 0.040449999272823334f
                        ? encoded * 0.07739938050508499f
                        : pow((encoded * 0.9478672742843628f) + 0.05213269963860512f, 2.4000000953674316f);
    return decoded.xxx;
  }

  return color;
}

PSOutput main(PSInput input) {
  const float2 scene_uv = min(input.texcoord, UVClamp0.xy);
  const float2 small_dof_uv = min(input.texcoord, UVClamp0.zw);
  const float2 post_uv = min(input.texcoord, UVClamp1.xy);

  const float3 scene = SceneTexture.Sample(SceneSampler, scene_uv).rgb;
  const float coc = CoCTexture.Sample(CoCSampler, scene_uv).x;
  const float4 near_dof = NearDOFTexture.Sample(NearDOFSampler, post_uv);
  const float3 small_dof = SmallDOFTexture.Sample(SmallDOFSampler, small_dof_uv).rgb;
  const float4 bloom_and_grain = BloomAndGrainWeightTexture.Sample(BloomAndGrainWeightSampler, post_uv);
  const float3 flare = FlareTexture.Sample(FlareSampler, post_uv).rgb;
  const float3 light_shaft = LightShaftTexture.Sample(LightShaftSampler, post_uv).rgb;
  const float local_luminance = LocalLuminanceTexture.Sample(LocalLuminanceSampler, input.texcoord).x;

  const float dof_weight = saturate(abs(coc) * 10.f);
  const float near_weight = 1.f - near_dof.w;
  float3 color = (((lerp(scene, small_dof, dof_weight) * near_weight) + near_dof.rgb) + (flare * flare) * injectedData.fx_flare);

  const float bloom_scale = max(
      max(
          bloom_and_grain.x / ((bloom_and_grain.x + 0.019999999552965164f) + (color.x * 2.f)),
          bloom_and_grain.y / ((bloom_and_grain.y + 0.019999999552965164f) + (color.y * 2.f))),
      bloom_and_grain.z / ((bloom_and_grain.z + 0.019999999552965164f) + (color.z * 2.f)));

  color += bloom_and_grain.rgb * bloom_scale * injectedData.fx_bloom;
  color *= rwRenderInfo[2];

  const float red_scale = rwRenderInfo[8];
  const float green_scale = rwRenderInfo[9];
  const float blue_scale = rwRenderInfo[10];
  color = float3(
      saturate(red_scale - green_scale) * color.y + color.x * red_scale,
      color.y * green_scale,
      color.z * blue_scale);

  if (GrainWeightScale > 0.f) {
    const float grain = bloom_and_grain.w * GrainWeightScale * (GrainTexture.Sample(GrainSampler, input.grain_texcoord).y - 0.5f);
    color = max(color + grain, 0.f);
  }

  const float2 vignette_coord = (input.texcoord / VignetteScale.xy) * 2.f - 1.f;
  const float vignette_distance = saturate(length(vignette_coord) * VignetteScale.z + VignetteBias);
  const float vignette_weight = vignette_distance * vignette_distance * VignetteColor.w * injectedData.fx_vignette;
  color = color * (1.f - vignette_weight) + VignetteColor.rgb * vignette_weight;

  const float source_luma = LumaDecima(color);

  float3 compressed_color;
  float source_luma_scaled;
  if (HdrCompressionControl.x > 0.5f) {
    const float exposure_scale = 1.f / (local_luminance + 1.f);
    compressed_color = 1.f - exp2(min(color * exposure_scale, 20.f) * -1.4426950216293335f);
    source_luma_scaled = exposure_scale * source_luma;
  } else {
    compressed_color = color;
    source_luma_scaled = source_luma;
  }

  const float3 light_shaft_term = LightShaftColor * LightShaftIntensity * light_shaft * injectedData.fx_light_shaft;
  const float3 pre_lut_color = saturate(1.f - saturate(1.f - light_shaft_term) * saturate(1.f - compressed_color));

  const bool vanilla_plus =
      injectedData.tone_map_type == HZD_TONE_MAP_TYPE_VANILLA_PLUS;
  const bool customized =
      injectedData.tone_map_type == HZD_TONE_MAP_TYPE_CUSTOMIZED;
  float3 lut_color = vanilla_plus
                         ? SampleVanillaHzdLut(pre_lut_color)
                         : SampleConfiguredHzdLut(pre_lut_color);
  const float compressed_luma = LumaDecima(compressed_color);
  const float highlight_weight = saturate((LumaDecima(lut_color) * 8.f) - 4.f)
                                 * saturate((max(source_luma_scaled / (compressed_luma + 9.999999960041972e-13f), 0.f) - 1.f) * 0.03999999910593033f);

  lut_color = saturate(lut_color);
  if (!vanilla_plus) {
    lut_color = lerp(
        pre_lut_color,
        lut_color,
        saturate(injectedData.color_grade_lut_strength));
  }

  float debug_mask;
  lut_color = ApplyDebugRamp(lut_color, input.texcoord, debug_mask);

  const int output_mode = int(OETFSettings3.x);
  float3 output_color;

  if (output_mode == 2 && vanilla_plus) {
    if (HdrOutputControl.y >= 0.f) {
      lut_color = ApplyCalibratedNativeExpansion(
          lut_color,
          LumaDecima(lut_color),
          highlight_weight,
          debug_mask);
    }
    output_color = ApplyRenoDXStandardOutput(lut_color, true);
  } else if (output_mode == 2 && injectedData.tone_map_type != HZD_TONE_MAP_TYPE_VANILLA) {
    // Hue-preserving LUT bridge: same compression curve as the active vanilla gate, but computed
    // on the brightest channel and applied as a uniform RGB scale, so the LUT coordinate keeps
    // the source hue instead of collapsing saturated highlights toward white. In-gamut pixels
    // get s = 1 (no change). The scale only shapes the LUT coordinate: in the luminance match
    // below it cancels algebraically (Luminance(lut/s, Y(lut)/s, t) == lut * t/Y(lut)), so no
    // explicit un-divide is needed.
    const float max_channel = renodx::math::Max(color);
    float bridge_scale;
    if (HdrCompressionControl.x > 0.5f) {
      const float exposure_scale = 1.f / (local_luminance + 1.f);
      bridge_scale = max_channel > 0.f
                         ? (1.f - exp2(min(max_channel * exposure_scale, 20.f) * -1.4426950216293335f)) / max_channel
                         : 1.f;
    } else {
      bridge_scale = max_channel > 1.f ? 1.f / max_channel : 1.f;
    }
    const float3 bridged = color * bridge_scale;
    const float3 bridge_pre_lut = saturate(1.f - saturate(1.f - light_shaft_term) * saturate(1.f - bridged));
    float3 bridge_lut = saturate(SampleConfiguredHzdLut(bridge_pre_lut));
    bridge_lut = lerp(bridge_pre_lut, bridge_lut, saturate(injectedData.color_grade_lut_strength));
    bridge_lut = ApplyDebugRamp(bridge_lut, input.texcoord, debug_mask);
    float luma_target;
    if (customized) {
      // Customized keeps the vanilla LUT brightness, but calibrates the active native
      // expansion to Peak/Game in the same inverse-gamma domain as Vanilla+.
      const NativeExpansionLuma expansion =
          EvaluateNativeExpansionLuma(LumaDecima(lut_color), highlight_weight);
      luma_target = HdrOutputControl.y >= 0.f
                        ? lerp(expansion.source, expansion.mapped, debug_mask)
                        : LumaDecima(lut_color);
    } else {
      // Preserve the existing PsychoV-24 input exactly until that mapper gets its own plan.
      const float3 vanilla_expanded = HdrOutputControl.y >= 0.f
                                          ? ApplyNativeHighlightExpansion(lut_color, highlight_weight, debug_mask)
                                          : lut_color;
      luma_target = LumaDecima(vanilla_expanded);
    }

    float3 hue_matched = renodx::color::correct::Luminance(
        bridge_lut,
        LumaDecima(bridge_lut),
        luma_target);
    if (customized) {
      // PsychoV23 signed-opponent retention restores adaptive highlight hue between the
      // unbounded bridge and its calibrated luminance target, then compresses to BT.2020.
      const float3 anchor_lms = renodx::color::lms::from::BT709(0.18f.xxx);
      hue_matched = renodx::color::bt709::from::LMS(
          ApplyPsycho23SignedOpponentRetentionAndGamutCompressionLMS(
              renodx::color::lms::from::BT709(
                  renodx::math::DivideSafe(
                      bridge_lut,
                      bridge_scale.xxx,
                      bridge_lut)),
              renodx::color::lms::from::BT709(hue_matched),
              anchor_lms,
              anchor_lms,
              renodx::color::lms::from::BT709(NativeExpansionCap().xxx),
              renodx::color::macleod_boynton::BT2020_TO_LMS_WEIGHTED_MAT,
              1.f,
              1.f));
      output_color = ApplyRenoDXStandardOutput(hue_matched, true);
    } else {
      output_color = ApplyRenoDXPsychoVOutput(hue_matched, true);
    }
  } else {
    if (HdrOutputControl.y >= 0.f) {
      lut_color = ApplyVanillaHDRCompression(lut_color, highlight_weight, debug_mask);
    }
    output_color = ApplyVanillaOutput(lut_color, OETFSettings0, OETFSettings1, OETFSettings2, OETFSettings3);
  }

  PSOutput output;
  output.color = float4(output_color, highlight_weight);
  output.luma = LumaDecima(output_color);
  return output;
}
