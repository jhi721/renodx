#ifndef SRC_GAMES_HORIZONZERODAWNCE_COMMON_HLSL_
#define SRC_GAMES_HORIZONZERODAWNCE_COMMON_HLSL_

#include "./shared.h"
#include "./psycho_test24.hlsli"

// Color pipeline shared by every replaced pass: the invertible max-channel LUT bridge and
// per-channel display map the scene composite runs, the HDR10 encode they all end on, and the
// native expansion the FMV decode keeps.
//
// The game's own luma weights, not Rec.709 - the FMV decode is the one exception.
static const float3 DECIMA_LUMA = float3(0.3086000084877014f, 0.6093999743461609f, 0.0820000022649765f);

float LumaDecima(float3 color) {
  return dot(color, DECIMA_LUMA);
}

// The game's exact Decima literals, used by ApplyVanillaOutput on the SDR path.
float EncodeSRGBChannel(float color) {
  return color < 0.003100000089034438f
             ? color * 12.920000076293945f
             : pow(color, 0.4166666567325592f) * 1.0549999475479126f - 0.054999999701976776f;
}

float3 EncodeSRGB(float3 color) {
  return float3(EncodeSRGBChannel(color.r), EncodeSRGBChannel(color.g), EncodeSRGBChannel(color.b));
}

float3 EncodePQ(float3 color) {
  color = max(0.f, color);
  float3 y_m1 = pow(color, 0.1593017578125f);
  return pow(((y_m1 * 18.8515625f) + 0.8359375f) / ((y_m1 * 18.6875f) + 1.f), 78.84375f);
}

float Highlights(float x, float highlights, float mid_gray) {
  if (highlights == 1.f) return x;

  if (highlights > 1.f) {
    return max(x, lerp(x, mid_gray * pow(x / mid_gray, highlights), min(x, 1.f)));
  } else {  // highlights < 1.f
    x /= mid_gray;
    return lerp(x, pow(x, highlights), step(1.f, x)) * mid_gray;
  }
}

float Shadows(float x, float shadows, float mid_gray) {
  if (shadows == 1.f) return x;

  const float ratio = max(renodx::math::DivideSafe(x, mid_gray, 0.f), 0.f);
  const float base_term = x * mid_gray;
  const float base_scale = renodx::math::DivideSafe(base_term, ratio, 0.f);

  if (shadows > 1.f) {
    float raised = x * (1.f + renodx::math::DivideSafe(base_term, pow(ratio, shadows), 0.f));
    float reference = x * (1.f + base_scale);
    return max(x, x + (raised - reference));
  } else {  // shadows < 1.f
    float lowered = x * (1.f - renodx::math::DivideSafe(base_term, pow(ratio, 2.f - shadows), 0.f));
    float reference = x * (1.f - base_scale);
    return clamp(x + (lowered - reference), 0.f, x);
  }
}

// Luminance-domain exposure / contrast / flare / highlights / shadows.
float3 ApplyExposureContrastFlareHighlightsShadowsByLuminance(float3 untonemapped, float y, renodx::color::grade::Config config, float mid_gray = 0.18f) {
  if (config.exposure == 1.f && config.shadows == 1.f && config.highlights == 1.f && config.contrast == 1.f && config.flare == 0.f) {
    return untonemapped;
  }
  float3 color = untonemapped;

  color *= config.exposure;

  const float y_normalized = y / mid_gray;
  float flare = renodx::math::DivideSafe(y_normalized + config.flare, y_normalized, 1.f);
  float exponent = config.contrast * flare;
  const float y_contrasted = pow(y_normalized, exponent) * mid_gray;

  float y_highlighted = Highlights(y_contrasted, config.highlights, mid_gray);
  float y_shadowed = Shadows(y_highlighted, config.shadows, mid_gray);

  color = renodx::color::correct::Luminance(color, y, y_shadowed);

  return color;
}

// Saturation / Dechroma / Highlight Saturation.
float3 ApplySaturationBlowoutHighlightSaturation(float3 tonemapped, float y, renodx::color::grade::Config config) {
  float3 color = tonemapped;
  if (config.saturation != 1.f || config.dechroma != 0.f || config.blowout != 0.f) {
    float3 perceptual_new = renodx::color::oklab::from::BT709(color);

    if (config.dechroma != 0.f) {
      perceptual_new.yz *= lerp(1.f, 0.f, saturate(pow(y / (10000.f / 100.f), (1.f - config.dechroma))));
    }

    if (config.blowout != 0.f) {
      float percent_max = saturate(y * 100.f / 10000.f);
      // positive = 1 to 0, negative = 1 to 2
      float blowout_strength = 100.f;
      float blowout_change = pow(1.f - percent_max, blowout_strength * abs(config.blowout));
      if (config.blowout < 0) {
        blowout_change = (2.f - blowout_change);
      }

      perceptual_new.yz *= blowout_change;
    }

    perceptual_new.yz *= config.saturation;

    color = renodx::color::bt709::from::OkLab(perceptual_new);

    color = renodx::color::bt709::clamp::AP1(color);
  }
  return color;
}

