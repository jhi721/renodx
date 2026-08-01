#ifndef SRC_GAMES_HORIZONZERODAWNCE_SHARED_H_
#define SRC_GAMES_HORIZONZERODAWNCE_SHARED_H_

#define HZD_TONE_MAP_TYPE_VANILLA 0.f
#define HZD_TONE_MAP_TYPE_VANILLA_PLUS 1.f
#define HZD_TONE_MAP_TYPE_PSYCHOV 2.f

#define HZD_GAMMA_CORRECTION_OFF 0.f
#define HZD_GAMMA_CORRECTION_2_2 1.f
#define HZD_GAMMA_CORRECTION_BT1886 2.f

// Must be 32-bit aligned.
struct ShaderInjectData {
  float tone_map_type;       // One of HZD_TONE_MAP_TYPE_*; Vanilla disables replacement
  float peak_white_nits;     // Display peak, 100..4000; a ceiling, not a target
  float diffuse_white_nits;  // Nits that shader 1.0 maps to, 48..500
  float gamma_correction;    // One of HZD_GAMMA_CORRECTION_*
  float tone_map_blowout;    // 0..1, default 1; how much of the map's highlight blow-out to keep
  float tone_map_hue_shift;  // 0..1, default 1; how much of the map's hue rotation to keep
  float color_grade_lut_strength;          // 0..1, default 1
  float custom_lut_tetrahedral;            // 0 = Trilinear (vanilla), 1 = Tetrahedral
  float color_grade_exposure;              // default 1
  float color_grade_highlights;            // default 1
  float color_grade_shadows;               // default 1
  float color_grade_contrast;              // default 1
  float color_grade_saturation;            // default 1
  float color_grade_dechroma;              // 0..1, default 0; luminance-keyed chroma fade
  float color_grade_flare;                 // default 0
  float color_grade_highlight_saturation;  // default 1; inverted into the grade's blowout
  float fx_vignette;                       // 0..1, default 1; scales the vanilla vignette mask
  float fx_bloom;                          // 0..1, default 1; scales the vanilla bloom
  float fx_light_shaft;                    // 0..1, default 1; scales the vanilla light shafts
  float fx_flare;                          // 0..1, default 1; scales the vanilla lens flare
  float custom_video_active;               // 1 while an FMV decodes this frame; set by the decode pass
};

#ifndef __cplusplus
cbuffer shader_injection : register(b0, space50) {
  ShaderInjectData injectedData : packoffset(c0);
}

#include "../../shaders/renodx.hlsl"
#endif

#endif  // SRC_GAMES_HORIZONZERODAWNCE_SHARED_H_
