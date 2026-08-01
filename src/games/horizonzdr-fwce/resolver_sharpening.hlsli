#ifndef SRC_GAMES_HORIZONZDR_FWCE_RESOLVER_SHARPENING_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_RESOLVER_SHARPENING_HLSLI_

// Optional replacement for the AA/upscale resolvers' own CAS sharpening: Lilium HDR RCAS run on
// the taps the resolver already fetched.

static const float RESOLVER_RCAS_LIMIT = 0.1875f;  // = 3/16, the RCAS lobe clamp.
static const float RESOLVER_RCAS_EPSILON = 1e-6f;  // Divide guard; never a visual threshold.

float GameSRGBDecode(float color) {
  if (color < 0.040449999272823334f) return color * 0.07739938050508499f;
  return pow(abs(color * 0.9478672742843628f + 0.05213269963860512f), 2.4000000953674316f);
}

float GameSRGBEncode(float color) {
  if (color < 0.003100000089034438f) return color * 12.920000076293945f;
  return pow(abs(color), 0.4166666567325592f) * 1.0549999475479126f - 0.054999999701976776f;
}

float3 ResolverBT709FromBT2020(float3 color) {
  return float3(
      mad(-0.07284989953041077f, color.z, mad(-0.5876410007476807f, color.y, color.x * 1.6604900360107422f)),
      mad(-0.008349419571459293f, color.z, mad(1.1328999996185303f, color.y, color.x * -0.124549999833107f)),
      mad(1.1187299489974976f, color.z, mad(-0.10057900100946426f, color.y, color.x * -0.018150800839066505f)));
}

float3 ResolverBT2020FromBT709(float3 color) {
  return float3(
      mad(0.04331306740641594f, color.z, mad(0.3292830288410187f, color.y, color.x * 0.6274039149284363f)),
      mad(0.011362316086888313f, color.z, mad(0.9195404052734375f, color.y, color.x * 0.06909728795289993f)),
      mad(0.8955952525138855f, color.z, mad(0.08801330626010895f, color.y, color.x * 0.016391439363360405f)));
}

float3 DecodeResolverColor(float3 color, float4 output_params) {
  const int output_mode = int(output_params.w);
  const float inverse_exponent = rcp(output_params.x);

  if (output_mode == 1) {
    color = float3(
        GameSRGBDecode(color.x),
        GameSRGBDecode(color.y),
        GameSRGBDecode(color.z));
    return pow(max(0.f, color), inverse_exponent);
  }

  if (output_mode == 2) {
    float3 encoded_root = pow(max(0.f, color), 0.012683313339948654f);
    color = (encoded_root - 0.8359375f) / (18.8515625f - encoded_root * 18.6875f);
    color = pow(max(0.f, color), inverse_exponent) / output_params.y;

    return ResolverBT709FromBT2020(color);
  }

  return color;
}

float3 EncodeResolverColor(float3 color, float4 output_params) {
  const int output_mode = int(output_params.w);

  if (output_mode == 1) {
    color = pow(max(0.f, color), output_params.x);
    return float3(
        GameSRGBEncode(color.x),
        GameSRGBEncode(color.y),
        GameSRGBEncode(color.z));
  }

  if (output_mode == 2) {
    color = max(0.f, ResolverBT2020FromBT709(color) * output_params.y);
    float3 linear_root = pow(color, output_params.x);
    color = (linear_root * 18.8515625f + 0.8359375f) / (linear_root * 18.6875f + 1.f);
    return pow(color, 78.84375f);
  }

  return color;
}

