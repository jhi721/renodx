#include "./shared.h"

float3 EncodeGameWorkingSpace(float3 color) {
  return renodx::color::gamma::EncodeSafe(color, 2.2f);
}

float3 DecodeGameWorkingSpace(float3 color) {
  return renodx::color::gamma::DecodeSafe(color, 2.2f);
}

// Final swapchain encode (replaces the game's sRGB final blit): gamma-2.2 working space -> scRGB
// linear (80 nits == 1.0). Working space is pow(1/2.2)-encoded in 0xEE858EE5.
float3 FinalizeOutput(float3 color) {
  // Decode to linear, emulating the chosen display EOTF (the sole EOTF for both modes). 2.2 = exact
  // inverse of the encode (neutral, validated default); BT.1886 = 2.4 (darker mids); Off = sRGB.
  if (injectedData.toneMapGammaCorrection == 2.f) {  // BT.1886
    color = renodx::color::gamma::DecodeSafe(color, 2.4f);
  } else if (injectedData.toneMapGammaCorrection == 1.f) {  // 2.2
    color = renodx::color::gamma::DecodeSafe(color, 2.2f);
  } else {  // Off -> sRGB
    color = renodx::color::srgb::DecodeSafe(color);
  }
  // color is now linear, 1.0 == diffuse white.

  // The vanilla composite (0x0A956F64) additively re-adds raw scene/bloom on top of the tone-mapped
  // layer, so highlights overshoot the ceiling and must be bounded here.
  if (injectedData.toneMapType == TONE_MAP_TYPE__SDR) {
    color = saturate(color);  // faithful SDR ref: hard clamp to paper white (rolloff NaNs at size 0)
  } else {
    // Vanilla+: the vanilla curve already shaped legit highlights to ~peak/game, so start the rolloff
    // HIGH and bound only the bloom OVERSHOOT (>> peak/game) -> legit reaches Peak, bloom asymptotes
    // to peak/game. rolloff_start=1.0 (paper white) double-shouldered everything -> peak only on bloom.
    float peak_paper_ratio = max(injectedData.toneMapPeakNits / injectedData.toneMapGameNits, 1.0001f);
    const float ROLLOFF_K = 0.8f;  // higher = brighter peak, sharper bloom knee
    float rolloff_start = max(1.f, peak_paper_ratio * ROLLOFF_K);
    rolloff_start = min(rolloff_start, peak_paper_ratio - 0.0001f);  // rolloff_size > 0 (no NaN)
    color = renodx::tonemap::ExponentialRollOff(color, rolloff_start, peak_paper_ratio);
  }

  color = renodx::color::bt709::clamp::BT709(color);  // Rec709 source: strip out-of-gamut/negatives
  color *= injectedData.toneMapGameNits / renodx::color::srgb::REFERENCE_WHITE;  // scRGB (80 nits)
  return color;
}
