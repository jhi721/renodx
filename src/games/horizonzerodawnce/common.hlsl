#ifndef SRC_GAMES_HORIZONZERODAWNCE_COMMON_HLSL_
#define SRC_GAMES_HORIZONZERODAWNCE_COMMON_HLSL_

#include "./shared.h"
#include "./psycho_test24.hlsli"

// Shared output-transform helpers for the Decima final passes. Both the scene composite
// (0xB444C8F0) and the standalone menu/video output (0x29103068) end in the SAME OETF
// transform and, in non-Vanilla modes, the SAME RenoDX HDR encode — kept here so the two shaders
// cannot drift.

// The game's own luma weights - not Rec.709 (the FMV decode pass is the one exception).
static const float3 DECIMA_LUMA = float3(0.3086000084877014f, 0.6093999743461609f, 0.0820000022649765f);

float LumaDecima(float3 color) {
  return dot(color, DECIMA_LUMA);
}

// Local encoders duplicate renodx::color::{srgb,pq} on purpose: they carry the game's exact
// Decima literals for the bit-exact ApplyVanillaOutput path; the non-Vanilla path uses
// renodx::color::pq::EncodeSafe instead.
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

// Luminance-domain exposure / contrast / flare / highlights / shadows. Split from the saturation
// half so the color half below can take an explicit per-channel reference.
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

