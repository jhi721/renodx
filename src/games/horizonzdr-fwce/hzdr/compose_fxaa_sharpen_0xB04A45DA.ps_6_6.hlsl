// Scene compose pass — FXAA + sharpen (extra block gated Constant_204 & 4) variant.
// Decompiled from the game's DXIL. Flow: AA/edge blend -> exposure -> grade ->
// (flag&1 grain) -> (flag&2 rational compressor) -> gamma2 3D LUT -> (flag&4 highlight
// re-expansion + peak clamp) -> encode switch Constant_176.w (1=sRGB, 2=BT.2020+PQ).

#include "../common.hlsli"

Texture2D<uint> t0_space3 : register(t0, space3);

Texture2D<float> t1_space3 : register(t1, space3);

Texture2D<float> t2_space3 : register(t2, space3);

Texture2D<float3> t4_space3 : register(t4, space3);

Texture2D<float4> t5_space3 : register(t5, space3);

Texture2D<float3> t6_space3 : register(t6, space3);

Texture2D<float4> t7_space3 : register(t7, space3);

Texture2D<float3> t8_space3 : register(t8, space3);

Texture2D<float2> t10_space3 : register(t10, space3);

Buffer<float> t0_space5 : register(t0, space5);

Texture3D<float3> t1_space5 : register(t1, space5);

cbuffer cb0_space3 : register(b0, space3) {
  struct Scratch_PerView_Constants {
    struct ComposeStaticBindings_Constant {
      float2 ComposeStaticBindings_Constant_000;
      int2 ComposeStaticBindings_Constant_008;
    } Scratch_PerView_Constants_000;
  } Scratch_PerView_000 : packoffset(c000.x);
};

cbuffer cb0_space5 : register(b0, space5) {
  struct Scratch_PerBatch_Constants {
    struct ComposeDynamicBindings_Constant {
      float4 ComposeDynamicBindings_Constant_000;
      int ComposeDynamicBindings_Constant_016;
      float3 ComposeDynamicBindings_Constant_020;
      float4 ComposeDynamicBindings_Constant_032;
      float4 ComposeDynamicBindings_Constant_048;
      float2 ComposeDynamicBindings_Constant_064;
      float2 ComposeDynamicBindings_Constant_072;
      float4 ComposeDynamicBindings_Constant_080;
      int4 ComposeDynamicBindings_Constant_096;
      float4 ComposeDynamicBindings_Constant_112;
      float4 ComposeDynamicBindings_Constant_128;
      float4 ComposeDynamicBindings_Constant_144;
      float4 ComposeDynamicBindings_Constant_160;
      float4 ComposeDynamicBindings_Constant_176;
      float3 ComposeDynamicBindings_Constant_192;
      int ComposeDynamicBindings_Constant_204;
      float2 ComposeDynamicBindings_Constant_208;
      float ComposeDynamicBindings_Constant_216;
      float ComposeDynamicBindings_Constant_220;
      float ComposeDynamicBindings_Constant_224;
    } Scratch_PerBatch_Constants_000;
  } Scratch_PerBatch_000 : packoffset(c000.x);
};

SamplerState s0_space3 : register(s0, space3);

SamplerState s1_space3 : register(s1, space3);

SamplerState s2_space3 : register(s2, space3);

struct OutputSignature {
  float4 SV_Target : SV_Target;
  float SV_Target_1 : SV_Target1;
};

