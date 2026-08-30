#ifndef SRC_GAMES_MASSEFFECTLE_ANALYTIC_RECONSTRUCT_HLSLI_
#define SRC_GAMES_MASSEFFECTLE_ANALYTIC_RECONSTRUCT_HLSLI_

// HDR tone maps of the analytic scene permutations. Include after the permutation declares its _Globals. white_point is
// the game's encoded white point; like vanilla it tints the native result ahead of its clip.

// Grades the working value through an uncapped copy of the native grade: max(0, .) replaces the saturate ahead of log2
// and nothing clamps after it.
float3 MELEToneMapAnalytic(float3 graded, float3 scene, float3 bloom, float3 white_point) {
  const float3 white_point_linear = renodx::math::SignPow(white_point, 2.2f);
  const float3 work = MELEExpWork(scene, bloom);
  const float3 shifted = MELEImageAdjustME12(work) - SceneShadowsAndDesaturation.xyz;
  const float3 base = SceneInverseHighLights.xyz * max(0, shifted);
  const float3 toned = exp2(SceneMidTones.xyz * log2(base));
  const float3 work_linear =
      white_point_linear * GammaColorScaleAndInverse.xyz
      * (toned * SceneShadowsAndDesaturation.www + GammaOverlayColor.xyz + dot(toned, SceneScaledLuminanceWeights.xyz));
  // shifted may be negative. A zero base needs a positive SceneMidTones, or log2 gives NaN or +inf.
  const bool valid = MELEIsFiniteNonNegative(work) && MELEIsFinite(shifted) && MELEIsFiniteNonNegative(base)
                     && !any(base == 0 && SceneMidTones.xyz <= 0) && MELEIsFiniteNonNegative(work_linear);
  const float3 sdr_linear =
      min(1, white_point_linear * MELENativeLinear(graded, GammaColorScaleAndInverse.xyz, false));
  return CustomToneMapPass(
      valid ? MELENativeColorAtLuminance(sdr_linear, renodx::color::y::from::BT709(work_linear)) : sdr_linear,
      MELE_EXP_ANCHOR, 1.f);
}

// ME3 native analytic grade on linear scene plus bloom, up to GammaOverlayColor.
float3 MELEGradeME3Analytic(float3 color) {
  float4 r0;
  r0.xyz = saturate(-SceneShadowsAndDesaturation.xyz + color);
  r0.xyz = SceneInverseHighLights.xyz * r0.xyz;
  r0.xyz = log2(r0.xyz);
  r0.xyz = SceneMidTones.xyz * r0.xyz;
  r0.xyz = exp2(r0.xyz);
  r0.w = dot(r0.xyz, SceneScaledLuminanceWeights.xyz);
  r0.xyz = r0.xyz * SceneShadowsAndDesaturation.www + r0.www;
  return GammaOverlayColor.xyz + r0.xyz;
}

// Grades a bounded proxy for range and takes only hue from the hard-clipped native result, at strength 0.75.
float3 MELEToneMapME3Analytic(float3 graded, float3 untonemapped, float3 white_point) {
  const float3 white_point_linear = renodx::math::SignPow(white_point, 2.2f);
  float q;
  float3 proxy;
  const bool valid = MELETryGradeProxy(untonemapped, q, proxy);
  const float3 sdr_linear = min(1, white_point_linear * MELENativeLinear(graded, GammaColorScaleAndInverse.xyz, true));
  const float3 work =
      min(1, white_point_linear * MELENativeLinear(MELEGradeME3Analytic(proxy), GammaColorScaleAndInverse.xyz, true)) / q;
  const float3 corrected = renodx::color::correct::HueOKLab(work, sdr_linear, 0.75f);
  return CustomToneMapPass(
      !(valid && MELEIsFinite(work)) ? sdr_linear : (MELEIsFinite(corrected) ? corrected : work),
      MELE_MIDGRAY_SCENE, 1.f);
}

#endif  // SRC_GAMES_MASSEFFECTLE_ANALYTIC_RECONSTRUCT_HLSLI_