float3 ApplyResolverHDRRCAS(
    float3 b,
    float3 d,
    float3 e,
    float3 f,
    float3 h,
    float strength,
    float normalization_point) {
  const float inverse_normalization = rcp(max(normalization_point, 1.f));
  const float b_luma = renodx::color::y::from::BT709(max(0.f, b)) * inverse_normalization;
  const float d_luma = renodx::color::y::from::BT709(max(0.f, d)) * inverse_normalization;
  const float e_luma = renodx::color::y::from::BT709(max(0.f, e)) * inverse_normalization;
  const float f_luma = renodx::color::y::from::BT709(max(0.f, f)) * inverse_normalization;
  const float h_luma = renodx::color::y::from::BT709(max(0.f, h)) * inverse_normalization;

  const float min_ring_luma = renodx::math::Min(b_luma, d_luma, f_luma, h_luma);
  const float max_ring_luma = renodx::math::Max(b_luma, d_luma, f_luma, h_luma);
  const float limited_max_luma = min(max_ring_luma, 0.99f);
  const float hit_min = min_ring_luma * rcp(max(4.f * limited_max_luma, RESOLVER_RCAS_EPSILON));
  float hit_max_denominator = 4.f * min_ring_luma - 4.f;
  hit_max_denominator = abs(hit_max_denominator) < RESOLVER_RCAS_EPSILON
                            ? (hit_max_denominator < 0.f ? -RESOLVER_RCAS_EPSILON : RESOLVER_RCAS_EPSILON)
                            : hit_max_denominator;
  const float hit_max = (1.f - limited_max_luma) * rcp(hit_max_denominator);
  float lobe = max(-RESOLVER_RCAS_LIMIT, min(max(-hit_min, hit_max), 0.f)) * strength;

  float noise = 0.25f * (b_luma + d_luma + f_luma + h_luma) - e_luma;
  const float max_luma = renodx::math::Max(renodx::math::Max(b_luma, d_luma, e_luma), f_luma, h_luma);
  const float min_luma = renodx::math::Min(renodx::math::Min(b_luma, d_luma, e_luma), f_luma, h_luma);
  noise = saturate(abs(noise) * rcp(max(max_luma - min_luma, RESOLVER_RCAS_EPSILON)));
  lobe *= 1.f - 0.5f * noise;

  const float sharpened_luma = ((b_luma + d_luma + f_luma + h_luma) * lobe + e_luma) * rcp(4.f * lobe + 1.f);
  return clamp(renodx::math::DivideSafe(sharpened_luma, e_luma, 1.f), 0.f, 4.f) * e;
}

float GetResolverNormalizationPoint(float4 output_params) {
  if ((injectedData.fx_resolver_sharpening_type < 1.f)
      || (injectedData.fx_resolver_sharpening_strength == 0.f)) return 1.f;

  const int output_mode = int(output_params.w);
  if (output_mode == 2) return PeakRatio();
  if ((output_mode != 1) || (output_params.x <= 0.f)) return 1.f;

  return max(renodx::color::y::from::BT709(
                 DecodeResolverColor(output_params.z.xxx, output_params)),
             1.f);
}

float3 SelectResolverSharpening(
    float3 game_sharpened,
    float3 b,
    float3 d,
    float3 e,
    float3 f,
    float3 h,
    float4 output_params,
    float normalization_point) {
  if (injectedData.fx_resolver_sharpening_type < 1.f) return game_sharpened;

  const float strength = injectedData.fx_resolver_sharpening_strength;
  if (strength == 0.f) return e;

  const int output_mode = int(output_params.w);
  if ((output_mode != 1) && (output_mode != 2)) return e;
  if ((output_params.x <= 0.f) || ((output_mode == 2) && (output_params.y <= 0.f))) return e;

  b = DecodeResolverColor(b, output_params);
  d = DecodeResolverColor(d, output_params);
  e = DecodeResolverColor(e, output_params);
  f = DecodeResolverColor(f, output_params);
  h = DecodeResolverColor(h, output_params);
  return EncodeResolverColor(
      ApplyResolverHDRRCAS(b, d, e, f, h, strength, normalization_point),
      output_params);
}

#endif  // SRC_GAMES_HORIZONZDR_FWCE_RESOLVER_SHARPENING_HLSLI_
