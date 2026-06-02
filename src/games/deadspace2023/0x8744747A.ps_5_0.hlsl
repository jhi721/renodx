// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 02 14:06:15 2026
// RenoDX: Dead Space (2023) bloom composite (o0 = scene*cb0[3] + bloom*cb0[4]). Scales the bloom
// contribution by the Bloom slider (Vanilla+ only). See shared.h.
#include "./shared.h"

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[5];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float4 v1 : TEXCOORD0,
  float2 v2 : TEXCOORD1,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xyzw = t1.Sample(s1_s, v2.xy).xyzw;
  r0.xyzw = cb0[4].xyzw * r0.xyzw;
  // RenoDX: scale the bloom contribution rgb only (Vanilla+; 1.0 = vanilla, 0 = off). Leave alpha
  // (r0.w) as vanilla so the composite RT's alpha is unchanged for any downstream consumer.
  if (shader_injection.tone_map_mode == TONE_MAP_MODE_VANILLA_PLUS) {
    r0.xyz = r0.xyz * shader_injection.fxBloom;
  }
  r1.xyzw = t0.Sample(s0_s, v2.xy).xyzw;
  o0.xyzw = r1.xyzw * cb0[3].xyzw + r0.xyzw;
  return;
}