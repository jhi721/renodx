#ifndef SRC_GAMES_HORIZONZDR_FWCE_COMMON_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_COMMON_HLSLI_

#include "./shared.h"
#include "./psycho_test24.hlsli"

// Luma is Rec.709-weighted throughout, not the Decima 0.3086/0.6094/0.0820 set.

float ComputeVanillaCompressionScalar(float x) {
  const float y = x + 1.f;
  const float g = x * ((y * x) + 1.f);
  return g / (g + y);
}

float3 ApplyRenoDXGrade(float3 color, float saturation) {
  renodx::color::grade::Config cg = renodx::color::grade::config::Create();
  cg.exposure = injectedData.color_grade_exposure;
  cg.highlights = injectedData.color_grade_highlights;
  cg.shadows = injectedData.color_grade_shadows;
  cg.contrast = injectedData.color_grade_contrast;
  cg.flare = injectedData.color_grade_flare;
  cg.saturation = saturation;
  cg.dechroma = injectedData.color_grade_blowout;
  cg.blowout = -1.f * (injectedData.color_grade_highlight_saturation - 1.f);
  cg.hue_correction_strength = 0.f;  // No hue correction; Create() would default this to 1.

  return renodx::color::grade::config::ApplyUserColorGrading(color, cg);
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
  return injectedData.peak_ratio;
}


float InternalPeakRatio() {
  return injectedData.internal_peak_ratio;
}

// Must come after PeakRatio: SelectResolverSharpening uses it for the RCAS normalization.
#include "./resolver_sharpening.hlsli"

// PsychoV23 signed-opponent retention(asscreed reference, thx Musa).
// White progress comes from the active display-map output, so hue shift and blowout increase as display headroom falls.
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

float3 Psycho23AdaptiveRelativeWeightedNeutral() {
  return renodx::color::macleod_boynton::WeighLMS(1.f.xxx);
}

// Opponent-axis normalizers derived from the adapted neutral. Shared so the forward and
// inverse transforms below provably use the same constants. Both fold at compile time —
// the neutral is WeighLMS applied to a constant.
// .x = M-to-L ratio, .y = S-to-(L+M) ratio.
float2 Psycho23OpponentAxisScales() {
  const float3 neutral_weighted = Psycho23AdaptiveRelativeWeightedNeutral();
  return float2(
      renodx::math::DivideSafe(
          neutral_weighted.x,
          neutral_weighted.y,
          0.f),
      renodx::math::DivideSafe(
          neutral_weighted.x + neutral_weighted.y,
          neutral_weighted.z,
          0.f));
}

float3 Psycho23OpponentACCFromWeightedDelta(float3 delta_weighted_lms) {
  const float2 axis_scales = Psycho23OpponentAxisScales();
  const float m_to_l = axis_scales.x;
  const float s_to_lm = axis_scales.y;

  return float3(
      delta_weighted_lms.x + delta_weighted_lms.y,
      delta_weighted_lms.x - m_to_l * delta_weighted_lms.y,
      -delta_weighted_lms.x - delta_weighted_lms.y
          + s_to_lm * delta_weighted_lms.z);
}

float3 Psycho23WeightedDeltaFromOpponentACC(float3 acc) {
  const float2 axis_scales = Psycho23OpponentAxisScales();
  const float m_to_l = axis_scales.x;
  const float s_to_lm = axis_scales.y;

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
    float3x3 gamut_bound_rgb_to_lms_weighted_mat) {
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
  // Hue restoration and gamut compression are not parameters: both always run at full
  // strength. Taking opponent_retained_lms directly rather than lerping toward it at weight
  // 1.0 also avoids a + (b - a), which equals b only when the difference is representable.
  float3 display_relative_weighted = Psycho23ToAdaptiveRelativeWeightedLMS(
      opponent_retained_lms,
      input_adaptive_state_lms);

  display_relative_weighted =
      renodx::color::gamut::GamutCompressWeightedLMSCoreRGBBoundFromAdaptiveWeightedInput(
          display_relative_weighted,
          input_adaptive_state_lms,
          gamut_bound_rgb_to_lms_weighted_mat,
          1.f);

  return renodx::color::macleod_boynton::UnweighLMS(
      Psycho23FromAdaptiveRelativeWeightedLMS(
          display_relative_weighted,
          input_adaptive_state_lms));
}

