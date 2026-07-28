// Scene compose pass — FXAA variant.
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
  float _78 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.x * TEXCOORD.x;
  float _79 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.y * TEXCOORD.y;
  float _80 = _78 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.z;
  float _81 = _79 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.w;
  float3 _84 = t4_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
  uint _88 = uint(SV_Position.x);
  uint _89 = uint(SV_Position.y);
  float _90 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.z));
  float _91 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.w));
  float _92 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.x));
  float _93 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.y));
  int _94 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.x & 31;
  int _95 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.y & 31;
  uint _96 = _88 >> _94;
  uint _97 = _89 >> _95;
  float _98 = float((int)(_96));
  float _99 = float((int)(_97));
  float _100 = max(_98, _92);
  float _101 = min(_100, _90);
  float _102 = min(_98, _92);
  float _103 = max(_102, _101);
  float _104 = max(_99, _93);
  float _105 = min(_104, _91);
  float _106 = min(_99, _93);
  float _107 = max(_106, _105);
  int _108 = int(_103);
  int _109 = int(_107);
  uint _111 = t0_space3.Load(int3(_108, _109, 0));
  bool _113 = (_111.x == 0);
  float _176;
  float _319;
  float _320;
  float _321;
  float _361;
  float _362;
  float _363;
  float _496;
  float _497;
  float _498;
  float _575;
  float _576;
  float _577;
  float _684;
  float _692;
  float _693;
  float _694;
  float _721;
  float _733;
  float _799;
  float _800;
  float _801;
  [branch]
  if (!_113) {
    int _115 = _111.x & 536870912;
    bool _116 = (_115 == 0);
    if (!_116) {
      float4 _120 = t5_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
      _361 = _120.x;
      _362 = _120.y;
      _363 = _120.z;
    } else {
      int _125 = _111.x & 268435456;
      bool _126 = (_125 == 0);
      if (!_126) {
        float3 _129 = t6_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
        _361 = _129.x;
        _362 = _129.y;
        _363 = _129.z;
      } else {
        float _135 = t1_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
        float _137 = _135.x * 12.0f;
        float _138 = max(_137, -18.0f);
        float _139 = min(_138, 18.0f);
        float _140 = min(_137, -18.0f);
        float _141 = max(_140, _139);
        float _143 = t2_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
        float _145 = -0.0f - _141;
        float _146 = saturate(_145);
        float _147 = max(_146, _143.x);
        float _148 = _141 + -0.5f;
        float _149 = saturate(_148);
        float _150 = _149 * 2.0f;
        float _151 = 3.0f - _150;
        float _152 = _149 * _149;
        float _153 = _152 * _151;
        float _154 = TEXCOORD.y - Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.y;
        float _155 = t1_space3.Sample(s0_space3, float2(TEXCOORD.x, _154));
        float _157 = min(_135.x, _155.x);
        float _158 = TEXCOORD.x - Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.x;
        float _159 = t1_space3.Sample(s0_space3, float2(_158, TEXCOORD.y));
        float _161 = min(_157, _159.x);
        float _162 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.x + TEXCOORD.x;
        float _163 = t1_space3.Sample(s0_space3, float2(_162, TEXCOORD.y));
        float _165 = min(_161, _163.x);
        float _166 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.y + TEXCOORD.y;
        float _167 = t1_space3.Sample(s0_space3, float2(TEXCOORD.x, _166));
        float _169 = min(_165, _167.x);
        bool _170 = (_169 < 0.0f);
        if (_170) {
          float _172 = -0.0f - _169;
          _176 = _172;
        } else {
          float _174 = max(_169, _135.x);
          _176 = _174;
        }
        float _177 = _176 * 12.0f;
        float _178 = max(_177, -18.0f);
        float _179 = min(_178, 18.0f);
        float _180 = min(_177, -18.0f);
        float _181 = max(_180, _179);
        float _182 = _181 * 2.0f;
        bool _183 = (_182 > 0.25f);
        bool _184 = (_147 < 1.0f);
        bool _185 = _184 && _183;
        bool _186 = (_153 < 1.0f);
        bool _187 = _186 && _185;
        if (_187) {
          float _189 = min(_182, 4.0f);
          float _190 = _189 * Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.x;
          float _191 = _189 * Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_000.y;
          float _192 = max(_84.x, 1.000000013351432e-10f);
          float _193 = max(_84.y, 1.000000013351432e-10f);
          float _194 = max(_84.z, 1.000000013351432e-10f);
          float _195 = log2(_192);
          float _196 = log2(_193);
          float _197 = log2(_194);
          float _198 = _191 + TEXCOORD.y;
          float3 _199 = t4_space3.SampleLevel(s1_space3, float2(TEXCOORD.x, _198), 0.0f);
          float _203 = max(_199.x, 1.000000013351432e-10f);
          float _204 = max(_199.y, 1.000000013351432e-10f);
          float _205 = max(_199.z, 1.000000013351432e-10f);
          float _206 = log2(_203);
          float _207 = log2(_204);
          float _208 = log2(_205);
          float _209 = _206 + _195;
          float _210 = _207 + _196;
          float _211 = _208 + _197;
          float _212 = _190 * 0.7071067690849304f;
          float _213 = _191 * 0.7071067690849304f;
          float _214 = _212 + TEXCOORD.x;
          float _215 = _213 + TEXCOORD.y;
          float3 _216 = t4_space3.SampleLevel(s1_space3, float2(_214, _215), 0.0f);
          float _220 = max(_216.x, 1.000000013351432e-10f);
          float _221 = max(_216.y, 1.000000013351432e-10f);
          float _222 = max(_216.z, 1.000000013351432e-10f);
          float _223 = log2(_220);
          float _224 = log2(_221);
          float _225 = log2(_222);
          float _226 = _209 + _223;
          float _227 = _210 + _224;
          float _228 = _211 + _225;
          float _229 = _190 + TEXCOORD.x;
          float3 _230 = t4_space3.SampleLevel(s1_space3, float2(_229, TEXCOORD.y), 0.0f);
          float _234 = max(_230.x, 1.000000013351432e-10f);
          float _235 = max(_230.y, 1.000000013351432e-10f);
          float _236 = max(_230.z, 1.000000013351432e-10f);
          float _237 = log2(_234);
          float _238 = log2(_235);
          float _239 = log2(_236);
          float _240 = _226 + _237;
          float _241 = _227 + _238;
          float _242 = _228 + _239;
          float _243 = TEXCOORD.y - _213;
          float3 _244 = t4_space3.SampleLevel(s1_space3, float2(_214, _243), 0.0f);
          float _248 = max(_244.x, 1.000000013351432e-10f);
          float _249 = max(_244.y, 1.000000013351432e-10f);
          float _250 = max(_244.z, 1.000000013351432e-10f);
          float _251 = log2(_248);
          float _252 = log2(_249);
          float _253 = log2(_250);
          float _254 = _240 + _251;
          float _255 = _241 + _252;
          float _256 = _242 + _253;
          float _257 = TEXCOORD.y - _191;
          float3 _258 = t4_space3.SampleLevel(s1_space3, float2(TEXCOORD.x, _257), 0.0f);
          float _262 = max(_258.x, 1.000000013351432e-10f);
          float _263 = max(_258.y, 1.000000013351432e-10f);
          float _264 = max(_258.z, 1.000000013351432e-10f);
          float _265 = log2(_262);
          float _266 = log2(_263);
          float _267 = log2(_264);
          float _268 = _254 + _265;
          float _269 = _255 + _266;
          float _270 = _256 + _267;
          float _271 = TEXCOORD.x - _212;
          float3 _272 = t4_space3.SampleLevel(s1_space3, float2(_271, _243), 0.0f);
          float _276 = max(_272.x, 1.000000013351432e-10f);
          float _277 = max(_272.y, 1.000000013351432e-10f);
          float _278 = max(_272.z, 1.000000013351432e-10f);
          float _279 = log2(_276);
          float _280 = log2(_277);
          float _281 = log2(_278);
          float _282 = _268 + _279;
          float _283 = _269 + _280;
          float _284 = _270 + _281;
          float _285 = TEXCOORD.x - _190;
          float3 _286 = t4_space3.SampleLevel(s1_space3, float2(_285, TEXCOORD.y), 0.0f);
          float _290 = max(_286.x, 1.000000013351432e-10f);
          float _291 = max(_286.y, 1.000000013351432e-10f);
          float _292 = max(_286.z, 1.000000013351432e-10f);
          float _293 = log2(_290);
          float _294 = log2(_291);
          float _295 = log2(_292);
          float _296 = _282 + _293;
          float _297 = _283 + _294;
          float _298 = _284 + _295;
          float3 _299 = t4_space3.SampleLevel(s1_space3, float2(_271, _215), 0.0f);
          float _303 = max(_299.x, 1.000000013351432e-10f);
          float _304 = max(_299.y, 1.000000013351432e-10f);
          float _305 = max(_299.z, 1.000000013351432e-10f);
          float _306 = log2(_303);
          float _307 = log2(_304);
          float _308 = log2(_305);
          float _309 = _296 + _306;
          float _310 = _297 + _307;
          float _311 = _298 + _308;
          float _312 = _309 * 0.1111111119389534f;
          float _313 = _310 * 0.1111111119389534f;
          float _314 = _311 * 0.1111111119389534f;
          float _315 = exp2(_312);
          float _316 = exp2(_313);
          float _317 = exp2(_314);
          _319 = _315;
          _320 = _316;
          _321 = _317;
        } else {
          _319 = _84.x;
          _320 = _84.y;
          _321 = _84.z;
        }
        float3 _323 = t6_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
        float _327 = _323.x - _319;
        float _328 = _323.y - _320;
        float _329 = _323.z - _321;
        float _330 = _327 * _153;
        float _331 = _328 * _153;
        float _332 = _329 * _153;
        float _333 = _330 + _319;
        float _334 = _331 + _320;
        float _335 = _332 + _321;
        float4 _337 = t5_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
        bool _341 = (_337.x > 0.0f);
        bool _342 = (_337.y > 0.0f);
        bool _343 = (_337.z > 0.0f);
        bool _344 = _341 || _342;
        bool _345 = _343 || _344;
        if (_345) {
          float4 _347 = t5_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
          float _351 = _347.x - _333;
          float _352 = _347.y - _334;
          float _353 = _347.z - _335;
          float _354 = _351 * _147;
          float _355 = _352 * _147;
          float _356 = _353 * _147;
          float _357 = _354 + _333;
          float _358 = _355 + _334;
          float _359 = _356 + _335;
          _361 = _357;
          _362 = _358;
          _363 = _359;
        } else {
          _361 = _333;
          _362 = _334;
          _363 = _335;
        }
      }
    }
  } else {
    _361 = _84.x;
    _362 = _84.y;
    _363 = _84.z;
  }
  float _365 = t0_space5.Load(2);
  float4 _369 = t7_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
  float3 _374 = t8_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
  float _378 = _369.x * _369.x;
  float _379 = _369.y * _369.y;
  float _380 = _369.z * _369.z;
  float _381 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.y * 0.25f;
  float _382 = _361 * _381;
  float _383 = _362 * _381;
  float _384 = _363 * _381;
  float _385 = dot(float3(_382, _383, _384), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _386 = _385 + 9.999999974752427e-07f;
  float _387 = saturate(_386);
  float _388 = 1.0f - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _389 = _387 * _388;
  float _390 = _389 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _391 = max(_382, 0.0f);
  float _392 = max(_383, 0.0f);
  float _393 = max(_384, 0.0f);
  float _394 = log2(_391);
  float _395 = log2(_392);
  float _396 = log2(_393);
  float _397 = _394 * _390;
  float _398 = _395 * _390;
  float _399 = _396 * _390;
  float _400 = exp2(_397);
  float _401 = exp2(_398);
  float _402 = exp2(_399);
  float _403 = _400 / _381;
  float _404 = _401 / _381;
  float _405 = _402 / _381;
  float _406 = _403 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _407 = _404 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _408 = _405 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _409 = _378 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _410 = _379 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _411 = _380 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _412 = _365.x * 4.0f;
  float _413 = _365.x + 0.25f;
  float _414 = _412 / _413;
  float _415 = _409 * _406;
  float _416 = _410 * _407;
  float _417 = _411 * _408;
  float _418 = max(_365.x, 1.0000000031710769e-30f);
  float _419 = _415 / _418;
  float _420 = _416 / _418;
  float _421 = _417 / _418;
  float _422 = sqrt(_419);
  float _423 = sqrt(_420);
  float _424 = sqrt(_421);
  float _425 = _422 * _414;
  float _426 = _423 * _414;
  float _427 = _424 * _414;
  float _428 = _365.x + 1.0f;
  float _429 = _428 + _414;
  float _430 = 1.0f / _429;
  float _431 = _409 + _406;
  float _432 = _431 + _425;
  float _433 = _430 * _432;
  float _434 = _410 + _407;
  float _435 = _434 + _426;
  float _436 = _435 * _430;
  float _437 = _411 + _408;
  float _438 = _437 + _427;
  float _439 = _438 * _430;
  float _440 = dot(float3(_374.x, _374.y, _374.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _441 = _374.x - _440;
  float _442 = _374.y - _440;
  float _443 = _374.z - _440;
  float _444 = _441 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _445 = _442 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _446 = _443 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _447 = _444 + _440;
  float _448 = _445 + _440;
  float _449 = _446 + _440;
  float _450 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.x;
  float _451 = _450 * _447;
  float _452 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.y;
  float _453 = _452 * _448;
  float _454 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.z;
  float _455 = _454 * _449;
  float _456 = _451 + _433;
  float _457 = _453 + _436;
  float _458 = _455 + _439;
  float _459 = _456 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.x;
  float _460 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.x - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.y;
  float _461 = _457 * _460;
  float _462 = _459 + _461;
  float _463 = _462 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _464 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.y;
  float _465 = _464 * _457;
  float _466 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.z;
  float _467 = _466 * _458;
  int _468 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 1;
  bool _469 = (_468 == 0);
  [branch]
  if (!_469) {
    int _472 = asint(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.z);
    int _473 = _472 & 65535;
    float _474 = float((uint)_473);
    float _475 = _474 * 1.52587890625e-05f;
    int _476 = (uint)(_472) >> 16;
    float _477 = float((uint)_476);
    float _478 = _477 * 1.52587890625e-05f;
    float _479 = _80 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.x;
    float _480 = _81 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.y;
    float _481 = _479 + _475;
    float _482 = _480 + _478;
    float2 _485 = t10_space3.Sample(s2_space3, float2(_481, _482));
    float _487 = _485.y + -0.5f;
    float _488 = _487 * _369.w;
    float _489 = _488 + _463;
    float _490 = _488 + _465;
    float _491 = _488 + _467;
    float _492 = max(_489, 0.0f);
    float _493 = max(_490, 0.0f);
    float _494 = max(_491, 0.0f);
    _496 = _492;
    _497 = _493;
    _498 = _494;
  } else {
    _496 = _463;
    _497 = _465;
    _498 = _467;
  }
  float _499 = _430 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _500 = _499 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.x;
  float _501 = _499 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.y;
  float _502 = _499 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.z;
  float _503 = _80 * 2.0f;
  float _504 = _81 * 2.0f;
  float _505 = _503 + -1.0f;
  float _506 = _504 + -1.0f;
  float _507 = _505 * _505;
  float _508 = _506 * _506;
  float _509 = _508 + _507;
  float _510 = sqrt(_509);
  float _511 = _510 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_064.x;
  float _512 = _511 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_064.y;
  float _513 = saturate(_512);
  float _514 = _513 * _513;
  float _515 = _514 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.w;
  _515 *= injectedData.fx_vignette;  // RenoDX vignette strength, 1.0 = vanilla
  float _516 = 1.0f - _515;
  float _517 = _516 * _496;
  float _518 = _516 * _497;
  float _519 = _516 * _498;
  float _520 = _500 * _515;
  float _521 = _501 * _515;
  float _522 = _502 * _515;
  float _523 = _517 + _520;
  float _524 = _518 + _521;
  float _525 = _519 + _522;
  float _526 = max(_523, 9.999999974752427e-07f);
  float _527 = max(_524, 9.999999974752427e-07f);
  float _528 = max(_525, 9.999999974752427e-07f);
  float _529 = dot(float3(_526, _527, _528), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  int _530 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 2;
  bool _531 = (_530 == 0);
  if (!_531) {
    float _533 = max(_526, 0.0f);
    float _534 = max(_527, 0.0f);
    float _535 = max(_528, 0.0f);
    float _536 = _533 * 0.9455959796905518f;
    float _537 = mad(0.045505501329898834f, _534, _536);
    float _538 = mad(0.008898990228772163f, _535, _537);
    float _539 = _533 * 0.014694600366055965f;
    float _540 = mad(0.967956006526947f, _534, _539);
    float _541 = mad(0.017349300906062126f, _535, _540);
    float _542 = _533 * 0.005567430052906275f;
    float _543 = mad(0.020142799243330956f, _534, _542);
    float _544 = mad(0.9742900133132935f, _535, _543);
    float _545 = dot(float3(0.21321800351142883f, 0.7275890111923218f, 0.059193599969148636f), float3(_538, _541, _544));
    float _546 = _545 + 1.0f;
    float _547 = _546 * _538;
    float _548 = _546 * _541;
    float _549 = _546 * _544;
    float _550 = _547 + 1.0f;
    float _551 = _548 + 1.0f;
    float _552 = _549 + 1.0f;
    float _553 = _550 * _538;
    float _554 = _551 * _541;
    float _555 = _552 * _544;
    float _556 = _553 + _546;
    float _557 = _554 + _546;
    float _558 = _555 + _546;
    float _559 = _553 / _556;
    float _560 = _554 / _557;
    float _561 = _555 / _558;
    float _562 = _559 * 1.058359980583191f;
    float _563 = mad(-0.049572598189115524f, _560, _562);
    float _564 = mad(-0.008784100413322449f, _561, _563);
    float _565 = _559 * -0.015964500606060028f;
    float _566 = mad(1.0342400074005127f, _560, _565);
    float _567 = mad(-0.01827090047299862f, _561, _566);
    float _568 = _559 * -0.00571777019649744f;
    float _569 = mad(-0.021098900586366653f, _560, _568);
    float _570 = mad(1.0268199443817139f, _561, _569);
    float _571 = max(_564, 0.0f);
    float _572 = max(_567, 0.0f);
    float _573 = max(_570, 0.0f);
    _575 = _571;
    _576 = _572;
    _577 = _573;
  } else {
    _575 = _526;
    _576 = _527;
    _577 = _528;
  }
  float _578 = dot(float3(_575, _576, _577), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _579 = max(_575, 0.0f);
  float _580 = max(_576, 0.0f);
  float _581 = max(_577, 0.0f);
  float _582 = sqrt(_579);
  float _583 = sqrt(_580);
  float _584 = sqrt(_581);
  float _585 = saturate(_582);
  float _586 = saturate(_583);
  float _587 = saturate(_584);
  float _588 = _585 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _589 = _586 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _590 = _587 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _591 = _588 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float _592 = _589 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float _593 = _590 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float3 _595 = t1_space5.SampleLevel(s1_space3, float3(_591, _592, _593), 0.0f);
  float _599 = _595.x * _595.x;
  float _600 = _595.y * _595.y;
  float _601 = _595.z * _595.z;
  float _602 = _578 + 9.999999960041972e-13f;
  float _603 = _529 / _602;
  float _604 = max(_603, 0.0f);
  float _605 = _604 + -1.0f;
  float _606 = _605 * 0.03999999910593033f;
  float _607 = saturate(_606);
  float _608 = dot(float3(_599, _600, _601), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _609 = _608 * 8.0f;
  float _610 = _609 + -4.0f;
  float _611 = saturate(_610);
  float _612 = _611 * _607;
  float _613 = saturate(_599);
  float _614 = saturate(_600);
  float _615 = saturate(_601);
  int _616 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 4;
  bool _617 = (_616 == 0);
  [branch]
  if (!_617) {
    float _619 = _613 * _613;
    float _620 = _614 * _614;
    float _621 = _615 * _615;
    float _622 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _623 = _619 + _622;
    float _624 = _620 + _622;
    float _625 = _621 + _622;
    float _626 = sqrt(_623);
    float _627 = sqrt(_624);
    float _628 = sqrt(_625);
    float _629 = _626 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _630 = _627 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _631 = _628 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _632 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220 + 1.0f;
    float _633 = _629 * _632;
    float _634 = _630 * _632;
    float _635 = _631 * _632;
    float _636 = max(1.0f, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_216);
    float _637 = dot(float3(_633, _634, _635), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    float _638 = saturate(_637);
    float _639 = _638 + -0.5f;
    float _640 = saturate(_639);
    float _641 = _638 * 0.5f;
    float _642 = 1.0f - _641;
    float _643 = 1.0f / _642;
    float _644 = _612 * 100.0f;
    float _645 = _640 * _640;
    float _646 = _645 * _644;
    float _647 = _646 + _643;
    float _648 = _647 * _638;
    float _649 = _636 + -1.0f;
    float _650 = _648 - _638;
    float _651 = max(0.0f, _650);
    float _652 = _649 * 0.03846153989434242f;
    float _653 = _652 * _651;
    float _654 = _653 + _638;
    float _655 = max(_638, 9.999999717180685e-10f);
    float _656 = 1.0f / _655;
    float _657 = _656 * _633;
    float _658 = _656 * _634;
    float _659 = _656 * _635;
    float _660 = _654 * _656;
    float _661 = max(9.999999717180685e-10f, _660);
    float _662 = abs(_657);
    float _663 = abs(_658);
    float _664 = abs(_659);
    float _665 = log2(_662);
    float _666 = log2(_663);
    float _667 = log2(_664);
    float _668 = _665 * _661;
    float _669 = _666 * _661;
    float _670 = _667 * _661;
    float _671 = exp2(_668);
    float _672 = exp2(_669);
    float _673 = exp2(_670);
    float _674 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224;
    float _675 = _674 * 0.03125f;
    bool _676 = (_654 > _675);
    if (_676) {
      float _678 = _675 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224;
      float _679 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224 - _675;
      float _680 = _679 + _654;
      float _681 = _674 / _680;
      float _682 = _678 - _681;
      _684 = _682;
    } else {
      _684 = _654;
    }
    float _685 = _684 * _671;
    float _686 = _684 * _672;
    float _687 = _684 * _673;
    float _688 = min(_685, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    float _689 = min(_686, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    float _690 = min(_687, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    _692 = _688;
    _693 = _689;
    _694 = _690;
  } else {
    _692 = _613;
    _693 = _614;
    _694 = _615;
  }
  int _695 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.w);
  bool _696 = (_695 == 1);
  [branch]
  if (_696) {
    float _698 = abs(_692);
    float _699 = abs(_693);
    float _700 = abs(_694);
    float _701 = log2(_698);
    float _702 = log2(_699);
    float _703 = log2(_700);
    float _704 = _701 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _705 = _702 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _706 = _703 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _707 = exp2(_704);
    float _708 = exp2(_705);
    float _709 = exp2(_706);
    bool _710 = (_707 < 0.003100000089034438f);
    if (_710) {
      float _712 = _707 * 12.920000076293945f;
      _721 = _712;
    } else {
      float _714 = abs(_707);
      float _715 = log2(_714);
      float _716 = _715 * 0.4166666567325592f;
      float _717 = exp2(_716);
      float _718 = _717 * 1.0549999475479126f;
      float _719 = _718 + -0.054999999701976776f;
      _721 = _719;
    }
    bool _722 = (_708 < 0.003100000089034438f);
    if (_722) {
      float _724 = _708 * 12.920000076293945f;
      _733 = _724;
    } else {
      float _726 = abs(_708);
      float _727 = log2(_726);
      float _728 = _727 * 0.4166666567325592f;
      float _729 = exp2(_728);
      float _730 = _729 * 1.0549999475479126f;
      float _731 = _730 + -0.054999999701976776f;
      _733 = _731;
    }
    bool _734 = (_709 < 0.003100000089034438f);
    if (_734) {
      float _736 = _709 * 12.920000076293945f;
      _799 = _721;
      _800 = _733;
      _801 = _736;
    } else {
      float _738 = abs(_709);
      float _739 = log2(_738);
      float _740 = _739 * 0.4166666567325592f;
      float _741 = exp2(_740);
      float _742 = _741 * 1.0549999475479126f;
      float _743 = _742 + -0.054999999701976776f;
      _799 = _721;
      _800 = _733;
      _801 = _743;
    }
  } else {
    bool _745 = (_695 == 2);
    if (_745) {
#if 1
      // renodx
      float3 vanilla_plus = ApplyRenoDXSceneOutput(
          float3(_526, _527, _528),
          float3(_613, _614, _615),
          _612,
          !_531,
          !_617,
          t1_space5, s1_space3,
          Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x,
          Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y);
      _799 = vanilla_plus.r;
      _800 = vanilla_plus.g;
      _801 = vanilla_plus.b;
#else
      // vanilla
      float _747 = _692 * 0.6274039149284363f;
      float _748 = mad(0.3292830288410187f, _693, _747);
      float _749 = mad(0.04331306740641594f, _694, _748);
      float _750 = _692 * 0.06909728795289993f;
      float _751 = mad(0.9195404052734375f, _693, _750);
      float _752 = mad(0.011362316086888313f, _694, _751);
      float _753 = _692 * 0.016391439363360405f;
      float _754 = mad(0.08801330626010895f, _693, _753);
      float _755 = mad(0.8955952525138855f, _694, _754);
      float _756 = _749 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _757 = _752 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _758 = _755 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _759 = abs(_756);
      float _760 = abs(_757);
      float _761 = abs(_758);
      float _762 = log2(_759);
      float _763 = log2(_760);
      float _764 = log2(_761);
      float _765 = _762 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _766 = _763 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _767 = _764 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _768 = exp2(_765);
      float _769 = exp2(_766);
      float _770 = exp2(_767);
      float _771 = _768 * 18.8515625f;
      float _772 = _771 + 0.8359375f;
      float _773 = _768 * 18.6875f;
      float _774 = _773 + 1.0f;
      float _775 = _772 / _774;
      float _776 = abs(_775);
      float _777 = log2(_776);
      float _778 = _777 * 78.84375f;
      float _779 = exp2(_778);
      float _780 = _769 * 18.8515625f;
      float _781 = _780 + 0.8359375f;
      float _782 = _769 * 18.6875f;
      float _783 = _782 + 1.0f;
      float _784 = _781 / _783;
      float _785 = abs(_784);
      float _786 = log2(_785);
      float _787 = _786 * 78.84375f;
      float _788 = exp2(_787);
      float _789 = _770 * 18.8515625f;
      float _790 = _789 + 0.8359375f;
      float _791 = _770 * 18.6875f;
      float _792 = _791 + 1.0f;
      float _793 = _790 / _792;
      float _794 = abs(_793);
      float _795 = log2(_794);
      float _796 = _795 * 78.84375f;
      float _797 = exp2(_796);
      _799 = _779;
      _800 = _788;
      _801 = _797;
#endif
    } else {
      _799 = _692;
      _800 = _693;
      _801 = _694;
    }
  }
  SV_Target.x = _799;
  SV_Target.y = _800;
  SV_Target.z = _801;
  SV_Target.w = _612;
  float _802 = dot(float3(_799, _800, _801), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  SV_Target_1 = _802;
  OutputSignature output_signature = { SV_Target, SV_Target_1 };
  return output_signature;
}
