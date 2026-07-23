#ifndef SRC_GAMES_HORIZONZERODAWNCE_SHARED_H_
#define SRC_GAMES_HORIZONZERODAWNCE_SHARED_H_

// Must be 32-bit aligned.
struct ShaderInjectData {
  float tone_map_type;  // 0 = Vanilla, 1 = Vanilla+, 2 = Vanilla+ (Customized), 3 = Vanilla+ (PsychoV-24)
  float peak_white_nits;
  float diffuse_white_nits;
  float gamma_correction;  // 0 = Off, 1 = 2.2, 2 = BT.1886
  float color_grade_lut_strength;  // 0..1, default 1
  float color_grade_exposure;      // default 1
  float color_grade_highlights;    // default 1
  float color_grade_shadows;       // default 1
  float color_grade_contrast;      // default 1
  float color_grade_saturation;    // default 1
  float color_grade_dechroma;      // default 0; extra highlight desaturation (grade config dechroma slot)
  float fx_vignette;               // default 1
  float fx_bloom;                  // default 1
  float fx_light_shaft;            // default 1
  float fx_flare;                  // default 1
  float color_grade_flare;                 // default 0
  float color_grade_highlight_saturation;  // default 1; drives the grade blowout slot (-(hs-1)) in ApplyRenoDXGrade
  float custom_lut_tetrahedral;            // 0 = Trilinear (vanilla), 1 = Tetrahedral
  float custom_video_active;               // set by the FMV decode callback for the current frame; the menu/output pass skips the highlight emulation while a video plays
};

#ifndef __cplusplus
cbuffer shader_injection : register(b0, space50) {
  ShaderInjectData injectedData : packoffset(c0);
}

#define HZD_TONE_MAP_TYPE_VANILLA 0.f
#define HZD_TONE_MAP_TYPE_VANILLA_PLUS 1.f
#define HZD_TONE_MAP_TYPE_CUSTOMIZED 2.f
#define HZD_TONE_MAP_TYPE_VANILLA_PLUS_PSYCHOV 3.f

#include "../../shaders/renodx.hlsl"
#endif

#endif  // SRC_GAMES_HORIZONZERODAWNCE_SHARED_H_
