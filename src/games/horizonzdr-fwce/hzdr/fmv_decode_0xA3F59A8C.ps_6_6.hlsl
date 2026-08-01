// FMV / video decode pass (Bink planes -> RGB). In HDR mode it runs the same highlight
// expansion family as the compose pass flag&4 block, driven by cHDROutputControl =
// (enable, boost, soft-knee, cap), with the per-pixel highlight weight baked into the
// video's alpha plane as APlane * 100.
// Output is LINEAR - the menu/FMV output pass 0x7475EFAE encodes it.
//
// RenoDX replaces cHDROutputControl's boost (.y) and cap (.w) with EvaluateNativeExpansionLuma
// and ignores the Shadows soft knee (.z); see common.hlsli for what that recalibration does.

#include "../common.hlsli"

Texture2D<float4> YPlane : register(t16, space8);

Texture2D<float4> RPlane : register(t17, space8);

Texture2D<float4> BPlane : register(t18, space8);

Texture2D<float4> APlane : register(t19, space8);

cbuffer InUniformParams : register(b0, space8) {
  float4 cHDROutputControl : packoffset(c000.x);
  float4 cYUVToSRGBMatrix[4] : packoffset(c001.x);
};

SamplerState Sampler : register(s0, space8);

float4 main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) : SV_Target {
  float4 SV_Target;
  float4 _12 = YPlane.Sample(Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _15 = RPlane.Sample(Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _18 = BPlane.Sample(Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float4 _21 = APlane.Sample(Sampler, float2(TEXCOORD.x, TEXCOORD.y));
  float _39 = (cYUVToSRGBMatrix[0].x) * _12.x;
  float _40 = mad((cYUVToSRGBMatrix[1].x), _15.x, _39);
  float _41 = mad((cYUVToSRGBMatrix[2].x), _18.x, _40);
  float _42 = _41 + (cYUVToSRGBMatrix[3].x);
  float _43 = (cYUVToSRGBMatrix[0].y) * _12.x;
  float _44 = mad((cYUVToSRGBMatrix[1].y), _15.x, _43);
  float _45 = mad((cYUVToSRGBMatrix[2].y), _18.x, _44);
  float _46 = _45 + (cYUVToSRGBMatrix[3].y);
  float _47 = (cYUVToSRGBMatrix[0].z) * _12.x;
  float _48 = mad((cYUVToSRGBMatrix[1].z), _15.x, _47);
  float _49 = mad((cYUVToSRGBMatrix[2].z), _18.x, _48);
  float _50 = _49 + (cYUVToSRGBMatrix[3].z);
  bool _51 = (_42 < 0.040449999272823334f);
  float _62;
  float _74;
  float _86;
  float _158;
  float _166;
  float _167;
  float _168;
  if (_51) {
    float _53 = _42 * 0.07739938050508499f;
    _62 = _53;
  } else {
    float _55 = _42 * 0.9478672742843628f;
    float _56 = _55 + 0.05213269963860512f;
    float _57 = abs(_56);
    float _58 = log2(_57);
    float _59 = _58 * 2.4000000953674316f;
    float _60 = exp2(_59);
    _62 = _60;
  }
  bool _63 = (_46 < 0.040449999272823334f);
  if (_63) {
    float _65 = _46 * 0.07739938050508499f;
    _74 = _65;
  } else {
    float _67 = _46 * 0.9478672742843628f;
    float _68 = _67 + 0.05213269963860512f;
    float _69 = abs(_68);
    float _70 = log2(_69);
    float _71 = _70 * 2.4000000953674316f;
    float _72 = exp2(_71);
    _74 = _72;
  }
  bool _75 = (_50 < 0.040449999272823334f);
  if (_75) {
    float _77 = _50 * 0.07739938050508499f;
    _86 = _77;
  } else {
    float _79 = _50 * 0.9478672742843628f;
    float _80 = _79 + 0.05213269963860512f;
    float _81 = abs(_80);
    float _82 = log2(_81);
    float _83 = _82 * 2.4000000953674316f;
    float _84 = exp2(_83);
    _86 = _84;
  }
  bool _89 = (cHDROutputControl.x > 0.0f);
  if (_89) {
    // Neutralizing the Shadows toe collapses the native soft-knee formula to abs() of the
    // decoded channels; EvaluateNativeExpansionLuma says why abs and not the identity.
    float _108 = abs(_62);
    float _109 = abs(_74);
    float _110 = abs(_86);
    // RenoDX replaces the in-game highlight boost/cap.
    const NativeExpansionLuma expansion = EvaluateNativeExpansionLuma(
        dot(float3(_108, _109, _110),
            float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f)),
        _21.x);
    float _113 = expansion.source;
    float _129 = expansion.boosted;
    float _130 = max(_113, 9.999999717180685e-10f);
    float _131 = 1.0f / _130;
    float _132 = _131 * _108;
    float _133 = _131 * _109;
    float _134 = _131 * _110;
    float _135 = _129 * _131;
    float _136 = max(9.999999717180685e-10f, _132);
    float _137 = max(9.999999717180685e-10f, _133);
    float _138 = max(9.999999717180685e-10f, _134);
    float _139 = log2(_136);
    float _140 = log2(_137);
    float _141 = log2(_138);
    float _142 = _139 * _135;
    float _143 = _140 * _135;
    float _144 = _141 * _135;
    float _145 = exp2(_142);
    float _146 = exp2(_143);
    float _147 = exp2(_144);
    _158 = expansion.mapped;
    float _159 = _158 * _145;
    float _160 = _158 * _146;
    float _161 = _158 * _147;
    float _162 = min(_159, expansion.cap);
    float _163 = min(_160, expansion.cap);
    float _164 = min(_161, expansion.cap);
    _166 = _162;
    _167 = _163;
    _168 = _164;
  } else {
    _166 = _62;
    _167 = _74;
    _168 = _86;
  }
  SV_Target.x = _166;
  SV_Target.y = _167;
  SV_Target.z = _168;
  SV_Target.w = 1.0f;
  return SV_Target;
}
