// Menu / FMV / loading output encoder (single input, OETF only). Mode switch
// InUniform_Constant_000.w: 1 = SDR sRGB, 2 = BT.2020 + PQ, anything else passthrough.
// Mode 2 is the shared RenoDX encode. The HFW twin is hfw/output_menu_0x55477A4D.

#include "../common.hlsli"

Texture2D<float4> t0_space8 : register(t0, space8);

cbuffer cb0_space8 : register(b0, space8) {
  struct ShaderInstance_PerInstance_Constants {
    struct InUniform_Constant {
      float4 InUniform_Constant_000;
    } ShaderInstance_PerInstance_Constants_000;
  } ShaderInstance_PerInstance_000 : packoffset(c000.x);
};

SamplerState s0_space8 : register(s0, space8);

float4 main(
    noperspective float4 SV_Position : SV_Position,
    linear float2 TEXCOORD : TEXCOORD) : SV_Target {
  float4 SV_Target;
  float4 _13 = t0_space8.Sample(s0_space8, float2(TEXCOORD.x, TEXCOORD.y));
  int _17 = int(ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.w);
  bool _18 = (_17 == 1);
  float _43;
  float _55;
  float _121;
  float _122;
  float _123;
  [branch]
  if (_18) {
    float _20 = abs(_13.x);
    float _21 = abs(_13.y);
    float _22 = abs(_13.z);
    float _23 = log2(_20);
    float _24 = log2(_21);
    float _25 = log2(_22);
    float _26 = _23 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.x;
    float _27 = _24 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.x;
    float _28 = _25 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.x;
    float _29 = exp2(_26);
    float _30 = exp2(_27);
    float _31 = exp2(_28);
    bool _32 = (_29 < 0.003100000089034438f);
    if (_32) {
      float _34 = _29 * 12.920000076293945f;
      _43 = _34;
    } else {
      float _36 = abs(_29);
      float _37 = log2(_36);
      float _38 = _37 * 0.4166666567325592f;
      float _39 = exp2(_38);
      float _40 = _39 * 1.0549999475479126f;
      float _41 = _40 + -0.054999999701976776f;
      _43 = _41;
    }
    bool _44 = (_30 < 0.003100000089034438f);
    if (_44) {
      float _46 = _30 * 12.920000076293945f;
      _55 = _46;
    } else {
      float _48 = abs(_30);
      float _49 = log2(_48);
      float _50 = _49 * 0.4166666567325592f;
      float _51 = exp2(_50);
      float _52 = _51 * 1.0549999475479126f;
      float _53 = _52 + -0.054999999701976776f;
      _55 = _53;
    }
    bool _56 = (_31 < 0.003100000089034438f);
    if (_56) {
      float _58 = _31 * 12.920000076293945f;
      _121 = _43;
      _122 = _55;
      _123 = _58;
    } else {
      float _60 = abs(_31);
      float _61 = log2(_60);
      float _62 = _61 * 0.4166666567325592f;
      float _63 = exp2(_62);
      float _64 = _63 * 1.0549999475479126f;
      float _65 = _64 + -0.054999999701976776f;
      _121 = _43;
      _122 = _55;
      _123 = _65;
    }
  } else {
    bool _67 = (_17 == 2);
    if (_67) {
#if 1
      // renodx
      float3 renodx_output = ApplyEncodeOnlyOutput(float3(_13.x, _13.y, _13.z));
      _121 = renodx_output.r;
      _122 = renodx_output.g;
      _123 = renodx_output.b;
#else
      // vanilla
      float _69 = _13.x * 0.6274039149284363f;
      float _70 = mad(0.3292830288410187f, _13.y, _69);
      float _71 = mad(0.04331306740641594f, _13.z, _70);
      float _72 = _13.x * 0.06909728795289993f;
      float _73 = mad(0.9195404052734375f, _13.y, _72);
      float _74 = mad(0.011362316086888313f, _13.z, _73);
      float _75 = _13.x * 0.016391439363360405f;
      float _76 = mad(0.08801330626010895f, _13.y, _75);
      float _77 = mad(0.8955952525138855f, _13.z, _76);
      float _78 = _71 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.y;
      float _79 = _74 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.y;
      float _80 = _77 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.y;
      float _81 = abs(_78);
      float _82 = abs(_79);
      float _83 = abs(_80);
      float _84 = log2(_81);
      float _85 = log2(_82);
      float _86 = log2(_83);
      float _87 = _84 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.x;
      float _88 = _85 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.x;
      float _89 = _86 * ShaderInstance_PerInstance_000.ShaderInstance_PerInstance_Constants_000.InUniform_Constant_000.x;
      float _90 = exp2(_87);
      float _91 = exp2(_88);
      float _92 = exp2(_89);
      float _93 = _90 * 18.8515625f;
      float _94 = _93 + 0.8359375f;
      float _95 = _90 * 18.6875f;
      float _96 = _95 + 1.0f;
      float _97 = _94 / _96;
      float _98 = abs(_97);
      float _99 = log2(_98);
      float _100 = _99 * 78.84375f;
      float _101 = exp2(_100);
      float _102 = _91 * 18.8515625f;
      float _103 = _102 + 0.8359375f;
      float _104 = _91 * 18.6875f;
      float _105 = _104 + 1.0f;
      float _106 = _103 / _105;
      float _107 = abs(_106);
      float _108 = log2(_107);
      float _109 = _108 * 78.84375f;
      float _110 = exp2(_109);
      float _111 = _92 * 18.8515625f;
      float _112 = _111 + 0.8359375f;
      float _113 = _92 * 18.6875f;
      float _114 = _113 + 1.0f;
      float _115 = _112 / _114;
      float _116 = abs(_115);
      float _117 = log2(_116);
      float _118 = _117 * 78.84375f;
      float _119 = exp2(_118);
      _121 = _101;
      _122 = _110;
      _123 = _119;
#endif
    } else {
      _121 = _13.x;
      _122 = _13.y;
      _123 = _13.z;
    }
  }
  SV_Target.x = _121;
  SV_Target.y = _122;
  SV_Target.z = _123;
  SV_Target.w = 1.0f;
  return SV_Target;
}