// Grade in two halves so Highlight Saturation can key off the luminance the first half measured.
float3 ApplyRenoDXGrade(float3 color) {
  renodx::color::grade::Config cg = renodx::color::grade::config::Create();
  cg.exposure = injectedData.color_grade_exposure;
  cg.highlights = injectedData.color_grade_highlights;
  cg.shadows = injectedData.color_grade_shadows;
  cg.contrast = injectedData.color_grade_contrast;
  cg.flare = injectedData.color_grade_flare;
  cg.saturation = injectedData.color_grade_saturation;
  cg.dechroma = injectedData.color_grade_dechroma;
  // Highlight Saturation is centered at 1.0 and drives the luminance-keyed blowout slot negative.
  cg.blowout = -1.f * (injectedData.color_grade_highlight_saturation - 1.f);

  const float y = renodx::color::y::from::BT709(color);
  color = ApplyExposureContrastFlareHighlightsShadowsByLuminance(color, y, cg);
  return ApplySaturationBlowoutHighlightSaturation(color, y, cg);
}

// The exponent behind each Gamma Correction setting.
float GammaCorrectionExponent() {
  if (injectedData.gamma_correction == HZD_GAMMA_CORRECTION_2_2) return 2.2f;
  if (injectedData.gamma_correction == HZD_GAMMA_CORRECTION_BT1886) return 2.4f;
  return 0.f;  // Off
}

// Emulates the per-channel display EOTF used by the game's own encode.
float3 ApplyEotfEmulation(float3 color) {
  const float gamma = GammaCorrectionExponent();
  if (gamma == 0.f) return color;

  return renodx::color::correct::GammaSafe(color, false, gamma);
}

// Display headroom over Game Brightness, and the output ceiling.
float PeakRatio() {
  return injectedData.peak_white_nits / max(injectedData.diffuse_white_nits, 1.f);
}

// PeakRatio in the pre-gamma domain. The native FMV expansion and PsychoV cap on this one, and the
// forward gamma on their output lands highlights back on PeakRatio.
float InternalPeakRatio() {
  const float gamma = GammaCorrectionExponent();
  if (gamma == 0.f) return PeakRatio();
  return renodx::color::correct::GammaSafe(PeakRatio(), true, gamma);
}

// The game's own tone curve is exponential: the vanilla scene compose compresses with
// 1 - exp(-color / s), written as exp2(x * -1/ln2) in 0xB444C8F0. Reused here as the display map,
// 1:1 up to paper white and rolling from there into the peak.
//
// The shoulder is held under the cap because PeakRatio can be below 1 - a peak dimmer than Game
// Brightness is a valid setting - and LuminanceCompress returns anything at or below the shoulder
// untouched, which would leave an identity band above the ceiling.
float3 ExponentialDisplayMap(float3 color, float cap) {
  const float shoulder = min(1.f, cap * 0.75f);
  return float3(
      renodx::tonemap::dice::internal::LuminanceCompress(color.r, cap, shoulder),
      renodx::tonemap::dice::internal::LuminanceCompress(color.g, cap, shoulder),
      renodx::tonemap::dice::internal::LuminanceCompress(color.b, cap, shoulder));
}