// Saturation / Dechroma / Highlight Saturation. The generic hue-correction and chrominance-emulation
// slots are still present in this helper, but this add-on keeps them disabled; adaptive highlight
// hue/blow emulation is applied after the display map instead.
float3 ApplySaturationBlowoutHueCorrectionHighlightSaturation(float3 tonemapped, float3 untonemapped, float y, renodx::color::grade::Config config, float chrominance_emulation = 0.f) {
  float3 color = tonemapped;
  if (config.saturation != 1.f || config.dechroma != 0.f || config.hue_correction_strength != 0.f || config.blowout != 0.f || chrominance_emulation != 0.f) {
    float3 perceptual_new = renodx::color::oklab::from::BT709(color);

    if (config.hue_correction_strength != 0.0 || chrominance_emulation != 0.0) {
      const float3 reference_oklab = renodx::color::oklab::from::BT709(untonemapped);

      float chrominance_current = length(perceptual_new.yz);
      float chrominance_ratio = 1.0;

      if (config.hue_correction_strength != 0.0) {
        const float chrominance_pre = chrominance_current;
        perceptual_new.yz = lerp(perceptual_new.yz, reference_oklab.yz, config.hue_correction_strength);
        const float chrominancePost = length(perceptual_new.yz);
        chrominance_ratio = renodx::math::SafeDivision(chrominance_pre, chrominancePost, 1);
        chrominance_current = chrominancePost;
      }

      if (chrominance_emulation != 0.0) {
        const float reference_chrominance = length(reference_oklab.yz);
        float target_chrominance_ratio = renodx::math::SafeDivision(reference_chrominance, chrominance_current, 1);
        chrominance_ratio = lerp(chrominance_ratio, target_chrominance_ratio, chrominance_emulation);
      }
      perceptual_new.yz *= chrominance_ratio;
    }

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

// Grade in two halves so Highlight Saturation can key off luminance. The per-channel highlight
// hue-shift + blowout emulation lives on the Customized scene bridge, NOT here - so this stage
// never pulls hue/chrominance toward a reference (hue_correction_strength /
// chrominance_emulation stay 0). Only Exposure/Highlights/Shadows/Contrast/Flare (luminance)
// + Saturation/Dechroma/Highlight Saturation (chroma) run here.
float3 ApplyRenoDXGrade(float3 color) {
  // PsychoV (mode 3) tone-maps in its own perceptual pipeline: Saturation rides its purity_scale
  // (kept out of the grade here so it survives the chroma compression).
  const bool psychov = injectedData.tone_map_type == HZD_TONE_MAP_TYPE_VANILLA_PLUS_PSYCHOV;

  renodx::color::grade::Config cg = renodx::color::grade::config::Create();
  cg.exposure = injectedData.color_grade_exposure;
  cg.highlights = injectedData.color_grade_highlights;
  cg.shadows = injectedData.color_grade_shadows;
  cg.contrast = injectedData.color_grade_contrast;
  cg.flare = injectedData.color_grade_flare;
  cg.saturation = psychov ? 1.f : injectedData.color_grade_saturation;
  cg.dechroma = injectedData.color_grade_dechroma;
  cg.hue_correction_strength = 0.f;
  // Highlight Saturation is centered at 1.0 and drives the luminance-keyed blowout slot negative.
  cg.blowout = -1.f * (injectedData.color_grade_highlight_saturation - 1.f);

  const float y = renodx::color::y::from::BT709(color);
  color = ApplyExposureContrastFlareHighlightsShadowsByLuminance(color, y, cg);
  // No reference pull here (hue/chrominance emulation off); pass color as the unused reference.
  color = ApplySaturationBlowoutHueCorrectionHighlightSaturation(color, color, y, cg, 0.f);
  return color;
}

float3 ApplyEotfEmulation(float3 color) {
  if (injectedData.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    color = renodx::color::correct::GammaSafe(color, false, 2.2f);
  } else if (injectedData.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    color = renodx::color::correct::GammaSafe(color, false, 2.4f);
  }
  return color;
}

float PeakRatio() {
  return max(injectedData.peak_white_nits / max(injectedData.diffuse_white_nits, 1.f), 1.001f);
}

// Native expansion runs before EOTF emulation. Move the selected display peak into
// that internal domain so ApplyEotfEmulation maps the ceiling back to PeakRatio().
float NativeExpansionCap() {
  float cap = PeakRatio();
  if (injectedData.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    cap = renodx::color::correct::GammaSafe(cap, true, 2.2f);
  } else if (injectedData.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    cap = renodx::color::correct::GammaSafe(cap, true, 2.4f);
  }
  return cap;
}

struct NativeExpansionLuma {
  float source;
  float mapped;
  float cap;
};

// HZDCE native highlight expansion, normalized from its fixed x20 output scale to
// the selected Peak/Game ratio. At cap=20 with gamma correction off this is the
// original curve. The low-headroom guard prevents the recalibration from dimming.
NativeExpansionLuma EvaluateNativeExpansionLuma(float source_luma, float highlight_weight) {
  NativeExpansionLuma result;
  result.source = saturate(source_luma);
  result.cap = NativeExpansionCap();

  const float shoulder =
      (log2(1.f - (result.source * 0.9816843271255493f)) * -0.6931471824645996f)
      / (result.source + 0.000009999999747378752f);
  const float weight = saturate(highlight_weight);
  const float smooth_weight = weight * weight * (3.f - (weight * 2.f));
  const float native_peak = (weight * 24.f) + 1.f;
  const float expansion = (smooth_weight * (native_peak - shoulder)) + shoulder;
  const float expansion_scaled = expansion * 0.04f;
  const float expansion_curve = 1.f + ((1.f - expansion_scaled) * expansion_scaled);
  const float mapped = result.source * expansion_scaled * expansion_curve * result.cap;

  result.mapped = clamp(mapped, result.source, result.cap);
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

float3 ApplyPeakSafetyCap(float3 color) {
  const float peak_ratio = PeakRatio();
  const float peak_channel = renodx::math::Max(color);
  if (peak_channel > peak_ratio) color *= peak_ratio / peak_channel;
  return color;
}

float3 EncodeRenoDXHDR10(float3 color) {
  const float3 scene_nits = max(0.f, color) * max(injectedData.diffuse_white_nits, 1.f);
  return renodx::color::pq::EncodeSafe(
      renodx::color::bt2020::from::BT709(scene_nits),
      1.f);
}

// Standard Vanilla+ output: optional user grading, corrected EOTF emulation,
// a hue-preserving peak ceiling, and fixed PQ.
float3 ApplyRenoDXStandardOutput(float3 color, bool apply_grade) {
  if (apply_grade) color = ApplyRenoDXGrade(color);
  color = ApplyEotfEmulation(color);
  return EncodeRenoDXHDR10(ApplyPeakSafetyCap(color));
}

// PsychoV23-style signed-opponent retention for adaptive highlight hue/blow emulation. white_progress
// is derived from the ACTUAL display-map output in the auto-compression power domain, so the emulation
// strengthens as the configured peak drops and needs no per-game hand tuning.

static const float PSYCHO23_LOCAL_EPSILON = 1e-6f;
static const float PSYCHO23_LOCAL_REFERENCE_SIMULTANEOUS_RANGE_LOG10 = 3.7f;
static const float PSYCHO23_LOCAL_REFERENCE_CENTERED_RANGE_SIDE_COUNT = 2.f;
static const float PSYCHO23_LOCAL_HEADROOM_RATIO_FALLBACK = 1.f;
static const float PSYCHO23_LOCAL_MIN_AUTO_COMPRESSION = 1.f;

// Empirical signed-opponent appearance controls from PsychoV23.
static const float PSYCHO23_LOCAL_RED_RETENTION = 1.5f;
static const float PSYCHO23_LOCAL_GREEN_RETENTION = 2.f;
static const float PSYCHO23_LOCAL_BLUE_RETENTION = 1.f;
static const float PSYCHO23_LOCAL_YELLOW_RETENTION = 3.f;

float Psycho23YfFromLMS(float3 lms) {
  float3 weighted_lms = renodx::color::macleod_boynton::WeighLMS(lms);
  return max(weighted_lms.x + weighted_lms.y, PSYCHO23_LOCAL_EPSILON);
}

float Psycho23AutoCompressionFromCenteredReferenceRange(float anchor_out_yf, float peak_yf) {
  float peak_over_anchor = renodx::math::DivideSafe(
      max(peak_yf, PSYCHO23_LOCAL_EPSILON),
      max(anchor_out_yf, PSYCHO23_LOCAL_EPSILON),
      PSYCHO23_LOCAL_HEADROOM_RATIO_FALLBACK);
  peak_over_anchor = max(peak_over_anchor, 1.f + PSYCHO23_LOCAL_EPSILON);

  float reference_one_side_range_log10 =
      PSYCHO23_LOCAL_REFERENCE_SIMULTANEOUS_RANGE_LOG10
      / PSYCHO23_LOCAL_REFERENCE_CENTERED_RANGE_SIDE_COUNT;
  float actual_above_adaptation_range_log10 =
      max(log10(peak_over_anchor), PSYCHO23_LOCAL_EPSILON);

  return max(
      reference_one_side_range_log10 / actual_above_adaptation_range_log10,
      PSYCHO23_LOCAL_MIN_AUTO_COMPRESSION);
}

float3 Psycho23ToAdaptiveRelativeWeightedLMS(
    float3 lms_input,
    float3 current_adaptive_state_lms) {
  return renodx::math::DivideSafe(
      renodx::color::macleod_boynton::WeighLMS(lms_input),
      current_adaptive_state_lms,
      0.f.xxx);
}

float3 Psycho23FromAdaptiveRelativeWeightedLMS(
    float3 lms_weighted_relative,
    float3 current_adaptive_state_lms) {
  return lms_weighted_relative * max(current_adaptive_state_lms, 1e-6f.xxx);
}

float3 Psycho23GamutCompressAdaptiveRelativeWeightedLMSBound(
    float3 lms_weighted_relative_input,
    float3 current_adaptive_state_lms,
    float3x3 bound_rgb_to_lms_weighted_mat,
    float strength) {
  return renodx::color::gamut::GamutCompressWeightedLMSCoreRGBBoundFromAdaptiveWeightedInput(
      lms_weighted_relative_input,
      current_adaptive_state_lms,
      bound_rgb_to_lms_weighted_mat,
      strength);
}

float3 Psycho23AdaptiveRelativeWeightedNeutral() {
  return renodx::color::macleod_boynton::WeighLMS(1.f.xxx);
}

float3 Psycho23OpponentACCFromWeightedDelta(float3 delta_weighted_lms) {
  float3 neutral_weighted = Psycho23AdaptiveRelativeWeightedNeutral();
  float m_to_l = renodx::math::DivideSafe(
      neutral_weighted.x,
      neutral_weighted.y,
      0.f);
  float s_to_lm = renodx::math::DivideSafe(
      neutral_weighted.x + neutral_weighted.y,
      neutral_weighted.z,
      0.f);

  return float3(
      delta_weighted_lms.x + delta_weighted_lms.y,
      delta_weighted_lms.x - m_to_l * delta_weighted_lms.y,
      -delta_weighted_lms.x - delta_weighted_lms.y
          + s_to_lm * delta_weighted_lms.z);
}

float3 Psycho23WeightedDeltaFromOpponentACC(float3 acc) {
  float3 neutral_weighted = Psycho23AdaptiveRelativeWeightedNeutral();
  float m_to_l = renodx::math::DivideSafe(
      neutral_weighted.x,
      neutral_weighted.y,
      0.f);
  float s_to_lm = renodx::math::DivideSafe(
      neutral_weighted.x + neutral_weighted.y,
      neutral_weighted.z,
      0.f);

  float delta_m = renodx::math::DivideSafe(acc.x - acc.y, 1.f + m_to_l, 0.f);
  float delta_l = acc.x - delta_m;
  float delta_s = renodx::math::DivideSafe(acc.z + acc.x, s_to_lm, 0.f);
  return float3(delta_l, delta_m, delta_s);
}

float Psycho23SignedOpponentRetention(float white_progress, float retention_exponent) {
  return 1.f - pow(saturate(white_progress), max(retention_exponent, PSYCHO23_LOCAL_EPSILON));
}

float3 Psycho23ApplySignedOpponentRetention(
    float3 compressed_lms,
    float3 source_lms,
    float3 adaptive_state_lms,
    float3 peak_lms,
    float white_progress) {
  if (white_progress <= 0.f
      || min(source_lms.x, min(source_lms.y, source_lms.z)) <= 0.f) {
    return compressed_lms;
  }

  float3 source_weighted = Psycho23ToAdaptiveRelativeWeightedLMS(
      source_lms,
      adaptive_state_lms);
  float3 adapted_neutral = Psycho23AdaptiveRelativeWeightedNeutral();
  float adapted_neutral_yf = adapted_neutral.x + adapted_neutral.y;
  float source_yf = source_weighted.x + source_weighted.y;

  if (source_yf <= PSYCHO23_LOCAL_EPSILON
      || adapted_neutral_yf <= PSYCHO23_LOCAL_EPSILON) {
    return compressed_lms;
  }

  float3 source_neutral = adapted_neutral
                          * renodx::math::DivideSafe(source_yf, adapted_neutral_yf, 1.f);
  float3 source_acc =
      Psycho23OpponentACCFromWeightedDelta(source_weighted - source_neutral)
      / source_yf;

  float red_retention = Psycho23SignedOpponentRetention(
      white_progress,
      PSYCHO23_LOCAL_RED_RETENTION);
  float green_retention = Psycho23SignedOpponentRetention(
      white_progress,
      PSYCHO23_LOCAL_GREEN_RETENTION);
  float blue_retention = Psycho23SignedOpponentRetention(
      white_progress,
      PSYCHO23_LOCAL_BLUE_RETENTION);
  float yellow_retention = Psycho23SignedOpponentRetention(
      white_progress,
      PSYCHO23_LOCAL_YELLOW_RETENTION);

  float rg_out = max(source_acc.y, 0.f) * red_retention
                 - max(-source_acc.y, 0.f) * green_retention;
  float yv_out = max(source_acc.z, 0.f) * blue_retention
                 - max(-source_acc.z, 0.f) * yellow_retention;

  float3 compressed_weighted = Psycho23ToAdaptiveRelativeWeightedLMS(
      compressed_lms,
      adaptive_state_lms);
  float target_yf = compressed_weighted.x + compressed_weighted.y;
  if (target_yf <= PSYCHO23_LOCAL_EPSILON) {
    return compressed_lms;
  }

  float3 peak_weighted = Psycho23ToAdaptiveRelativeWeightedLMS(
      peak_lms,
      adaptive_state_lms);
  float peak_weighted_yf = peak_weighted.x + peak_weighted.y;
  if (peak_weighted_yf <= PSYCHO23_LOCAL_EPSILON) {
    return compressed_lms;
  }

  float3 target_neutral = peak_weighted * renodx::math::DivideSafe(target_yf, peak_weighted_yf, 1.f);
  float3 target_delta = Psycho23WeightedDeltaFromOpponentACC(
      float3(0.f, rg_out * target_yf, yv_out * target_yf));
  float3 output_lms = renodx::color::macleod_boynton::UnweighLMS(
      Psycho23FromAdaptiveRelativeWeightedLMS(
          target_neutral + target_delta,
          adaptive_state_lms));

  float compressed_yf = Psycho23YfFromLMS(compressed_lms);
  float output_yf = Psycho23YfFromLMS(output_lms);
  if (output_yf <= PSYCHO23_LOCAL_EPSILON) {
    return compressed_lms;
  }

  return output_lms * renodx::math::DivideSafe(compressed_yf, output_yf, 1.f);
}

float3 ApplyPsycho23SignedOpponentRetentionAndGamutCompressionLMS(
    float3 precompression_lms,
    float3 compressed_lms,
    float3 input_adaptive_state_lms,
    float3 output_anchor_lms,
    float3 peak_white_lms,
    float3x3 gamut_bound_rgb_to_lms_weighted_mat,
    float hue_restore = 1.f,
    float gamut_compression = 1.f) {
  float anchor_yf = Psycho23YfFromLMS(output_anchor_lms);
  float peak_yf = Psycho23YfFromLMS(peak_white_lms);
  float output_yf = Psycho23YfFromLMS(compressed_lms);

  // Test23 measures white convergence in the compression power domain. Derive
  // the same progress from the actual display-map output instead of assuming its
  // shoulder follows PsychoV's analytic compression curve.
  float compression_power = Psycho23AutoCompressionFromCenteredReferenceRange(
      anchor_yf,
      peak_yf);
  float anchor_over_peak = saturate(renodx::math::DivideSafe(anchor_yf, peak_yf, 1.f));
  float output_over_peak = max(renodx::math::DivideSafe(output_yf, peak_yf, 0.f), 0.f);
  float anchor_powered = pow(max(anchor_over_peak, 1e-6f), compression_power);
  float white_progress = saturate(renodx::math::DivideSafe(
      pow(output_over_peak, compression_power) - anchor_powered,
      1.f - anchor_powered,
      0.f));

  float3 opponent_retained_lms = Psycho23ApplySignedOpponentRetention(
      compressed_lms,
      precompression_lms,
      input_adaptive_state_lms,
      peak_white_lms,
      white_progress);
  float3 hue_restored_lms = lerp(
      compressed_lms,
      opponent_retained_lms,
      saturate(hue_restore));

  float3 display_relative_weighted = Psycho23ToAdaptiveRelativeWeightedLMS(
      hue_restored_lms,
      input_adaptive_state_lms);

  if (gamut_compression != 0.f) {
    display_relative_weighted = Psycho23GamutCompressAdaptiveRelativeWeightedLMSBound(
        display_relative_weighted,
        input_adaptive_state_lms,
        gamut_bound_rgb_to_lms_weighted_mat,
        gamut_compression);
  }

  return renodx::color::macleod_boynton::UnweighLMS(
      Psycho23FromAdaptiveRelativeWeightedLMS(
          display_relative_weighted,
          input_adaptive_state_lms));
}

// PsychoV-24 display mapping (opt-in "Vanilla+ (PsychoV-24)"): a perceptual observer-model curve
// (LMS + MacLeod-Boynton). Idiom-A gamma: the scene stays LINEAR into the curve, the EOTF gamma is
// folded OUT of the neutral peak target (inverse) and back ONTO the output (forward). Neutral
// highlights approach the configured Peak Brightness asymptotically while mids darken; this path is
// not a hard per-channel MaxCLL clamp for saturated colors. Saturation rides purity_scale; hue
// restore and highlight bleach are internal to the curve, so the separate adaptive highlight
// emulation is bypassed in this mode; gamut compresses to the BT.2020 hull. Consumes the same
// reconstructed color as the other mappers.
float3 ApplyRenoDXPsychoV(float3 color, bool apply_grade) {
  float peak = max(injectedData.peak_white_nits / max(injectedData.diffuse_white_nits, 1.f), 1.001f);
  if (injectedData.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_2) {
    peak = renodx::color::correct::GammaSafe(peak, true, 2.2f);
  } else if (injectedData.gamma_correction == renodx::draw::GAMMA_CORRECTION_GAMMA_2_4) {
    peak = renodx::color::correct::GammaSafe(peak, true, 2.4f);
  }
  // Menu / FMV / loading is ungraded (apply_grade = false) -> neutral purity there.
  const float purity = apply_grade ? injectedData.color_grade_saturation : 1.f;
  color = renodx::tonemap::psychov::psychotm_test24(
      color, peak,
      1.f, 1.f, 1.f, 1.f,    // exposure / highlights / shadows / contrast (graded upstream)
      purity,                // purity_scale = Saturation
      1.f, 100.f, 1.f, 1.f,  // bleaching / clip / hue_restore / adaptation_contrast (defaults)
      0,                     // white_curve_mode
      1.f,                   // cone_response_exponent
      0.18f.xxx, 0.18f.xxx,  // adaptive / background state (mid grey)
      1.f,                   // gamut compression
      1,                     // gamut compression bound = BT.2020 (HDR10)
      1.f,                   // adaptive_normalization
      0.f,                   // compression = auto (shoulder from display headroom)
      1.f,                   // highlight_saturation (unused by test24)
      0.f);                  // gamut_hue_restore off
  return ApplyEotfEmulation(color);  // Idiom-A forward gamma (undoes the peak inverse)
}

// Dedicated PsychoV-24 output. Its display mapper owns gamma and peak handling;
// keep this separate from the fixed Standard output used by Vanilla+ and Customized.
float3 ApplyRenoDXPsychoVOutput(float3 color, bool apply_grade) {
  if (apply_grade) color = ApplyRenoDXGrade(color);
  return EncodeRenoDXHDR10(ApplyRenoDXPsychoV(color, apply_grade));
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
