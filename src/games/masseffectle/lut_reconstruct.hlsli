#ifndef SRC_GAMES_MASSEFFECTLE_LUT_RECONSTRUCT_HLSLI_
#define SRC_GAMES_MASSEFFECTLE_LUT_RECONSTRUCT_HLSLI_

// Native colour grades of the LUT permutations and the HDR tone maps built on them. Include after the permutation
// declares ColorGradingLUT, GammaColorScaleAndInverse and GammaOverlayColor.

// 16-slice colour LUT plus GammaOverlayColor, before the game's scale and gamma: slice from blue, strip from red and green.
float3 MELEGradeColorLUT(float3 color) {
  float4 r0, r1;
  r0.xyz = color;
  if (CUSTOM_LUT_SAMPLING == 0.f) {
    r0.xw = float2(0.05859375, 15) * r0.xz;
    r0.w = floor(r0.w);
    r0.z = r0.z * 15 + -r0.w;
    r1.x = r0.w * 0.0625 + r0.x;
    r1.y = 0.9375 * r0.y;
    r1.xyzw = float4(0.001953125, 0.03125, 0.064453125, 0.03125) + r1.xyxy;
    r0.xyw = ColorGradingLUT.Sample(ColorGradingLUTSampler_s, r1.xy).xyz;
    r1.xyz = ColorGradingLUT.Sample(ColorGradingLUTSampler_s, r1.zw).xyz;
    r1.xyz = r1.xyz + -r0.xyw;
    r0.xyz = r0.zzz * r1.xyz + r0.xyw;
  } else {
    r0.xyz = renodx::lut::SampleTetrahedral(ColorGradingLUT, r0.xyz);
  }
  return GammaOverlayColor.xyz + lerp(color, r0.xyz, CUSTOM_LUT_STRENGTH);
}

float3 MELEGradeME12(float3 color) {
  return MELEGradeColorLUT(saturate(MELEImageAdjustME12(color)));
}

// Native RGB ratios at the luminance of the graded proxy divided by q; the native result when not valid.
float3 MELEProjectGradedProxy(float3 graded, float3 graded_proxy, float q, bool valid) {
  const float3 sdr_linear = MELENativeLinear(graded, GammaColorScaleAndInverse.xyz, true);
  const float3 work = MELENativeLinear(graded_proxy, GammaColorScaleAndInverse.xyz, true) / q;
  return valid ? MELENativeColorAtLuminance(sdr_linear, renodx::color::y::from::BT709(work)) : sdr_linear;
}

float3 MELEToneMapME12(float3 graded, float3 scene, float3 bloom, float3 vignette_tint) {
  float q;
  float3 proxy;
  const bool valid = MELETryGradeProxy(MELEExpWork(scene, bloom), q, proxy);
  return CustomToneMapPass(MELEProjectGradedProxy(graded, MELEGradeME12(proxy), q, valid), MELE_EXP_ANCHOR,
                           vignette_tint);
}

// z is the filmic LUT's input: MELEExpWork(scene, bloom) on ME2, scene plus bloom on ME3. The PsychoV anchor is the LUT at
// its mid-grey node.
float3 MELEToneMapFilmic(float3 graded, float3 z, float3 filmic, bool has_precurve, Texture2D<float4> filmic_lut,
                         SamplerState filmic_sampler, float3 vignette_tint) {
  float q;
  float3 proxy;
  const bool valid =
      MELETryGradeProxy(MELEFilmicExtended(filmic_lut, filmic_sampler, z, filmic, has_precurve), q, proxy);
  return CustomToneMapPass(
      MELEProjectGradedProxy(graded, MELEGradeColorLUT(proxy), q, valid),
      MELEFilmicLookup(filmic_lut, filmic_sampler, has_precurve ? MELE_MIDGRAY_NATIVE_CURVE : MELE_MIDGRAY_SCENE),
      vignette_tint);
}

#endif  // SRC_GAMES_MASSEFFECTLE_LUT_RECONSTRUCT_HLSLI_
