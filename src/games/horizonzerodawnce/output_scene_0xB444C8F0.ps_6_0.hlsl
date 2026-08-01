#include "./common.hlsl"

// Decima scene-final output transform: composites scene + DOF + bloom + flare + light shafts +
// grain + vignette, applies the local-luminance HDR compression, the 3D LUT, and the OETF. In the
// non-Vanilla HDR10 branch (output_mode 2) the whole tail from the compression gate onward is the
// RenoDX bridge and display map instead.

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
  float4 color : SV_Target0;  // rgb, alpha carries the native highlight weight
  float luma : SV_Target1;    // read by the FXAA pass
};

// Vanilla LUT sample: scale/bias, the coordinate-derived LOD, and trilinear filtering.
float3 SampleVanillaHzdLut(float3 pre_lut_color) {
  const float3 coord = pre_lut_color * Rgb3dLookupScaleBias.x + Rgb3dLookupScaleBias.y;
  return Rgb3dLookupTexture.SampleLevel(Rgb3dLookupSampler, coord, coord.z).rgb;
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

  const float3 light_shaft_term = LightShaftColor * LightShaftIntensity * light_shaft * injectedData.fx_light_shaft;

  const int output_mode = int(OETFSettings3.x);
  float highlight_weight;
  float3 output_color;

  if (output_mode == 2 && injectedData.tone_map_type != HZD_TONE_MAP_TYPE_VANILLA) {
    // renodx
    const SceneBridge bridge = BridgeSceneToSdr(color, light_shaft_term);
    float3 lut_color = saturate(
        SampleHzdLut(Rgb3dLookupTexture, Rgb3dLookupSampler, bridge.sdr,
                     Rgb3dLookupScaleBias.x, Rgb3dLookupScaleBias.y));
    // 1/scale is the headroom the bridge compressed away - the same quantity the vanilla block
    // measures as source luma over compressed luma.
    highlight_weight = saturate((LumaDecima(lut_color) * 8.f) - 4.f)
                       * saturate((max(renodx::math::DivideSafe(1.f, bridge.scale, 0.f), 0.f) - 1.f)
                                  * 0.03999999910593033f);
    lut_color = lerp(bridge.sdr, lut_color, saturate(injectedData.color_grade_lut_strength));
    output_color = ApplyRenoDXSceneOutput(bridge, lut_color);
  } else {
    // vanilla
    const float source_luma = LumaDecima(color);
    const float local_luminance = LocalLuminanceTexture.Sample(LocalLuminanceSampler, input.texcoord).x;

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

    const float3 pre_lut_color = saturate(1.f - saturate(1.f - light_shaft_term) * saturate(1.f - compressed_color));
    float3 lut_color = SampleVanillaHzdLut(pre_lut_color);
    const float compressed_luma = LumaDecima(compressed_color);
    highlight_weight = saturate((LumaDecima(lut_color) * 8.f) - 4.f)
                       * saturate((max(source_luma_scaled / (compressed_luma + 9.999999960041972e-13f), 0.f) - 1.f) * 0.03999999910593033f);

    float debug_mask;
    lut_color = ApplyDebugRamp(saturate(lut_color), input.texcoord, debug_mask);

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