OutputSignature main(
  noperspective float4 SV_Position : SV_Position,
  linear float2 TEXCOORD : TEXCOORD
) {
  float4 SV_Target;
  float SV_Target_1;
  float _95 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.x * TEXCOORD.x;
  float _96 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.y * TEXCOORD.y;
  float _97 = _95 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.z;
  float _98 = _96 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.w;
  float _99 = max(TEXCOORD.x, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_128.x);
  float _100 = min(_99, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_128.z);
  float _101 = min(TEXCOORD.x, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_128.x);
  float _102 = max(_101, _100);
  float _103 = max(TEXCOORD.y, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_128.y);
  float _104 = min(_103, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_128.w);
  float _105 = min(TEXCOORD.y, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_128.y);
  float _106 = max(_105, _104);
  float _107 = max(TEXCOORD.x, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_144.x);
  float _108 = min(_107, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_144.z);
  float _109 = min(TEXCOORD.x, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_144.x);
  float _110 = max(_109, _108);
  float _111 = max(TEXCOORD.y, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_144.y);
  float _112 = min(_111, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_144.w);
  float _113 = min(TEXCOORD.y, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_144.y);
  float _114 = max(_113, _112);
  float3 _117 = t4_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
  uint _121 = uint(SV_Position.x);
  uint _122 = uint(SV_Position.y);
  float _123 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.z));
  float _124 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.w));
  float _125 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.x));
  float _126 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.y));
  int _127 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.x & 31;
  int _128 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.y & 31;
  uint _129 = _121 >> _127;
  uint _130 = _122 >> _128;
  float _131 = float((int)(_129));
  float _132 = float((int)(_130));
  float _133 = max(_131, _125);
  float _134 = min(_133, _123);
  float _135 = min(_131, _125);
  float _136 = max(_135, _134);
  float _137 = max(_132, _126);
  float _138 = min(_137, _124);
  float _139 = min(_132, _126);
  float _140 = max(_139, _138);
  int _141 = int(_136);
  int _142 = int(_140);
  uint _144 = t0_space3.Load(int3(_141, _142, 0));
  bool _146 = (_144.x == 0);
  int _184;
  float _188;
  float _205;
  float _261;
  float _274;
  float _277;
  float _455;
  float _456;
  float _457;
  float _497;
  float _498;
  float _499;
  float _632;
  float _633;
  float _634;
  float _711;
  float _712;
  float _713;
  float _820;
  float _828;
  float _829;
  float _830;
  float _857;
  float _869;
  float _935;
  float _936;
  float _937;
  [branch]
  if (!_146) {
    int _148 = _144.x & 536870912;
    bool _149 = (_148 == 0);
    if (!_149) {
      float4 _153 = t5_space3.Sample(s1_space3, float2(_102, _106));
      _497 = _153.x;
      _498 = _153.y;
      _499 = _153.z;
    } else {
      int _158 = _144.x & 268435456;
      bool _159 = (_158 == 0);
      if (!_159) {
        float3 _163 = t6_space3.Sample(s1_space3, float2(_102, _106));
        _497 = _163.x;
        _498 = _163.y;
        _499 = _163.z;
      } else {
        float _169 = t1_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
        float _171 = _169.x * 12.0f;
        int _172 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204 & 512;
        bool _173 = (_172 == 0);
        if (!_173) {
          int _175 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204 & 1024;
          bool _176 = (_175 != 0);
          float _177 = select(_176, 1.0f, 3.0f);
          bool _178 = (_175 == 0);
          if (_178) {
            int _180 = (uint)((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204)) >> 7;
            int _181 = _180 & 2;
            int _182 = _181 ^ 6;
            _184 = _182;
          } else {
            _184 = 45;
          }
          float _185 = float((uint)_184);
          float _186 = _185 * _177;
          _188 = _186;
        } else {
          _188 = 63.0f;
        }
        float _189 = -0.0f - _188;
        float _190 = max(_171, _189);
        float _191 = min(_190, _188);
        float _192 = min(_171, _189);
        float _193 = max(_192, _191);
        float _196 = t2_space3.Sample(s1_space3, float2(_102, _106));
        int _198 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204 & 4;
        bool _199 = (_198 == 0);
        if (!_199) {
          float _201 = -0.0f - _193;
          float _202 = saturate(_201);
          float _203 = max(_202, _196.x);
          _205 = _203;
        } else {
          _205 = _196.x;
        }
        int _206 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204 & 2097152;
        bool _207 = (_206 != 0);
        float _208 = select(_207, 0.5f, 3.0f);
        float _209 = _193 - _208;
        float _210 = saturate(_209);
        float _211 = _210 * 2.0f;
        float _212 = 3.0f - _211;
        float _213 = _210 * _210;
        float _214 = _213 * _212;
        float _215 = TEXCOORD.y - Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.y;
        float _216 = max(TEXCOORD.x, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
        float _217 = min(_216, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.z);
        float _218 = min(TEXCOORD.x, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
        float _219 = max(_218, _217);
        float _220 = max(_215, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
        float _221 = min(_220, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.w);
        float _222 = min(_215, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
        float _223 = max(_222, _221);
        float _224 = t1_space3.Sample(s0_space3, float2(_219, _223));
        float _226 = min(_169.x, _224.x);
        float _227 = TEXCOORD.x - Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.x;
        float _228 = max(_227, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
        float _229 = min(_228, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.z);
        float _230 = min(_227, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
        float _231 = max(_230, _229);
        float _232 = max(TEXCOORD.y, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
        float _233 = min(_232, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.w);
        float _234 = min(TEXCOORD.y, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
        float _235 = max(_234, _233);
        float _236 = t1_space3.Sample(s0_space3, float2(_231, _235));
        float _238 = min(_226, _236.x);
        float _239 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.x + TEXCOORD.x;
        float _240 = max(_239, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
        float _241 = min(_240, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.z);
        float _242 = min(_239, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
        float _243 = max(_242, _241);
        float _244 = t1_space3.Sample(s0_space3, float2(_243, _235));
        float _246 = min(_238, _244.x);
        float _247 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.y + TEXCOORD.y;
        float _248 = max(_247, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
        float _249 = min(_248, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.w);
        float _250 = min(_247, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
        float _251 = max(_250, _249);
        float _252 = t1_space3.Sample(s0_space3, float2(_219, _251));
        float _254 = min(_246, _252.x);
        bool _255 = (_254 < 0.0f);
        if (_255) {
          float _257 = -0.0f - _254;
          _261 = _257;
        } else {
          float _259 = max(_254, _169.x);
          _261 = _259;
        }
        float _262 = _261 * 12.0f;
        if (!_173) {
          int _264 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204 & 1024;
          bool _265 = (_264 != 0);
          float _266 = select(_265, 1.0f, 3.0f);
          bool _267 = (_264 == 0);
          if (_267) {
            int _269 = (uint)((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204)) >> 7;
            int _270 = _269 & 2;
            int _271 = _270 ^ 6;
            float _272 = float((uint)_271);
            _274 = _272;
          } else {
            _274 = 45.0f;
          }
          float _275 = _274 * _266;
          _277 = _275;
        } else {
          _277 = 63.0f;
        }
        float _278 = -0.0f - _277;
        float _279 = max(_262, _278);
        float _280 = min(_279, _277);
        float _281 = min(_262, _278);
        float _282 = max(_281, _280);
        float _283 = _282 * 2.0f;
        int _284 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_204 & 524288;
        bool _285 = (_284 != 0);
        bool _286 = (_283 > 0.25f);
        bool _287 = _285 && _286;
        bool _288 = (_205 < 1.0f);
        bool _289 = _288 && _287;
        bool _290 = (_214 < 1.0f);
        bool _291 = _290 && _289;
        if (_291) {
          float _293 = min(_283, 4.0f);
          float _294 = _293 * Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.x;
          float _295 = _293 * Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.y;
          float _296 = max(_117.x, 1.000000013351432e-10f);
          float _297 = max(_117.y, 1.000000013351432e-10f);
          float _298 = max(_117.z, 1.000000013351432e-10f);
          float _299 = log2(_296);
          float _300 = log2(_297);
          float _301 = log2(_298);
          float _302 = _295 + TEXCOORD.y;
          float _303 = max(_302, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _304 = min(_303, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.w);
          float _305 = min(_302, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _306 = max(_305, _304);
          float3 _307 = t4_space3.SampleLevel(s1_space3, float2(_219, _306), 0.0f);
          float _311 = max(_307.x, 1.000000013351432e-10f);
          float _312 = max(_307.y, 1.000000013351432e-10f);
          float _313 = max(_307.z, 1.000000013351432e-10f);
          float _314 = log2(_311);
          float _315 = log2(_312);
          float _316 = log2(_313);
          float _317 = _314 + _299;
          float _318 = _315 + _300;
          float _319 = _316 + _301;
          float _320 = _294 * 0.7071067690849304f;
          float _321 = _295 * 0.7071067690849304f;
          float _322 = _320 + TEXCOORD.x;
          float _323 = _321 + TEXCOORD.y;
          float _324 = max(_322, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _325 = min(_324, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.z);
          float _326 = min(_322, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _327 = max(_326, _325);
          float _328 = max(_323, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _329 = min(_328, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.w);
          float _330 = min(_323, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _331 = max(_330, _329);
          float3 _332 = t4_space3.SampleLevel(s1_space3, float2(_327, _331), 0.0f);
          float _336 = max(_332.x, 1.000000013351432e-10f);
          float _337 = max(_332.y, 1.000000013351432e-10f);
          float _338 = max(_332.z, 1.000000013351432e-10f);
          float _339 = log2(_336);
          float _340 = log2(_337);
          float _341 = log2(_338);
          float _342 = _317 + _339;
          float _343 = _318 + _340;
          float _344 = _319 + _341;
          float _345 = _294 + TEXCOORD.x;
          float _346 = max(_345, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _347 = min(_346, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.z);
          float _348 = min(_345, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _349 = max(_348, _347);
          float3 _350 = t4_space3.SampleLevel(s1_space3, float2(_349, _235), 0.0f);
          float _354 = max(_350.x, 1.000000013351432e-10f);
          float _355 = max(_350.y, 1.000000013351432e-10f);
          float _356 = max(_350.z, 1.000000013351432e-10f);
          float _357 = log2(_354);
          float _358 = log2(_355);
          float _359 = log2(_356);
          float _360 = _342 + _357;
          float _361 = _343 + _358;
          float _362 = _344 + _359;
          float _363 = TEXCOORD.y - _321;
          float _364 = max(_363, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _365 = min(_364, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.w);
          float _366 = min(_363, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _367 = max(_366, _365);
          float3 _368 = t4_space3.SampleLevel(s1_space3, float2(_327, _367), 0.0f);
          float _372 = max(_368.x, 1.000000013351432e-10f);
          float _373 = max(_368.y, 1.000000013351432e-10f);
          float _374 = max(_368.z, 1.000000013351432e-10f);
          float _375 = log2(_372);
          float _376 = log2(_373);
          float _377 = log2(_374);
          float _378 = _360 + _375;
          float _379 = _361 + _376;
          float _380 = _362 + _377;
          float _381 = TEXCOORD.y - _295;
          float _382 = max(_381, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _383 = min(_382, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.w);
          float _384 = min(_381, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.y);
          float _385 = max(_384, _383);
          float3 _386 = t4_space3.SampleLevel(s1_space3, float2(_219, _385), 0.0f);
          float _390 = max(_386.x, 1.000000013351432e-10f);
          float _391 = max(_386.y, 1.000000013351432e-10f);
          float _392 = max(_386.z, 1.000000013351432e-10f);
          float _393 = log2(_390);
          float _394 = log2(_391);
          float _395 = log2(_392);
          float _396 = _378 + _393;
          float _397 = _379 + _394;
          float _398 = _380 + _395;
          float _399 = TEXCOORD.x - _320;
          float _400 = max(_399, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _401 = min(_400, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.z);
          float _402 = min(_399, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _403 = max(_402, _401);
          float3 _404 = t4_space3.SampleLevel(s1_space3, float2(_403, _367), 0.0f);
          float _408 = max(_404.x, 1.000000013351432e-10f);
          float _409 = max(_404.y, 1.000000013351432e-10f);
          float _410 = max(_404.z, 1.000000013351432e-10f);
          float _411 = log2(_408);
          float _412 = log2(_409);
          float _413 = log2(_410);
          float _414 = _396 + _411;
          float _415 = _397 + _412;
          float _416 = _398 + _413;
          float _417 = TEXCOORD.x - _294;
          float _418 = max(_417, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _419 = min(_418, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.z);
          float _420 = min(_417, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_112.x);
          float _421 = max(_420, _419);
          float3 _422 = t4_space3.SampleLevel(s1_space3, float2(_421, _235), 0.0f);
          float _426 = max(_422.x, 1.000000013351432e-10f);
          float _427 = max(_422.y, 1.000000013351432e-10f);
          float _428 = max(_422.z, 1.000000013351432e-10f);
          float _429 = log2(_426);
          float _430 = log2(_427);
          float _431 = log2(_428);
          float _432 = _414 + _429;
          float _433 = _415 + _430;
          float _434 = _416 + _431;
          float3 _435 = t4_space3.SampleLevel(s1_space3, float2(_403, _331), 0.0f);
          float _439 = max(_435.x, 1.000000013351432e-10f);
          float _440 = max(_435.y, 1.000000013351432e-10f);
          float _441 = max(_435.z, 1.000000013351432e-10f);
          float _442 = log2(_439);
          float _443 = log2(_440);
          float _444 = log2(_441);
          float _445 = _432 + _442;
          float _446 = _433 + _443;
          float _447 = _434 + _444;
          float _448 = _445 * 0.1111111119389534f;
          float _449 = _446 * 0.1111111119389534f;
          float _450 = _447 * 0.1111111119389534f;
          float _451 = exp2(_448);
          float _452 = exp2(_449);
          float _453 = exp2(_450);
          _455 = _451;
          _456 = _452;
          _457 = _453;
        } else {
          _455 = _117.x;
          _456 = _117.y;
          _457 = _117.z;
        }
        float3 _459 = t6_space3.Sample(s1_space3, float2(_102, _106));
        float _463 = _459.x - _455;
        float _464 = _459.y - _456;
        float _465 = _459.z - _457;
        float _466 = _463 * _214;
        float _467 = _464 * _214;
        float _468 = _465 * _214;
        float _469 = _466 + _455;
        float _470 = _467 + _456;
        float _471 = _468 + _457;
        float4 _473 = t5_space3.Sample(s0_space3, float2(_102, _106));
        bool _477 = (_473.x > 0.0f);
        bool _478 = (_473.y > 0.0f);
        bool _479 = (_473.z > 0.0f);
        bool _480 = _477 || _478;
        bool _481 = _479 || _480;
        if (_481) {
          float4 _483 = t5_space3.Sample(s1_space3, float2(_102, _106));
          float _487 = _483.x - _469;
          float _488 = _483.y - _470;
          float _489 = _483.z - _471;
          float _490 = _487 * _205;
          float _491 = _488 * _205;
          float _492 = _489 * _205;
          float _493 = _490 + _469;
          float _494 = _491 + _470;
          float _495 = _492 + _471;
          _497 = _493;
          _498 = _494;
          _499 = _495;
        } else {
          _497 = _469;
          _498 = _470;
          _499 = _471;
        }
      }
    }
  } else {
    _497 = _117.x;
    _498 = _117.y;
    _499 = _117.z;
  }
  float _501 = t0_space5.Load(2);
  float4 _505 = t7_space3.Sample(s1_space3, float2(_110, _114));
  float3 _510 = t8_space3.Sample(s1_space3, float2(_102, _106));
  float _514 = _505.x * _505.x;
  float _515 = _505.y * _505.y;
  float _516 = _505.z * _505.z;
  float _517 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.y * 0.25f;
  float _518 = _497 * _517;
  float _519 = _498 * _517;
  float _520 = _499 * _517;
  float _521 = dot(float3(_518, _519, _520), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _522 = _521 + 9.999999974752427e-07f;
  float _523 = saturate(_522);
  float _524 = 1.0f - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _525 = _523 * _524;
  float _526 = _525 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _527 = max(_518, 0.0f);
  float _528 = max(_519, 0.0f);
  float _529 = max(_520, 0.0f);
  float _530 = log2(_527);
  float _531 = log2(_528);
  float _532 = log2(_529);
  float _533 = _530 * _526;
  float _534 = _531 * _526;
  float _535 = _532 * _526;
  float _536 = exp2(_533);
  float _537 = exp2(_534);
  float _538 = exp2(_535);
  float _539 = _536 / _517;
  float _540 = _537 / _517;
  float _541 = _538 / _517;
  float _542 = _539 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _543 = _540 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _544 = _541 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _545 = _514 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _546 = _515 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _547 = _516 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _548 = _501.x * 4.0f;
  float _549 = _501.x + 0.25f;
  float _550 = _548 / _549;
  float _551 = _545 * _542;
  float _552 = _546 * _543;
  float _553 = _547 * _544;
  float _554 = max(_501.x, 1.0000000031710769e-30f);
  float _555 = _551 / _554;
  float _556 = _552 / _554;
  float _557 = _553 / _554;
  float _558 = sqrt(_555);
  float _559 = sqrt(_556);
  float _560 = sqrt(_557);
  float _561 = _558 * _550;
  float _562 = _559 * _550;
  float _563 = _560 * _550;
  float _564 = _501.x + 1.0f;
  float _565 = _564 + _550;
  float _566 = 1.0f / _565;
  float _567 = _545 + _542;
  float _568 = _567 + _561;
  float _569 = _566 * _568;
  float _570 = _546 + _543;
  float _571 = _570 + _562;
  float _572 = _571 * _566;
  float _573 = _547 + _544;
  float _574 = _573 + _563;
  float _575 = _574 * _566;
  float _576 = dot(float3(_510.x, _510.y, _510.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _577 = _510.x - _576;
  float _578 = _510.y - _576;
  float _579 = _510.z - _576;
  float _580 = _577 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _581 = _578 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _582 = _579 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _583 = _580 + _576;
  float _584 = _581 + _576;
  float _585 = _582 + _576;
  float _586 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.x;
  float _587 = _586 * _583;
  float _588 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.y;
  float _589 = _588 * _584;
  float _590 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.z;
  float _591 = _590 * _585;
  float _592 = _587 + _569;
  float _593 = _589 + _572;
  float _594 = _591 + _575;
  float _595 = _592 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.x;
  float _596 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.x - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.y;
  float _597 = _593 * _596;
  float _598 = _595 + _597;
  float _599 = _598 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _600 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.y;
  float _601 = _600 * _593;
  float _602 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.z;
  float _603 = _602 * _594;
  int _604 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 1;
  bool _605 = (_604 == 0);
  [branch]
  if (!_605) {
    int _608 = asint(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.z);
    int _609 = _608 & 65535;
    float _610 = float((uint)_609);
    float _611 = _610 * 1.52587890625e-05f;
    int _612 = (uint)(_608) >> 16;
    float _613 = float((uint)_612);
    float _614 = _613 * 1.52587890625e-05f;
    float _615 = _97 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.x;
    float _616 = _98 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.y;
    float _617 = _615 + _611;
    float _618 = _616 + _614;
    float2 _621 = t10_space3.Sample(s2_space3, float2(_617, _618));
    float _623 = _621.y + -0.5f;
    float _624 = _623 * _505.w;
    float _625 = _624 + _599;
    float _626 = _624 + _601;
    float _627 = _624 + _603;
    float _628 = max(_625, 0.0f);
    float _629 = max(_626, 0.0f);
    float _630 = max(_627, 0.0f);
    _632 = _628;
    _633 = _629;
    _634 = _630;
  } else {
    _632 = _599;
    _633 = _601;
    _634 = _603;
  }
  float _635 = _566 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _636 = _635 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.x;
  float _637 = _635 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.y;
  float _638 = _635 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.z;
  float _639 = _97 * 2.0f;
  float _640 = _98 * 2.0f;
  float _641 = _639 + -1.0f;
  float _642 = _640 + -1.0f;
  float _643 = _641 * _641;
  float _644 = _642 * _642;
  float _645 = _644 + _643;
  float _646 = sqrt(_645);
  float _647 = _646 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_064.x;
  float _648 = _647 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_064.y;
  float _649 = saturate(_648);
  float _650 = _649 * _649;
  float _651 = _650 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.w;
  _651 *= injectedData.fx_vignette;  // RenoDX vignette strength, 1.0 = vanilla
  float _652 = 1.0f - _651;
  float _653 = _652 * _632;
  float _654 = _652 * _633;
  float _655 = _652 * _634;
  float _656 = _636 * _651;
  float _657 = _637 * _651;
  float _658 = _638 * _651;
  float _659 = _653 + _656;
  float _660 = _654 + _657;
  float _661 = _655 + _658;
  float _662 = max(_659, 9.999999974752427e-07f);
  float _663 = max(_660, 9.999999974752427e-07f);
  float _664 = max(_661, 9.999999974752427e-07f);
  float _665 = dot(float3(_662, _663, _664), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  int _666 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 2;
  bool _667 = (_666 == 0);
  if (!_667) {
    float _669 = max(_662, 0.0f);
    float _670 = max(_663, 0.0f);
    float _671 = max(_664, 0.0f);
    float _672 = _669 * 0.9455959796905518f;
    float _673 = mad(0.045505501329898834f, _670, _672);
    float _674 = mad(0.008898990228772163f, _671, _673);
    float _675 = _669 * 0.014694600366055965f;
    float _676 = mad(0.967956006526947f, _670, _675);
    float _677 = mad(0.017349300906062126f, _671, _676);
    float _678 = _669 * 0.005567430052906275f;
    float _679 = mad(0.020142799243330956f, _670, _678);
    float _680 = mad(0.9742900133132935f, _671, _679);
    float _681 = dot(float3(0.21321800351142883f, 0.7275890111923218f, 0.059193599969148636f), float3(_674, _677, _680));
    float _682 = _681 + 1.0f;
    float _683 = _682 * _674;
    float _684 = _682 * _677;
    float _685 = _682 * _680;
    float _686 = _683 + 1.0f;
    float _687 = _684 + 1.0f;
    float _688 = _685 + 1.0f;
    float _689 = _686 * _674;
    float _690 = _687 * _677;
    float _691 = _688 * _680;
    float _692 = _689 + _682;
    float _693 = _690 + _682;
    float _694 = _691 + _682;
    float _695 = _689 / _692;
    float _696 = _690 / _693;
    float _697 = _691 / _694;
    float _698 = _695 * 1.058359980583191f;
    float _699 = mad(-0.049572598189115524f, _696, _698);
    float _700 = mad(-0.008784100413322449f, _697, _699);
    float _701 = _695 * -0.015964500606060028f;
    float _702 = mad(1.0342400074005127f, _696, _701);
    float _703 = mad(-0.01827090047299862f, _697, _702);
    float _704 = _695 * -0.00571777019649744f;
    float _705 = mad(-0.021098900586366653f, _696, _704);
    float _706 = mad(1.0268199443817139f, _697, _705);
    float _707 = max(_700, 0.0f);
    float _708 = max(_703, 0.0f);
    float _709 = max(_706, 0.0f);
    _711 = _707;
    _712 = _708;
    _713 = _709;
  } else {
    _711 = _662;
    _712 = _663;
    _713 = _664;
  }
  float _714 = dot(float3(_711, _712, _713), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _715 = max(_711, 0.0f);
  float _716 = max(_712, 0.0f);
  float _717 = max(_713, 0.0f);
  float _718 = sqrt(_715);
  float _719 = sqrt(_716);
  float _720 = sqrt(_717);
  float _721 = saturate(_718);
  float _722 = saturate(_719);
  float _723 = saturate(_720);
  float _724 = _721 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _725 = _722 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _726 = _723 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _727 = _724 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float _728 = _725 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float _729 = _726 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float3 _731 = t1_space5.SampleLevel(s1_space3, float3(_727, _728, _729), 0.0f);
  float _735 = _731.x * _731.x;
  float _736 = _731.y * _731.y;
  float _737 = _731.z * _731.z;
  float _738 = _714 + 9.999999960041972e-13f;
  float _739 = _665 / _738;
  float _740 = max(_739, 0.0f);
  float _741 = _740 + -1.0f;
  float _742 = _741 * 0.03999999910593033f;
  float _743 = saturate(_742);
  float _744 = dot(float3(_735, _736, _737), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _745 = _744 * 8.0f;
  float _746 = _745 + -4.0f;
  float _747 = saturate(_746);
  float _748 = _747 * _743;
  float _749 = saturate(_735);
  float _750 = saturate(_736);
  float _751 = saturate(_737);
  int _752 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 4;
  bool _753 = (_752 == 0);
  [branch]
  if (!_753) {
    float _755 = _749 * _749;
    float _756 = _750 * _750;
    float _757 = _751 * _751;
    float _758 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _759 = _755 + _758;
    float _760 = _756 + _758;
    float _761 = _757 + _758;
    float _762 = sqrt(_759);
    float _763 = sqrt(_760);
    float _764 = sqrt(_761);
    float _765 = _762 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _766 = _763 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _767 = _764 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _768 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220 + 1.0f;
    float _769 = _765 * _768;
    float _770 = _766 * _768;
    float _771 = _767 * _768;
    float _772 = max(1.0f, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_216);
    float _773 = dot(float3(_769, _770, _771), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    float _774 = saturate(_773);
    float _775 = _774 + -0.5f;
    float _776 = saturate(_775);
    float _777 = _774 * 0.5f;
    float _778 = 1.0f - _777;
    float _779 = 1.0f / _778;
    float _780 = _748 * 100.0f;
    float _781 = _776 * _776;
    float _782 = _781 * _780;
    float _783 = _782 + _779;
    float _784 = _783 * _774;
    float _785 = _772 + -1.0f;
    float _786 = _784 - _774;
    float _787 = max(0.0f, _786);
    float _788 = _785 * 0.03846153989434242f;
    float _789 = _788 * _787;
    float _790 = _789 + _774;
    float _791 = max(_774, 9.999999717180685e-10f);
    float _792 = 1.0f / _791;
    float _793 = _792 * _769;
    float _794 = _792 * _770;
    float _795 = _792 * _771;
    float _796 = _790 * _792;
    float _797 = max(9.999999717180685e-10f, _796);
    float _798 = abs(_793);
    float _799 = abs(_794);
    float _800 = abs(_795);
    float _801 = log2(_798);
    float _802 = log2(_799);
    float _803 = log2(_800);
    float _804 = _801 * _797;
    float _805 = _802 * _797;
    float _806 = _803 * _797;
    float _807 = exp2(_804);
    float _808 = exp2(_805);
    float _809 = exp2(_806);
    float _810 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224;
    float _811 = _810 * 0.03125f;
    bool _812 = (_790 > _811);
    if (_812) {
      float _814 = _811 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224;
      float _815 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224 - _811;
      float _816 = _815 + _790;
      float _817 = _810 / _816;
      float _818 = _814 - _817;
      _820 = _818;
    } else {
      _820 = _790;
    }
    float _821 = _820 * _807;
    float _822 = _820 * _808;
    float _823 = _820 * _809;
    float _824 = min(_821, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    float _825 = min(_822, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    float _826 = min(_823, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    _828 = _824;
    _829 = _825;
    _830 = _826;
  } else {
    _828 = _749;
    _829 = _750;
    _830 = _751;
  }
  int _831 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.w);
  bool _832 = (_831 == 1);
  [branch]
  if (_832) {
    float _834 = abs(_828);
    float _835 = abs(_829);
    float _836 = abs(_830);
    float _837 = log2(_834);
    float _838 = log2(_835);
    float _839 = log2(_836);
    float _840 = _837 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _841 = _838 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _842 = _839 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _843 = exp2(_840);
    float _844 = exp2(_841);
    float _845 = exp2(_842);
    bool _846 = (_843 < 0.003100000089034438f);
    if (_846) {
      float _848 = _843 * 12.920000076293945f;
      _857 = _848;
    } else {
      float _850 = abs(_843);
      float _851 = log2(_850);
      float _852 = _851 * 0.4166666567325592f;
      float _853 = exp2(_852);
      float _854 = _853 * 1.0549999475479126f;
      float _855 = _854 + -0.054999999701976776f;
      _857 = _855;
    }
    bool _858 = (_844 < 0.003100000089034438f);
    if (_858) {
      float _860 = _844 * 12.920000076293945f;
      _869 = _860;
    } else {
      float _862 = abs(_844);
      float _863 = log2(_862);
      float _864 = _863 * 0.4166666567325592f;
      float _865 = exp2(_864);
      float _866 = _865 * 1.0549999475479126f;
      float _867 = _866 + -0.054999999701976776f;
      _869 = _867;
    }
    bool _870 = (_845 < 0.003100000089034438f);
    if (_870) {
      float _872 = _845 * 12.920000076293945f;
      _935 = _857;
      _936 = _869;
      _937 = _872;
    } else {
      float _874 = abs(_845);
      float _875 = log2(_874);
      float _876 = _875 * 0.4166666567325592f;
      float _877 = exp2(_876);
      float _878 = _877 * 1.0549999475479126f;
      float _879 = _878 + -0.054999999701976776f;
      _935 = _857;
      _936 = _869;
      _937 = _879;
    }
  } else {
    bool _881 = (_831 == 2);
    if (_881) {
#if 1
      // renodx
      float3 vanilla_plus = ApplyRenoDXSceneOutput(
          float3(_662, _663, _664),
          float3(_749, _750, _751),
          _748,
          !_667,
          !_753,
          t1_space5, s1_space3,
          Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x,
          Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y);
      _935 = vanilla_plus.r;
      _936 = vanilla_plus.g;
      _937 = vanilla_plus.b;
#else
      // vanilla
      float _883 = _828 * 0.6274039149284363f;
      float _884 = mad(0.3292830288410187f, _829, _883);
      float _885 = mad(0.04331306740641594f, _830, _884);
      float _886 = _828 * 0.06909728795289993f;
      float _887 = mad(0.9195404052734375f, _829, _886);
      float _888 = mad(0.011362316086888313f, _830, _887);
      float _889 = _828 * 0.016391439363360405f;
      float _890 = mad(0.08801330626010895f, _829, _889);
      float _891 = mad(0.8955952525138855f, _830, _890);
      float _892 = _885 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _893 = _888 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _894 = _891 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _895 = abs(_892);
      float _896 = abs(_893);
      float _897 = abs(_894);
      float _898 = log2(_895);
      float _899 = log2(_896);
      float _900 = log2(_897);
      float _901 = _898 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _902 = _899 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _903 = _900 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _904 = exp2(_901);
      float _905 = exp2(_902);
      float _906 = exp2(_903);
      float _907 = _904 * 18.8515625f;
      float _908 = _907 + 0.8359375f;
      float _909 = _904 * 18.6875f;
      float _910 = _909 + 1.0f;
      float _911 = _908 / _910;
      float _912 = abs(_911);
      float _913 = log2(_912);
      float _914 = _913 * 78.84375f;
      float _915 = exp2(_914);
      float _916 = _905 * 18.8515625f;
      float _917 = _916 + 0.8359375f;
      float _918 = _905 * 18.6875f;
      float _919 = _918 + 1.0f;
      float _920 = _917 / _919;
      float _921 = abs(_920);
      float _922 = log2(_921);
      float _923 = _922 * 78.84375f;
      float _924 = exp2(_923);
      float _925 = _906 * 18.8515625f;
      float _926 = _925 + 0.8359375f;
      float _927 = _906 * 18.6875f;
      float _928 = _927 + 1.0f;
      float _929 = _926 / _928;
      float _930 = abs(_929);
      float _931 = log2(_930);
      float _932 = _931 * 78.84375f;
      float _933 = exp2(_932);
      _935 = _915;
      _936 = _924;
      _937 = _933;
#endif
    } else {
      _935 = _828;
      _936 = _829;
      _937 = _830;
    }
  }
  SV_Target.x = _935;
  SV_Target.y = _936;
  SV_Target.z = _937;
  SV_Target.w = _748;
  float _938 = dot(float3(_935, _936, _937), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  SV_Target_1 = _938;
  OutputSignature output_signature = { SV_Target, SV_Target_1 };
  return output_signature;
}
