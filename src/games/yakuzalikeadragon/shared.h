#ifndef SRC_GAMES_YAKUZALIKEADRAGON_SHARED_H_
#define SRC_GAMES_YAKUZALIKEADRAGON_SHARED_H_

#ifndef __cplusplus
#include "../../shaders/renodx.hlsl"
#endif

// Must be 32bit aligned. Should be 4x32.
struct ShaderInjectData {
  float toneMapType;
  float toneMapPeakNits;
  float toneMapGameNits;
  float toneMapGammaCorrection;
  float colorGradeLUTStrength;
  float pad0;
  float pad1;
  float pad2;
};

#define TONE_MAP_TYPE__SDR          0.f
#define TONE_MAP_TYPE__VANILLA_PLUS 1.f

#ifndef __cplusplus
// Use space50 when the shader target supports register spaces. LAD replacements are ps_5_0/fxc, so
// they fall back to b0 while the add-on still requests space50 for cloned layouts where available.
#if ((__SHADER_TARGET_MAJOR == 5 && __SHADER_TARGET_MINOR >= 1) || __SHADER_TARGET_MAJOR >= 6)
cbuffer injectedBuffer : register(b0, space50) {
#elif (__SHADER_TARGET_MAJOR < 5) || ((__SHADER_TARGET_MAJOR == 5) && (__SHADER_TARGET_MINOR < 1))
cbuffer injectedBuffer : register(b0) {
#endif
  ShaderInjectData injectedData : packoffset(c0);
}
#endif

#endif  // SRC_GAMES_YAKUZALIKEADRAGON_SHARED_H_
