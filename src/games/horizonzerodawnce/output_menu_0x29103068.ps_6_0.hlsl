#include "./common.hlsl"

// Standalone Decima output transform used by the menu / FMV / loading presents (NOT the scene
// composite — that is 0xB444C8F0). Same three OETF modes as the scene pass's tail, but with a
// single input texture and no scene compositing. In non-Vanilla modes the native-HDR (PQ) branch is
// routed through the RenoDX fixed-HDR encode so menu/video highlights honor the configured peak nits
// instead of encoding straight into PQ's 10000-nit domain.

Texture2D<float4> SourceTexture : register(t0, space8);
SamplerState SourceSampler : register(s0, space8);

cbuffer ShaderInstance_PerInstance : register(b0, space8) {
  float4 OETFSettings0 : packoffset(c0);  // .x gamma, .yzw output matrix row
  float4 OETFSettings1 : packoffset(c1);  // .x native scale (mode 2), .yzw output matrix row
  float4 OETFSettings2 : packoffset(c2);  // .yzw output matrix row
  float4 OETFSettings3 : packoffset(c3);  // .x output mode
};

struct PSInput {
  float4 position : SV_Position;
  float2 texcoord : TEXCOORD;
};

float4 main(PSInput input) : SV_Target {
  float3 color = SourceTexture.Sample(SourceSampler, input.texcoord).rgb;

  const int output_mode = int(OETFSettings3.x);

  float3 output_color;
  if (output_mode == 2 && injectedData.tone_map_type != HZD_TONE_MAP_TYPE_VANILLA) {
    output_color = ApplyRenoDXFixedHDR10(color, false);
  } else {
    output_color = ApplyVanillaOutput(color, OETFSettings0, OETFSettings1, OETFSettings2, OETFSettings3);
  }

  return float4(output_color, 1.f);
}
