#include "./common.hlsl"

// Decima FMV decode: 4-plane YCbCr -> RGB with an EOTF decode that differs by output mode.
// The vanilla SDR branch decodes with proper piecewise sRGB, but the vanilla HDR branch
// (cHDROutputControl.x > 0) decodes with a plain 2.2 power before the native highlight expansion,
// crushing video shadows relative to the SDR reference. In non-Vanilla modes the HDR branch decodes
// with the same piecewise sRGB as SDR; the expansion and its x20 scale are untouched. Output stays
// linear and feeds the (intercepted) output pass 0x29103068. Note: this pass uses Rec.709 luma
// weights, not the Decima weights of the scene composite.

Texture2D<float4> YPlane : register(t16);
Texture2D<float4> CbPlane : register(t17);
Texture2D<float4> CrPlane : register(t18);
Texture2D<float4> APlane : register(t19);

SamplerState PlaneSampler : register(s0);

struct InUniformParams {
  float4 cHDROutputControl;
};

ConstantBuffer<InUniformParams> UniformParams[] : register(b4);

// NOTE: near-duplicate of renodx::color::srgb::Decode, kept LOCAL on purpose: the vanilla
// SDR branch below must stay bit-exact to the game's decompiled DXBC, and the library body
// compiles to different bytecode (strict `<` at the breakpoint + different instruction
// ordering — verified by a .cso hash A/B). Non-Vanilla HDR reuses it for SDR-parity.
float3 DecodeSRGBPiecewise(float3 color) {
  return float3(
      color.r < 0.040449999f ? color.r * 0.0773993805f : pow((color.r * 0.947867274f) + 0.0521326996f, 2.400000f),
      color.g < 0.040449999f ? color.g * 0.0773993805f : pow((color.g * 0.947867274f) + 0.0521326996f, 2.400000f),
      color.b < 0.040449999f ? color.b * 0.0773993805f : pow((color.b * 0.947867274f) + 0.0521326996f, 2.400000f));
}

struct PSInput {
  float4 position : SV_Position;
  float2 texcoord : TEXCOORD;
};

float4 main(PSInput input) : SV_Target {
  const float luma = YPlane.Sample(PlaneSampler, input.texcoord).x;
  const float cb = CbPlane.Sample(PlaneSampler, input.texcoord).y;
  const float cr = CrPlane.Sample(PlaneSampler, input.texcoord).z;
  const float weight = APlane.Sample(PlaneSampler, input.texcoord).w;

  float3 rgb = luma.xxx
               + (cb * float3(1.402000f, -0.714140f, 0.f))
               + (cr * float3(0.f, -0.344140f, 1.772000f))
               + float3(-0.701000f, 0.529140f, -0.886000f);

  float3 output_color;
  if (UniformParams[0].cHDROutputControl.x > 0.f) {
    float3 decoded;
    if (injectedData.tone_map_type != HZD_TONE_MAP_TYPE_VANILLA) {
      // sRGB-correct video decode, matching the vanilla SDR branch.
      decoded = DecodeSRGBPiecewise(rgb);
    } else {
      decoded = pow(abs(rgb), 2.200000f);
    }

    // Native highlight expansion, bit-exact to the original (Rec.709 luma, x20 final scale).
    const float expansion_luma = min(dot(decoded, float3(0.212600f, 0.715200f, 0.072200f)), 1.f);
    const float shoulder = (log2(1.f - (expansion_luma * 0.981684327f)) * -0.693147182f) / (expansion_luma + 0.000010f);
    const float native_peak = (weight * 24.f) + 1.f;
    const float weight_sat = saturate(weight);
    const float smooth_weight = ((-weight_sat * 2.f) + 3.f) * (weight_sat * weight_sat);
    const float expansion = (smooth_weight * (native_peak - shoulder)) + shoulder;
    const float expansion_scaled = expansion * 0.040000f;
    const float expansion_curve = ((-expansion * 0.040000f) + 1.f) * expansion_scaled + 1.f;
    const float scale = (expansion_scaled * expansion_curve) * 20.f;
    output_color = decoded * scale;
  } else {
    output_color = DecodeSRGBPiecewise(rgb);
  }

  return float4(output_color, 1.f);
}