float3 ApplyRenoDXPsychoV(float3 color) {
  const float peak = InternalPeakRatio();
  color = renodx_custom::tonemap::psychov::psychotm_test24(
      color, peak,
      1.f, 1.f, 1.f, 1.f,    // exposure / highlights / shadows / contrast (graded upstream)
      injectedData.color_grade_saturation,  // purity_scale = Saturation
      1.f, 100.f, 1.f,       // bleaching / clip / hue_restore (ignored by test24)
      1.f,                   // adaptation_contrast
      0,                     // white_curve_mode (ignored by test24)
      1.f,                   // cone_response_exponent
      0.18f.xxx, 0.18f.xxx,  // adaptive / background state (mid grey)
      1.f,                   // gamut compression
      1,                     // gamut compression bound = BT.2020 (HDR10)
      1.f,                   // adaptive_normalization (ignored by test24)
      0.f,                   // compression = auto (shoulder from display headroom)
      1.f,                   // highlight_saturation (ignored by test24)
      0.f);                  // gamut_hue_restore off
  return ApplyEotfEmulation(color);  // Idiom-A forward gamma (undoes the peak inverse)
}

float3 ApplyPeakSafetyCap(float3 color) {
  const float peak_ratio = PeakRatio();
  const float peak_channel = renodx::math::Max(color);
  if (peak_channel > peak_ratio) color *= peak_ratio / peak_channel;
  return color;
}

// Scene-relative linear BT.709 -> absolute-nits PQ BT.2020. Never reads the game's
// Constant_176.x gamma or .y paper-white scale; Game Brightness maps 1.0 to nits.
float3 EncodeRenoDXHDR10(float3 color) {
  float3 scene_nits = max(0.f, color) * injectedData.diffuse_white_nits;
  return renodx::color::pq::EncodeSafe(renodx::color::bt2020::from::BT709(scene_nits), 1.f);
}

float3 ApplyRenoDXStandardOutput(float3 color) {
  color = ApplyRenoDXGrade(color, injectedData.color_grade_saturation);
  color = ApplyEotfEmulation(color);
  return EncodeRenoDXHDR10(ApplyPeakSafetyCap(color));
}

float3 ApplyRenoDXPsychoVOutput(float3 color) {
  color = ApplyRenoDXGrade(color, 1.f);
  return EncodeRenoDXHDR10(ApplyRenoDXPsychoV(color));
}

float3 SampleHzdrLut(Texture3D<float3> lut, SamplerState samp,
                     float3 gamma2_color, float lut_scale, float lut_bias) {
  float3 lutted;
  if (injectedData.custom_lut_tetrahedral != 0.f) {
    float lut_size;
    renodx::lut::GetLutSize(lut, lut_size);
    const float3 game_uvw = gamma2_color * lut_scale + lut_bias;
    const float3 std_color = (game_uvw * lut_size - 0.5f) / (lut_size - 1.f);
    lutted = renodx::lut::SampleTetrahedral(lut, std_color);
  } else {
    lutted = lut.SampleLevel(samp, gamma2_color * lut_scale + lut_bias, 0.f);
  }
  return lutted * lutted;
}

struct NativeExpansionLuma {
  float source;
  float boosted;
  float mapped;
  float cap;
};

// Shared luma core for scene and FMV expansion. Callers retain their native
// soft-knee and chroma reconstruction while sharing the calibrated shoulder.
NativeExpansionLuma EvaluateNativeExpansionLuma(float source_luma, float weight) {
  NativeExpansionLuma result;
  result.source = saturate(source_luma);
  result.cap = InternalPeakRatio();

  const float knee = result.cap * result.cap * 0.03125f;
  const float boost = 32.f - result.cap + knee;
  const float shoulder_mask = saturate(result.source - 0.5f);
  const float boost_curve = (shoulder_mask * shoulder_mask * (weight * 100.f))
                            + (1.f / (1.f - (result.source * 0.5f)));
  result.boosted = result.source
                   + ((boost - 1.f) * 0.03846153989434242f  // = 1/26, from the vanilla block
                      * max(0.f, (boost_curve * result.source) - result.source));

  result.mapped = result.boosted;
  if (result.boosted > knee) {
    result.mapped = (knee + result.cap)
                    - ((result.cap * result.cap)
                       / ((result.cap - knee) + result.boosted));
  }

  result.mapped = clamp(result.mapped, result.source, result.cap);
  return result;
}