// The add-on's only display map and HDR10 encode. Every replaced pass ends here: scene composite,
// the menu/FMV/loading encoder, and - through that encoder - the FMV decode.
//
// Input is scene-relative linear BT.709 where 1.0 is Game Brightness, already graded and
// EOTF-emulated. The scene is mapped per channel; menus and FMV arrive display-mapped already and
// only need the peak clamp.
float3 FinalizeOutput(float3 color, bool apply_display_map = false) {
  color = max(0.f, color);
  const float3 source_bt709 = color;

  if (apply_display_map) {
    color = ExponentialDisplayMap(color, PeakRatio());
  }

  color = renodx::color::bt2020::from::BT709(color);

  if (apply_display_map
      && (injectedData.tone_map_hue_shift != 1.f || injectedData.tone_map_blowout != 1.f)) {
    const float3 mb_source = renodx::color::macleod_boynton::from::BT709(source_bt709);
    const float3 mb_mapped = renodx::color::macleod_boynton::from::BT2020(color);
    const float2 white = renodx::color::macleod_boynton::from::D65XY();

    const float2 dir_source = mb_source.xy - white;
    const float2 dir_mapped = mb_mapped.xy - white;
    const float len_source = length(dir_source);
    const float len_mapped = length(dir_mapped);

    // Neutral in either frame: no direction to steer and no purity to restore.
    if (len_source > 1e-6f && len_mapped > 1e-6f) {
      // Hue Shift only turns the vector - both terms carry the mapped purity.
      const float2 dir = lerp(
          dir_source * (len_mapped / len_source), dir_mapped, injectedData.tone_map_hue_shift);
      const float len_dir = length(dir);
      // Blowout picks the purity: 1 keeps what the map produced, 0 puts the source's back.
      const float len_final = lerp(len_source, len_mapped, injectedData.tone_map_blowout);

      if (len_dir > 1e-6f) {
        // Purity restored at the mapped luminance can leave a channel negative; the ceiling is
        // held by the clamp below.
        color = max(0.f, renodx::color::bt2020::from::MacLeodBoynton(
                             white + dir * (len_final / len_dir), mb_mapped.z));
      }
    }
  }

  color = min(color, PeakRatio());

  // scaling carries Game Brightness: Encode multiplies by scaling/10000 internally.
  return renodx::color::pq::EncodeSafe(color, injectedData.diffuse_white_nits);
}

float3 ApplyRenoDXStandardOutput(float3 color, bool apply_display_map = false, bool apply_grade = true) {
  if (apply_grade) color = ApplyRenoDXGrade(color);
  color = ApplyEotfEmulation(color);
  return FinalizeOutput(color, apply_display_map);
}

// PsychoV replaces both the user grade and the display map: test24 applies exposure, highlights,
// shadows, contrast and purity itself, then compresses to peak in cone space.
float3 ApplyPsychoVOutput(float3 color) {
  color = renodx_custom::tonemap::psychov::psychotm_test24(
      color, InternalPeakRatio(),
      injectedData.color_grade_exposure,
      injectedData.color_grade_highlights,
      injectedData.color_grade_shadows,
      injectedData.color_grade_contrast,
      injectedData.color_grade_saturation,  // purity_scale; test24 divides it by contrast
      1.f, 100.f, 1.f,                      // bleaching / clip / hue_restore - unread
      1.f,                                  // adaptation_contrast
      0,                                    // white_curve_mode - unread
      1.f,                                  // cone_response_exponent
      0.18f.xxx, 0.18f.xxx,                 // adaptive and background state at mid grey
      1.f,                                  // gamut_compression, always full
      1,                                    // gamut bound = BT.2020, matches the output
      1.f,                                  // adaptive_normalization - unread
      0.f,                                  // compression = auto
      1.f,                                  // highlight_saturation - unread
      0.f);                                 // gamut_hue_restore off

  return FinalizeOutput(ApplyEotfEmulation(color), false);
}

struct NativeExpansionLuma {
  float source;  // Input luma, clamped to 0..1
  float mapped;  // After the expansion, clamped to the cap
  float cap;     // Ceiling in the pre-gamma domain
};

// The game's native highlight expansion, normalized from its fixed x20 output scale to the selected
// Peak / Game Brightness ratio. Calibration fades from identity at cap = 1 to the exact native curve
// at cap = 20, retaining its midtone dip without adding low-headroom dimming. Above cap = 20 the
// native result scales into the additional headroom.
NativeExpansionLuma EvaluateNativeExpansionLuma(float source_luma, float highlight_weight) {
  NativeExpansionLuma result;
  result.source = saturate(source_luma);
  result.cap = InternalPeakRatio();

  const float shoulder =
      (log2(1.f - (result.source * 0.9816843271255493f)) * -0.6931471824645996f)
      / (result.source + 0.000009999999747378752f);
  const float weight = saturate(highlight_weight);
  const float smooth_weight = weight * weight * (3.f - (weight * 2.f));
  const float native_peak = (weight * 24.f) + 1.f;
  const float expansion = (smooth_weight * (native_peak - shoulder)) + shoulder;
  const float expansion_scaled = expansion * 0.04f;
  const float expansion_curve = 1.f + ((1.f - expansion_scaled) * expansion_scaled);
  const float native_mapped = result.source * expansion_scaled * expansion_curve * 20.f;

  float mapped;
  if (result.cap <= 20.f) {
    const float headroom_weight = saturate((result.cap - 1.f) / 19.f);
    mapped = lerp(result.source, native_mapped, headroom_weight);
  } else {
    mapped = native_mapped * (result.cap / 20.f);
  }

  result.mapped = min(mapped, result.cap);
  return result;
}

