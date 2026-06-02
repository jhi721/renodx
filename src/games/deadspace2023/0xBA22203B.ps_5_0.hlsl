// ---- Created with 3Dmigoto v1.3.16 on Tue Jun 02 14:06:15 2026
// RenoDX: Dead Space (2023) uber-post (barrel distortion + depth fog/flash + vignette). Only the
// vignette darkening is scaled by the Vignette slider (Vanilla+); distortion/fog kept verbatim.
#include "./shared.h"

Texture2D<float4> t2 : register(t2);

Texture2D<float4> t1 : register(t1);

Texture2D<float4> t0 : register(t0);

SamplerState s2_s : register(s2);

SamplerState s1_s : register(s1);

SamplerState s0_s : register(s0);

cbuffer cb0 : register(b0)
{
  float4 cb0[9];
}




// 3Dmigoto declarations
#define cmp -


void main(
  float4 v0 : SV_Position0,
  float2 v1 : TEXCOORD0,
  out float4 o0 : SV_Target0)
{
  float4 r0,r1,r2;
  uint4 bitmask, uiDest;
  float4 fDest;

  r0.xy = cmp(float2(0,0) < cb0[2].xw);
  if (r0.x != 0) {
    r0.xz = float2(-0.5,-0.5) + v1.xy;
    r0.w = dot(r0.xz, r0.xz);
    r1.x = cmp(abs(cb0[2].z) < 9.99999975e-005);
    if (r1.x != 0) {
      r1.x = r0.w * cb0[2].y + 1;
      r1.y = max(0, cb0[2].y);
      r1.y = r1.y * 0.5 + 1;
      r1.x = r1.x / r1.y;
    } else {
      r1.y = sqrt(r0.w);
      r1.y = cb0[2].z * r1.y + cb0[2].y;
      r0.w = r0.w * r1.y + 1;
      r1.y = cb0[2].z * 0.707106769 + cb0[2].y;
      r1.y = max(0, r1.y);
      r1.y = r1.y * 0.5 + 1;
      r1.x = r0.w / r1.y;
    }
    r0.xz = r0.xz * r1.xx + float2(0.5,0.5);
  } else {
    r0.xz = v1.xy;
  }
  r1.xyzw = t0.SampleLevel(s0_s, r0.xz, 0).xyzw;
  if (r0.y != 0) {
    r0.x = t1.SampleLevel(s1_s, r0.xz, 0).x;
    r0.x = -cb0[1].y + r0.x;
    r0.x = 1 / r0.x;
    r0.x = cb0[1].x * r0.x;
    r0.y = cmp(r0.x < 5000);
    if (r0.y != 0) {
      r0.x = -64 * r0.x;
      r0.x = r0.x / cb0[4].x;
      r0.x = exp2(r0.x);
      r0.yzw = float3(0.25,0.25,0.25) * cb0[3].xyz;
      r2.x = 1 + -r0.x;
      r0.yzw = r2.xxx * r0.yzw;
      r1.xyz = r1.xyz * r0.xxx + r0.yzw;
    }
  }
  r0.xy = cmp(float2(0,0) < cb0[7].xz);
  if (r0.x != 0) {
    r2.xyzw = t2.Sample(s2_s, float2(0,0)).xyzw;
    r0.x = cb0[7].y * cb0[7].x;
    r1.xyzw = r2.xyzw * r0.xxxx + r1.xyzw;
  }
  if (r0.y != 0) {
    r0.xy = float2(-0.5,-0.5) + v1.xy;
    r0.xy = r0.xy + r0.xy;
    r0.x = dot(r0.xy, r0.xy);
    r0.x = sqrt(r0.x);
    r0.x = 0.707106769 * r0.x;
    r0.x = min(1, r0.x);
    r0.x = log2(r0.x);
    r0.x = cb0[7].w * r0.x;
    r0.x = exp2(r0.x);
    r0.x = 1 + -r0.x;
    r0.y = 1 + -cb0[8].x;
    r0.x = r0.x * r0.y + cb0[8].x;
    // RenoDX: scale vignette strength (Vanilla+ only; 1.0 = vanilla, 0 = off -> factor lerps to 1).
    if (shader_injection.tone_map_mode == TONE_MAP_MODE_VANILLA_PLUS) {
      r0.x = lerp(1.0, r0.x, shader_injection.fxVignette);
    }
    r1.xyz = r1.xyz * r0.xxx;
  }
  o0.xyzw = r1.xyzw;
  return;
}