// Full native Decima expansion with addon-controlled boost/cap. The input is the
// game's per-channel-compressed, trilinear-LUT result
float3 ApplyNativeSceneExpansion(
    float3 lut_sat,
    float weight,
    bool expansion_active) {
  if (!expansion_active) return lut_sat;

  const NativeExpansionLuma expansion = EvaluateNativeExpansionLuma(
      dot(lut_sat, float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f)),
      weight);
  const float safe_y = max(expansion.source, 1e-9f);
  const float chroma_exponent = max(expansion.boosted / safe_y, 1e-9f);
  const float3 chroma = exp2(log2(abs(lut_sat / safe_y)) * chroma_exponent);
  return min(expansion.mapped * chroma, expansion.cap.xxx);
}

float3 ApplyRenoDXSceneOutput(
    float3 pre_compressor,   // linear scene color before the flag&2 compressor
    float3 vanilla_lut_sat,  // vanilla saturate(lut^2) — the SDR-range graded color
    float weight,            // vanilla highlight weight (slider-independent)
    bool compressor_active,  // flag&2
    bool expansion_active,   // flag&4
    Texture3D<float3> lut, SamplerState lut_sampler,
    float lut_scale, float lut_bias) {  // Constant_072.x/.y
  if (injectedData.tone_map_type == HORIZON_TONE_MAP_TYPE_VANILLA_PLUS) {
    return ApplyRenoDXStandardOutput(
        ApplyNativeSceneExpansion(
            vanilla_lut_sat,
            weight,
            expansion_active));
  }

  pre_compressor = max(pre_compressor, 0.f);
  const float max_channel = renodx::math::Max(pre_compressor);
  float scale = 1.f;
  if (max_channel > 1e-6f) {
    const float compressed = compressor_active
                                 ? ComputeVanillaCompressionScalar(max_channel)
                                 : min(max_channel, 1.f);
    scale = compressed / max_channel;
  }
  const float3 bridge_input = pre_compressor * scale;
  const float3 lutted = SampleHzdrLut(lut, lut_sampler, sqrt(saturate(bridge_input)),
                                      lut_scale, lut_bias);
  const float3 bridge = lerp(bridge_input, lutted, injectedData.color_grade_lut_strength);

  const bool customized_map = injectedData.tone_map_type == HORIZON_TONE_MAP_TYPE_CUSTOMIZED;
  const bool psychov_map = injectedData.tone_map_type == HORIZON_TONE_MAP_TYPE_PSYCHOV;
  if (psychov_map && expansion_active) {
    return ApplyRenoDXPsychoVOutput(bridge / scale);
  }

  // Customized and the PsychoV expansion-off fallback preserve the flag&4 luma-keyed
  // luminance match used by both games.
  const float y_bridge = renodx::color::y::from::BT709(bridge);  // same weights as y_target
  const float vanilla_y = saturate(renodx::color::y::from::BT709(vanilla_lut_sat));
  const float y_target = psychov_map || !expansion_active
                             ? vanilla_y
                             : EvaluateNativeExpansionLuma(vanilla_y, weight).mapped;
  float3 color = renodx::color::correct::Luminance(bridge, y_bridge, y_target);

  if (customized_map) {
    const float internal_peak_ratio = InternalPeakRatio();
    const float3 anchor_lms = renodx::color::lms::from::BT709(0.18f.xxx);

    const float3 peak_white_lms = renodx::color::lms::from::BT709(1.f.xxx) * internal_peak_ratio;
    color = renodx::color::bt709::from::LMS(
        ApplyPsycho23SignedOpponentRetentionAndGamutCompressionLMS(
            renodx::color::lms::from::BT709(bridge / scale),
            renodx::color::lms::from::BT709(color),
            anchor_lms,
            anchor_lms,
            peak_white_lms,
            renodx::color::macleod_boynton::BT2020_TO_LMS_WEIGHTED_MAT));
  }

  return ApplyRenoDXStandardOutput(color);
}

float3 ApplyVanillaPlusMenu(float3 color) {
  return ApplyRenoDXStandardOutput(color);
}

float4 GetResolverOutputParams(float4 game_output_params) {
  if ((injectedData.tone_map_type == HORIZON_TONE_MAP_TYPE_VANILLA)
      || (int(game_output_params.w) != 2)) {
    return game_output_params;
  }

  const float peak_nits = injectedData.peak_white_nits;
  game_output_params.x = renodx::color::pq::M1;
  game_output_params.y = injectedData.diffuse_white_nits / 10000.f;
  game_output_params.z = renodx::color::pq::EncodeSafe(peak_nits.xxx, 1.f).x;
  return game_output_params;
}

#endif  // SRC_GAMES_HORIZONZDR_FWCE_COMMON_HLSLI_
