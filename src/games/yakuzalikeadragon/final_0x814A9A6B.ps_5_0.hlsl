// Yakuza: Like a Dragon — final blit to the swap chain.
// Vanilla: linearize (pow 2.2) -> display color matrix -> display gamma -> sRGB encode -> 8-bit.
// RenoDX: the incoming color is our gamma-2.2 working-space HDR signal; decode it and scale to
//         scRGB linear for the upgraded fp16 / scRGB HDR swap chain (game's color-matrix +
//         sRGB encode dropped).

#include "./common.hlsl"

Texture2D<float4> sourceTexture : register(t0);
SamplerState sourceSampler_s : register(s0);

void main(
    linear noperspective float2 uv : TEXCOORD0,
    out float4 o0 : SV_Target0) {
  float3 color = sourceTexture.Sample(sourceSampler_s, uv).rgb;
  o0.rgb = FinalizeOutput(color);
  o0.w = 1.f;
}