float3 ApplyCalibratedNativeExpansion(
    float3 color,
    float source_luma,
    float highlight_weight,
    float expansion_strength) {
  const NativeExpansionLuma expansion =
      EvaluateNativeExpansionLuma(source_luma, highlight_weight);
  if (expansion.source <= 0.f) return color;

  const float mapped = lerp(
      expansion.source,
      expansion.mapped,
      saturate(expansion_strength));
  return color * (mapped / expansion.source);
}

// Samples the game's grade LUT. Its domain is the compressor's own output, so the coordinate is
// scaled and biased with no encode, and the vanilla LOD comes from the blue axis.
float3 SampleHzdLut(Texture3D<float4> lut, SamplerState samp,
                    float3 sdr_color, float lut_scale, float lut_bias) {
  const float3 coord = sdr_color * lut_scale + lut_bias;
  if (injectedData.custom_lut_tetrahedral != 0.f) {
    return renodx::lut::SampleTetrahedral(lut, sdr_color, 0.f).rgb;
  }
  return lut.SampleLevel(samp, coord, coord.z).rgb;
}

struct SceneBridge {
  float3 sdr;  // Scene in the LUT's SDR domain, light shafts blended in as the game blends them
  float scale;  // The max-channel scale that produced it; 1/scale is the compressed headroom
};

// Compresses the linear BT.709 scene into the LUT's SDR domain by one max-channel scale.
SceneBridge BridgeSceneToSdr(float3 pre_compressor, float3 light_shaft_term) {
  pre_compressor = max(pre_compressor, 0.f);

  SceneBridge bridge;
  bridge.scale = renodx::tonemap::neutwo::ComputeMaxChannelScale(pre_compressor);
  bridge.sdr = saturate(
      1.f - saturate(1.f - light_shaft_term) * saturate(1.f - (pre_compressor * bridge.scale)));
  return bridge;
}

// Divides the bridge's own scale back out and display-maps the result exactly once, either by
// FinalizeOutput's per-channel branch or by test24. An identity grade returns the input unchanged.
float3 ApplyRenoDXSceneOutput(SceneBridge bridge, float3 graded_sdr) {
  const float3 graded_hdr = renodx::math::DivideSafe(graded_sdr, bridge.scale.xxx, graded_sdr);

  if (injectedData.tone_map_type == HZD_TONE_MAP_TYPE_PSYCHOV) {
    return ApplyPsychoVOutput(graded_hdr);
  }
  return ApplyRenoDXStandardOutput(graded_hdr, true);
}

// Menus, loading screens and video reach the output encoder already display-mapped - by the game for
// UI, by the intercepted FMV decode for video - so they take the clamp-only path. Video keeps its
// authored color and skips the user grade.
float3 ApplyEncodeOnlyOutput(float3 color) {
  return ApplyRenoDXStandardOutput(color, false, injectedData.custom_video_active == 0.f);
}

// Faithful Decima OETF output. output_mode = int(oetf3.x):
//   1 = sRGB (SDR), 2 = BT.2020 + PQ (native HDR10), else = matrix + gamma.
float3 ApplyVanillaOutput(float3 color, float4 oetf0, float4 oetf1, float4 oetf2, float4 oetf3) {
  const int output_mode = int(oetf3.x);

  if (output_mode == 1) {
    color = pow(color, oetf0.x);
    return EncodeSRGB(color);
  }

  if (output_mode == 2) {
    float3 bt2020 = float3(
        mad(0.04331306740641594f, color.z, mad(0.3292830288410187f, color.y, color.x * 0.6274039149284363f)),
        mad(0.011362316086888313f, color.z, mad(0.9195404052734375f, color.y, color.x * 0.06909728795289993f)),
        mad(0.8955952525138855f, color.z, mad(0.08801330626010895f, color.y, color.x * 0.016391439363360405f)));

    return EncodePQ(pow(bt2020 * oetf1.x, oetf0.x));
  }

  float3 transformed = float3(
      mad(oetf2.y, color.z, mad(oetf1.y, color.y, color.x * oetf0.y)),
      mad(oetf2.z, color.z, mad(oetf1.z, color.y, color.x * oetf0.z)),
      mad(oetf2.w, color.z, mad(oetf1.w, color.y, color.x * oetf0.w)));

  return pow(max(transformed, 0.f), oetf0.x);
}

#endif  // SRC_GAMES_HORIZONZERODAWNCE_COMMON_HLSL_
