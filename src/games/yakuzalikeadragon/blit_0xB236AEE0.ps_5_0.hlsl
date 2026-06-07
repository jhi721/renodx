// Yakuza: Like a Dragon -- pre-final blit (passthrough copy).
// Vanilla: sample the tonemap output and write the b8g8r8a8 buffer consumed by 0x814A9A6B.
// RenoDX: keep the same copy, but the add-on hot-swaps this RT to fp16 so the HDR working-space
// signal from 0xEE858EE5 survives into the final blit replacement.

Texture2D<float4> sourceTexture : register(t0);
SamplerState sourceSampler_s : register(s0);

[earlydepthstencil]
void main(
    linear noperspective float2 uv : TEXCOORD0,
    out float4 o0 : SV_Target0) {
  o0 = sourceTexture.Sample(sourceSampler_s, uv);
}
