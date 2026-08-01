// HFW CE menu / FMV / loading output encoder.
// The HZDR twin is hzdr/output_menu_0x7475EFAE.

#include "../common.hlsli"

Texture2D<float4> t0_space8 : register(t0, space8);

cbuffer cb0_space8 : register(b0, space8) {
  float4 InUniform_Constant_000;
};

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  SamplerState samp = SamplerDescriptorHeap[0];
  float4 sampled = t0_space8.Sample(samp, float2(TEXCOORD.x, TEXCOORD.y));
  float3 color = sampled.xyz;

  const int output_mode = int(InUniform_Constant_000.w);
  [branch]
  if (output_mode == 1) {
    float3 powed = pow(abs(color), InUniform_Constant_000.x);
    color = float3(GameSRGBEncode(powed.x), GameSRGBEncode(powed.y), GameSRGBEncode(powed.z));
  } else if (output_mode == 2) {
    // RenoDX replaces the vanilla BT.2020 * paper white -> pow(gamma) -> PQ tail:
    // grade -> EOTF emulation -> hue-preserving safety cap -> mod paper white -> PQ.
    // FMV arrives already display-mapped by the intercepted decode pass 0x07DE7A57.
    color = ApplyEncodeOnlyOutput(color);
  }

  return float4(color, 1.f);
}
