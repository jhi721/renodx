#ifndef SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0X9C79EDC7_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0X9C79EDC7_HLSLI_

// AA/upscale resolver over the encoded frame: decode -> temporal resolve -> encode.
// Decompiled from the game's DXIL. The RenoDX edits are GetResolverOutputParams and the
// optional RCAS in SelectResolverSharpening; both are documented where they are defined.
//
// Shared by HZDR 0x9C79EDC7 and HFW 0xF4342F55: both games ship this program with the same
// instructions and the same constants, differing only in how the sampler is bound.
// Define HORIZON_RESOLVER_SAMPLER_HEAP_INDEX to take it from the SM6.6 sampler heap
// (HFW); leave it undefined for the classic s0/space5 binding (HZDR).

#include "../common.hlsli"
#include "./resolver_bindings.hlsli"

#ifndef HORIZON_RESOLVER_SAMPLER_HEAP_INDEX
SamplerState s0_space5 : register(s0, space5);
#endif

[numthreads(64, 1, 1)]
void main(
  uint3 SV_DispatchThreadID : SV_DispatchThreadID,
  uint3 SV_GroupID : SV_GroupID,
  uint3 SV_GroupThreadID : SV_GroupThreadID,
  uint SV_GroupIndex : SV_GroupIndex
) {
  const float4 resolver_output_params = GetResolverOutputParams(
      Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_080);
  // Dispatch-uniform RCAS normalization, hoisted once for the four resolver branches below.
  const float resolver_normalization_point =
      GetResolverNormalizationPoint(resolver_output_params);
#ifdef HORIZON_RESOLVER_SAMPLER_HEAP_INDEX
  // HFW binds no classic sampler here - SM6.6 sampler heap, index from the wrapper.
  SamplerState s0_space5 = SamplerDescriptorHeap[HORIZON_RESOLVER_SAMPLER_HEAP_INDEX];
#endif
  // Dispatch-uniform output cap, hoisted once for the four resolver branches below.
  const float scene_cap = resolver_output_params.z;
  int _24 = (uint)(SV_GroupThreadID.x) >> 1;
  int _25 = _24 & 7;
  int _26 = (uint)(SV_GroupThreadID.x) >> 3;
  int _27 = (uint)(SV_GroupThreadID.x) & 1;
  int _28 = _26 & 6;
  int _29 = _28 | _27;
  uint _30 = (uint)(SV_GroupID.x) << 4;
  uint _31 = (uint)(SV_GroupID.y) << 4;
  int _32 = _25 | _30;
  int _33 = _29 | _31;
  uint _34 = _33 + -1u;
  float _35 = float((int)(_32));
  float _36 = float((int)(_34));
  float _37 = _35 + 0.5f;
  float _38 = _36 + 0.5f;
  float _39 = _37 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float _40 = _38 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _43 = t0_space6.SampleLevel(s0_space5, float2(_39, _40), 0.0f);
  uint _47 = _32 + -1u;
  float _48 = float((int)(_47));
  float _49 = float((int)(_33));
  float _50 = _48 + 0.5f;
  float _51 = _49 + 0.5f;
  float _52 = _50 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float _53 = _51 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _54 = t0_space6.SampleLevel(s0_space5, float2(_52, _53), 0.0f);
  float4 _58 = t0_space6.SampleLevel(s0_space5, float2(_39, _53), 0.0f);
  int _62 = _32 + 1;
  float _63 = float((int)(_62));
  float _64 = _63 + 0.5f;
  float _65 = _64 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _66 = t0_space6.SampleLevel(s0_space5, float2(_65, _53), 0.0f);
  int _70 = _33 + 1;
  float _71 = float((int)(_70));
  float _72 = _71 + 0.5f;
  float _73 = _72 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _74 = t0_space6.SampleLevel(s0_space5, float2(_39, _73), 0.0f);
  float _78 = min(_54.x, _66.x);
  float _79 = min(_43.x, _78);
  float _80 = min(_79, _74.x);
  float _81 = min(_54.y, _66.y);
  float _82 = min(_43.y, _81);
  float _83 = min(_82, _74.y);
  float _84 = min(_54.z, _66.z);
  float _85 = min(_43.z, _84);
  float _86 = min(_85, _74.z);
  float _87 = max(_54.x, _66.x);
  float _88 = max(_43.x, _87);
  float _89 = max(_88, _74.x);
  float _90 = max(_54.y, _66.y);
  float _91 = max(_43.y, _90);
  float _92 = max(_91, _74.y);
  float _93 = max(_54.z, _66.z);
  float _94 = max(_43.z, _93);
  float _95 = max(_94, _74.z);
  float _96 = 0.25f / _89;
  float _97 = 0.25f / _92;
  float _98 = 0.25f / _95;
  float _99 = 1.0f - _89;
  float _100 = _80 * 4.0f;
  float _101 = _100 + -4.0f;
  float _102 = 1.0f / _101;
  float _103 = _102 * _99;
  float _104 = 1.0f - _92;
  float _105 = _83 * 4.0f;
  float _106 = _105 + -4.0f;
  float _107 = 1.0f / _106;
  float _108 = _107 * _104;
  float _109 = 1.0f - _95;
  float _110 = _86 * 4.0f;
  float _111 = _110 + -4.0f;
  float _112 = 1.0f / _111;
  float _113 = _112 * _109;
  float _114 = _80 * _96;
  float _115 = -0.0f - _114;
  float _116 = max(_115, _103);
  float _117 = _83 * _97;
  float _118 = -0.0f - _117;
  float _119 = max(_118, _108);
  float _120 = _86 * _98;
  float _121 = -0.0f - _120;
  float _122 = max(_121, _113);
  float _123 = max(_119, _122);
  float _124 = max(_116, _123);
  float _125 = min(_124, 0.0f);
  float _126 = max(-0.1875f, _125);
  float _127 = _126 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _128 = _127 * 4.0f;
  float _129 = _128 + 1.0f;
  int _130 = asint(_129);
  uint _131 = 2129764351u - _130;
  float _132 = asfloat(_131);
  float _133 = _132 * _129;
  float _134 = 2.0f - _133;
  float _135 = _134 * _132;
  float _136 = _54.x + _43.x;
  float _137 = _136 + _66.x;
  float _138 = _137 + _74.x;
  float _139 = _127 * _138;
  float _140 = _139 + _58.x;
  float _141 = _135 * _140;
  float _142 = _54.y + _43.y;
  float _143 = _142 + _66.y;
  float _144 = _143 + _74.y;
  float _145 = _127 * _144;
  float _146 = _145 + _58.y;
  float _147 = _135 * _146;
  float _148 = _54.z + _43.z;
  float _149 = _148 + _66.z;
  float _150 = _149 + _74.z;
  float _151 = _127 * _150;
  float _152 = _151 + _58.z;
  float _153 = _135 * _152;
  const float3 resolver_color_0 = SelectResolverSharpening(
      float3(_141, _147, _153), _43.rgb, _54.rgb, _58.rgb, _66.rgb, _74.rgb,
      resolver_output_params, resolver_normalization_point);
  float _154 = min(resolver_color_0.x, scene_cap);
  float _155 = min(resolver_color_0.y, scene_cap);
  float _156 = min(resolver_color_0.z, scene_cap);
  int _157 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.x);
  int _158 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.y);
  float4 _160 = t1_space6.Load(int3(_32, _33, 0));
  float _165 = max(_160.y, _160.z);
  float _166 = max(_160.x, _165);
  float _167 = _166 + _160.w;
  bool _168 = !(_167 > 0.0f);
  bool _169 = (_158 != 0);
  bool _170 = _169 || _168;
  float _186;
  float _198;
  float _210;
  float _278;
  float _279;
  float _280;
  float _312;
  float _324;
  float _390;
  float _391;
  float _392;
  float _420;
  float _432;
  float _498;
  float _499;
  float _500;
  float _644;
  float _656;
  float _668;
  float _736;
  float _737;
  float _738;
  float _770;
  float _782;
  float _848;
  float _849;
  float _850;
  float _878;
  float _890;
  float _956;
  float _957;
  float _958;
  float _1102;
  float _1114;
  float _1126;
  float _1194;
  float _1195;
  float _1196;
  float _1228;
  float _1240;
  float _1306;
  float _1307;
  float _1308;
  float _1336;
  float _1348;
  float _1414;
  float _1415;
  float _1416;
  float _1548;
  float _1560;
  float _1572;
  float _1640;
  float _1641;
  float _1642;
  float _1674;
  float _1686;
  float _1752;
  float _1753;
  float _1754;
  float _1782;
  float _1794;
  float _1860;
  float _1861;
  float _1862;
  if (!_170) {
    int _172 = int(resolver_output_params.w);
    bool _173 = (_172 == 1);
    [branch]
    if (_173) {
      bool _175 = (_154 < 0.040449999272823334f);
      if (_175) {
        float _177 = _154 * 0.07739938050508499f;
        _186 = _177;
      } else {
        float _179 = _154 * 0.9478672742843628f;
        float _180 = _179 + 0.05213269963860512f;
        float _181 = abs(_180);
        float _182 = log2(_181);
        float _183 = _182 * 2.4000000953674316f;
        float _184 = exp2(_183);
        _186 = _184;
      }
      bool _187 = (_155 < 0.040449999272823334f);
      if (_187) {
        float _189 = _155 * 0.07739938050508499f;
        _198 = _189;
      } else {
        float _191 = _155 * 0.9478672742843628f;
        float _192 = _191 + 0.05213269963860512f;
        float _193 = abs(_192);
        float _194 = log2(_193);
        float _195 = _194 * 2.4000000953674316f;
        float _196 = exp2(_195);
        _198 = _196;
      }
      bool _199 = (_156 < 0.040449999272823334f);
      if (_199) {
        float _201 = _156 * 0.07739938050508499f;
        _210 = _201;
      } else {
        float _203 = _156 * 0.9478672742843628f;
        float _204 = _203 + 0.05213269963860512f;
        float _205 = abs(_204);
        float _206 = log2(_205);
        float _207 = _206 * 2.4000000953674316f;
        float _208 = exp2(_207);
        _210 = _208;
      }
      float _211 = 1.0f / resolver_output_params.x;
      float _212 = abs(_186);
      float _213 = abs(_198);
      float _214 = abs(_210);
      float _215 = log2(_212);
      float _216 = log2(_213);
      float _217 = log2(_214);
      float _218 = _215 * _211;
      float _219 = _216 * _211;
      float _220 = _217 * _211;
      float _221 = exp2(_218);
      float _222 = exp2(_219);
      float _223 = exp2(_220);
      _278 = _221;
      _279 = _222;
      _280 = _223;
    } else {
      bool _225 = (_172 == 2);
      if (_225) {
        float _227 = abs(_154);
        float _228 = abs(_155);
        float _229 = abs(_156);
        float _230 = log2(_227);
        float _231 = log2(_228);
        float _232 = log2(_229);
        float _233 = _230 * 0.012683313339948654f;
        float _234 = _231 * 0.012683313339948654f;
        float _235 = _232 * 0.012683313339948654f;
        float _236 = exp2(_233);
        float _237 = exp2(_234);
        float _238 = exp2(_235);
        float _239 = _236 + -0.8359375f;
        float _240 = _236 * 18.6875f;
        float _241 = 18.8515625f - _240;
        float _242 = _239 / _241;
        float _243 = _237 + -0.8359375f;
        float _244 = _237 * 18.6875f;
        float _245 = 18.8515625f - _244;
        float _246 = _243 / _245;
        float _247 = _238 + -0.8359375f;
        float _248 = _238 * 18.6875f;
        float _249 = 18.8515625f - _248;
        float _250 = _247 / _249;
        float _251 = 1.0f / resolver_output_params.x;
        float _252 = abs(_242);
        float _253 = abs(_246);
        float _254 = abs(_250);
        float _255 = log2(_252);
        float _256 = log2(_253);
        float _257 = log2(_254);
        float _258 = _255 * _251;
        float _259 = _256 * _251;
        float _260 = _257 * _251;
        float _261 = exp2(_258);
        float _262 = exp2(_259);
        float _263 = exp2(_260);
        float _264 = 1.0f / resolver_output_params.y;
        float _265 = _264 * _261;
        float _266 = _264 * _262;
        float _267 = _264 * _263;
        float _268 = _265 * 1.6604900360107422f;
        float _269 = mad(-0.5876410007476807f, _266, _268);
        float _270 = mad(-0.07284989953041077f, _267, _269);
        float _271 = _265 * -0.124549999833107f;
        float _272 = mad(1.1328999996185303f, _266, _271);
        float _273 = mad(-0.008349419571459293f, _267, _272);
        float _274 = _265 * -0.018150800839066505f;
        float _275 = mad(-0.10057900100946426f, _266, _274);
        float _276 = mad(1.1187299489974976f, _267, _275);
        _278 = _270;
        _279 = _273;
        _280 = _276;
      } else {
        _278 = _154;
        _279 = _155;
        _280 = _156;
      }
    }
    float _281 = 1.0f - _160.w;
    float _282 = _278 * _281;
    float _283 = _279 * _281;
    float _284 = _280 * _281;
    float _285 = _282 + _160.x;
    float _286 = _283 + _160.y;
    float _287 = _284 + _160.z;
    [branch]
    if (_173) {
      float _289 = abs(_285);
      float _290 = abs(_286);
      float _291 = abs(_287);
      float _292 = log2(_289);
      float _293 = log2(_290);
      float _294 = log2(_291);
      float _295 = _292 * resolver_output_params.x;
      float _296 = _293 * resolver_output_params.x;
      float _297 = _294 * resolver_output_params.x;
      float _298 = exp2(_295);
      float _299 = exp2(_296);
      float _300 = exp2(_297);
      bool _301 = (_298 < 0.003100000089034438f);
      if (_301) {
        float _303 = _298 * 12.920000076293945f;
        _312 = _303;
      } else {
        float _305 = abs(_298);
        float _306 = log2(_305);
        float _307 = _306 * 0.4166666567325592f;
        float _308 = exp2(_307);
        float _309 = _308 * 1.0549999475479126f;
        float _310 = _309 + -0.054999999701976776f;
        _312 = _310;
      }
      bool _313 = (_299 < 0.003100000089034438f);
      if (_313) {
        float _315 = _299 * 12.920000076293945f;
        _324 = _315;
      } else {
        float _317 = abs(_299);
        float _318 = log2(_317);
        float _319 = _318 * 0.4166666567325592f;
        float _320 = exp2(_319);
        float _321 = _320 * 1.0549999475479126f;
        float _322 = _321 + -0.054999999701976776f;
        _324 = _322;
      }
      bool _325 = (_300 < 0.003100000089034438f);
      if (_325) {
        float _327 = _300 * 12.920000076293945f;
        _390 = _312;
        _391 = _324;
        _392 = _327;
      } else {
        float _329 = abs(_300);
        float _330 = log2(_329);
        float _331 = _330 * 0.4166666567325592f;
        float _332 = exp2(_331);
        float _333 = _332 * 1.0549999475479126f;
        float _334 = _333 + -0.054999999701976776f;
        _390 = _312;
        _391 = _324;
        _392 = _334;
      }
    } else {
      bool _336 = (_172 == 2);
      if (_336) {
        float _338 = _285 * 0.6274039149284363f;
        float _339 = mad(0.3292830288410187f, _286, _338);
        float _340 = mad(0.04331306740641594f, _287, _339);
        float _341 = _285 * 0.06909728795289993f;
        float _342 = mad(0.9195404052734375f, _286, _341);
        float _343 = mad(0.011362316086888313f, _287, _342);
        float _344 = _285 * 0.016391439363360405f;
        float _345 = mad(0.08801330626010895f, _286, _344);
        float _346 = mad(0.8955952525138855f, _287, _345);
        float _347 = _340 * resolver_output_params.y;
        float _348 = _343 * resolver_output_params.y;
        float _349 = _346 * resolver_output_params.y;
        float _350 = abs(_347);
        float _351 = abs(_348);
        float _352 = abs(_349);
        float _353 = log2(_350);
        float _354 = log2(_351);
        float _355 = log2(_352);
        float _356 = _353 * resolver_output_params.x;
        float _357 = _354 * resolver_output_params.x;
        float _358 = _355 * resolver_output_params.x;
        float _359 = exp2(_356);
        float _360 = exp2(_357);
        float _361 = exp2(_358);
        float _362 = _359 * 18.8515625f;
        float _363 = _362 + 0.8359375f;
        float _364 = _359 * 18.6875f;
        float _365 = _364 + 1.0f;
        float _366 = _363 / _365;
        float _367 = abs(_366);
        float _368 = log2(_367);
        float _369 = _368 * 78.84375f;
        float _370 = exp2(_369);
        float _371 = _360 * 18.8515625f;
        float _372 = _371 + 0.8359375f;
        float _373 = _360 * 18.6875f;
        float _374 = _373 + 1.0f;
        float _375 = _372 / _374;
        float _376 = abs(_375);
        float _377 = log2(_376);
        float _378 = _377 * 78.84375f;
        float _379 = exp2(_378);
        float _380 = _361 * 18.8515625f;
        float _381 = _380 + 0.8359375f;
        float _382 = _361 * 18.6875f;
        float _383 = _382 + 1.0f;
        float _384 = _381 / _383;
        float _385 = abs(_384);
        float _386 = log2(_385);
        float _387 = _386 * 78.84375f;
        float _388 = exp2(_387);
        _390 = _370;
        _391 = _379;
        _392 = _388;
      } else {
        _390 = _285;
        _391 = _286;
        _392 = _287;
      }
    }
    u0_space6[int2(_32, _33)] = float4(_390, _391, _392, 1.0f);
    bool _394 = (_157 == 0);
    if (!_394) {
      [branch]
      if (_173) {
        float _397 = abs(_160.x);
        float _398 = abs(_160.y);
        float _399 = abs(_160.z);
        float _400 = log2(_397);
        float _401 = log2(_398);
        float _402 = log2(_399);
        float _403 = _400 * resolver_output_params.x;
        float _404 = _401 * resolver_output_params.x;
        float _405 = _402 * resolver_output_params.x;
        float _406 = exp2(_403);
        float _407 = exp2(_404);
        float _408 = exp2(_405);
        bool _409 = (_406 < 0.003100000089034438f);
        if (_409) {
          float _411 = _406 * 12.920000076293945f;
          _420 = _411;
        } else {
          float _413 = abs(_406);
          float _414 = log2(_413);
          float _415 = _414 * 0.4166666567325592f;
          float _416 = exp2(_415);
          float _417 = _416 * 1.0549999475479126f;
          float _418 = _417 + -0.054999999701976776f;
          _420 = _418;
        }
        bool _421 = (_407 < 0.003100000089034438f);
        if (_421) {
          float _423 = _407 * 12.920000076293945f;
          _432 = _423;
        } else {
          float _425 = abs(_407);
          float _426 = log2(_425);
          float _427 = _426 * 0.4166666567325592f;
          float _428 = exp2(_427);
          float _429 = _428 * 1.0549999475479126f;
          float _430 = _429 + -0.054999999701976776f;
          _432 = _430;
        }
        bool _433 = (_408 < 0.003100000089034438f);
        if (_433) {
          float _435 = _408 * 12.920000076293945f;
          _498 = _420;
          _499 = _432;
          _500 = _435;
        } else {
          float _437 = abs(_408);
          float _438 = log2(_437);
          float _439 = _438 * 0.4166666567325592f;
          float _440 = exp2(_439);
          float _441 = _440 * 1.0549999475479126f;
          float _442 = _441 + -0.054999999701976776f;
          _498 = _420;
          _499 = _432;
          _500 = _442;
        }
      } else {
        bool _444 = (_172 == 2);
        if (_444) {
          float _446 = _160.x * 0.6274039149284363f;
          float _447 = mad(0.3292830288410187f, _160.y, _446);
          float _448 = mad(0.04331306740641594f, _160.z, _447);
          float _449 = _160.x * 0.06909728795289993f;
          float _450 = mad(0.9195404052734375f, _160.y, _449);
          float _451 = mad(0.011362316086888313f, _160.z, _450);
          float _452 = _160.x * 0.016391439363360405f;
          float _453 = mad(0.08801330626010895f, _160.y, _452);
          float _454 = mad(0.8955952525138855f, _160.z, _453);
          float _455 = _448 * resolver_output_params.y;
          float _456 = _451 * resolver_output_params.y;
          float _457 = _454 * resolver_output_params.y;
          float _458 = abs(_455);
          float _459 = abs(_456);
          float _460 = abs(_457);
          float _461 = log2(_458);
          float _462 = log2(_459);
          float _463 = log2(_460);
          float _464 = _461 * resolver_output_params.x;
          float _465 = _462 * resolver_output_params.x;
          float _466 = _463 * resolver_output_params.x;
          float _467 = exp2(_464);
          float _468 = exp2(_465);
          float _469 = exp2(_466);
          float _470 = _467 * 18.8515625f;
          float _471 = _470 + 0.8359375f;
          float _472 = _467 * 18.6875f;
          float _473 = _472 + 1.0f;
          float _474 = _471 / _473;
          float _475 = abs(_474);
          float _476 = log2(_475);
          float _477 = _476 * 78.84375f;
          float _478 = exp2(_477);
          float _479 = _468 * 18.8515625f;
          float _480 = _479 + 0.8359375f;
          float _481 = _468 * 18.6875f;
          float _482 = _481 + 1.0f;
          float _483 = _480 / _482;
          float _484 = abs(_483);
          float _485 = log2(_484);
          float _486 = _485 * 78.84375f;
          float _487 = exp2(_486);
          float _488 = _469 * 18.8515625f;
          float _489 = _488 + 0.8359375f;
          float _490 = _469 * 18.6875f;
          float _491 = _490 + 1.0f;
          float _492 = _489 / _491;
          float _493 = abs(_492);
          float _494 = log2(_493);
          float _495 = _494 * 78.84375f;
          float _496 = exp2(_495);
          _498 = _478;
          _499 = _487;
          _500 = _496;
        } else {
          _498 = _160.x;
          _499 = _160.y;
          _500 = _160.z;
        }
      }
      u1_space6[int2(_32, _33)] = float4(_498, _499, _500, _160.w);
    }
  } else {
    u0_space6[int2(_32, _33)] = float4(_154, _155, _156, 1.0f);
  }
  int _505 = _32 | 8;
  float _506 = float((int)(_505));
  float _507 = _506 + 0.5f;
  float _508 = _507 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _511 = t0_space6.SampleLevel(s0_space5, float2(_508, _40), 0.0f);
  uint _515 = _505 + -1u;
  float _516 = float((int)(_515));
  float _517 = _516 + 0.5f;
  float _518 = _517 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _519 = t0_space6.SampleLevel(s0_space5, float2(_518, _53), 0.0f);
  float4 _523 = t0_space6.SampleLevel(s0_space5, float2(_508, _53), 0.0f);
  uint _527 = _505 + 1u;
  float _528 = float((int)(_527));
  float _529 = _528 + 0.5f;
  float _530 = _529 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _531 = t0_space6.SampleLevel(s0_space5, float2(_530, _53), 0.0f);
  float4 _535 = t0_space6.SampleLevel(s0_space5, float2(_508, _73), 0.0f);
  float _539 = min(_519.x, _531.x);
  float _540 = min(_511.x, _539);
  float _541 = min(_540, _535.x);
  float _542 = min(_519.y, _531.y);
  float _543 = min(_511.y, _542);
  float _544 = min(_543, _535.y);
  float _545 = min(_519.z, _531.z);
  float _546 = min(_511.z, _545);
  float _547 = min(_546, _535.z);
  float _548 = max(_519.x, _531.x);
  float _549 = max(_511.x, _548);
  float _550 = max(_549, _535.x);
  float _551 = max(_519.y, _531.y);
  float _552 = max(_511.y, _551);
  float _553 = max(_552, _535.y);
  float _554 = max(_519.z, _531.z);
  float _555 = max(_511.z, _554);
  float _556 = max(_555, _535.z);
  float _557 = 0.25f / _550;
  float _558 = 0.25f / _553;
  float _559 = 0.25f / _556;
  float _560 = 1.0f - _550;
  float _561 = _541 * 4.0f;
  float _562 = _561 + -4.0f;
  float _563 = 1.0f / _562;
  float _564 = _563 * _560;
  float _565 = 1.0f - _553;
  float _566 = _544 * 4.0f;
  float _567 = _566 + -4.0f;
  float _568 = 1.0f / _567;
  float _569 = _568 * _565;
  float _570 = 1.0f - _556;
  float _571 = _547 * 4.0f;
  float _572 = _571 + -4.0f;
  float _573 = 1.0f / _572;
  float _574 = _573 * _570;
  float _575 = _541 * _557;
  float _576 = -0.0f - _575;
  float _577 = max(_576, _564);
  float _578 = _544 * _558;
  float _579 = -0.0f - _578;
  float _580 = max(_579, _569);
  float _581 = _547 * _559;
  float _582 = -0.0f - _581;
  float _583 = max(_582, _574);
  float _584 = max(_580, _583);
  float _585 = max(_577, _584);
  float _586 = min(_585, 0.0f);
  float _587 = max(-0.1875f, _586);
  float _588 = _587 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _589 = _588 * 4.0f;
  float _590 = _589 + 1.0f;
  int _591 = asint(_590);
  uint _592 = 2129764351u - _591;
  float _593 = asfloat(_592);
  float _594 = _593 * _590;
  float _595 = 2.0f - _594;
  float _596 = _595 * _593;
  float _597 = _519.x + _511.x;
  float _598 = _597 + _531.x;
  float _599 = _598 + _535.x;
  float _600 = _588 * _599;
  float _601 = _600 + _523.x;
  float _602 = _596 * _601;
  float _603 = _519.y + _511.y;
  float _604 = _603 + _531.y;
  float _605 = _604 + _535.y;
  float _606 = _588 * _605;
  float _607 = _606 + _523.y;
  float _608 = _596 * _607;
  float _609 = _519.z + _511.z;
  float _610 = _609 + _531.z;
  float _611 = _610 + _535.z;
  float _612 = _588 * _611;
  float _613 = _612 + _523.z;
  float _614 = _596 * _613;
  const float3 resolver_color_1 = SelectResolverSharpening(
      float3(_602, _608, _614), _511.rgb, _519.rgb, _523.rgb, _531.rgb, _535.rgb,
      resolver_output_params, resolver_normalization_point);
  float _615 = min(resolver_color_1.x, scene_cap);
  float _616 = min(resolver_color_1.y, scene_cap);
  float _617 = min(resolver_color_1.z, scene_cap);
  float4 _619 = t1_space6.Load(int3(_505, _33, 0));
  float _624 = max(_619.y, _619.z);
  float _625 = max(_619.x, _624);
  float _626 = _625 + _619.w;
  bool _627 = !(_626 > 0.0f);
  bool _628 = _169 || _627;
  if (!_628) {
    int _630 = int(resolver_output_params.w);
    bool _631 = (_630 == 1);
    [branch]
    if (_631) {
      bool _633 = (_615 < 0.040449999272823334f);
      if (_633) {
        float _635 = _615 * 0.07739938050508499f;
        _644 = _635;
      } else {
        float _637 = _615 * 0.9478672742843628f;
        float _638 = _637 + 0.05213269963860512f;
        float _639 = abs(_638);
        float _640 = log2(_639);
        float _641 = _640 * 2.4000000953674316f;
        float _642 = exp2(_641);
        _644 = _642;
      }
      bool _645 = (_616 < 0.040449999272823334f);
      if (_645) {
        float _647 = _616 * 0.07739938050508499f;
        _656 = _647;
      } else {
        float _649 = _616 * 0.9478672742843628f;
        float _650 = _649 + 0.05213269963860512f;
        float _651 = abs(_650);
        float _652 = log2(_651);
        float _653 = _652 * 2.4000000953674316f;
        float _654 = exp2(_653);
        _656 = _654;
      }
      bool _657 = (_617 < 0.040449999272823334f);
      if (_657) {
        float _659 = _617 * 0.07739938050508499f;
        _668 = _659;
      } else {
        float _661 = _617 * 0.9478672742843628f;
        float _662 = _661 + 0.05213269963860512f;
        float _663 = abs(_662);
        float _664 = log2(_663);
        float _665 = _664 * 2.4000000953674316f;
        float _666 = exp2(_665);
        _668 = _666;
      }
      float _669 = 1.0f / resolver_output_params.x;
      float _670 = abs(_644);
      float _671 = abs(_656);
      float _672 = abs(_668);
      float _673 = log2(_670);
      float _674 = log2(_671);
      float _675 = log2(_672);
      float _676 = _673 * _669;
      float _677 = _674 * _669;
      float _678 = _675 * _669;
      float _679 = exp2(_676);
      float _680 = exp2(_677);
      float _681 = exp2(_678);
      _736 = _679;
      _737 = _680;
      _738 = _681;
    } else {
      bool _683 = (_630 == 2);
      if (_683) {
        float _685 = abs(_615);
        float _686 = abs(_616);
        float _687 = abs(_617);
        float _688 = log2(_685);
        float _689 = log2(_686);
        float _690 = log2(_687);
        float _691 = _688 * 0.012683313339948654f;
        float _692 = _689 * 0.012683313339948654f;
        float _693 = _690 * 0.012683313339948654f;
        float _694 = exp2(_691);
        float _695 = exp2(_692);
        float _696 = exp2(_693);
        float _697 = _694 + -0.8359375f;
        float _698 = _694 * 18.6875f;
        float _699 = 18.8515625f - _698;
        float _700 = _697 / _699;
        float _701 = _695 + -0.8359375f;
        float _702 = _695 * 18.6875f;
        float _703 = 18.8515625f - _702;
        float _704 = _701 / _703;
        float _705 = _696 + -0.8359375f;
        float _706 = _696 * 18.6875f;
        float _707 = 18.8515625f - _706;
        float _708 = _705 / _707;
        float _709 = 1.0f / resolver_output_params.x;
        float _710 = abs(_700);
        float _711 = abs(_704);
        float _712 = abs(_708);
        float _713 = log2(_710);
        float _714 = log2(_711);
        float _715 = log2(_712);
        float _716 = _713 * _709;
        float _717 = _714 * _709;
        float _718 = _715 * _709;
        float _719 = exp2(_716);
        float _720 = exp2(_717);
        float _721 = exp2(_718);
        float _722 = 1.0f / resolver_output_params.y;
        float _723 = _722 * _719;
        float _724 = _722 * _720;
        float _725 = _722 * _721;
        float _726 = _723 * 1.6604900360107422f;
        float _727 = mad(-0.5876410007476807f, _724, _726);
        float _728 = mad(-0.07284989953041077f, _725, _727);
        float _729 = _723 * -0.124549999833107f;
        float _730 = mad(1.1328999996185303f, _724, _729);
        float _731 = mad(-0.008349419571459293f, _725, _730);
        float _732 = _723 * -0.018150800839066505f;
        float _733 = mad(-0.10057900100946426f, _724, _732);
        float _734 = mad(1.1187299489974976f, _725, _733);
        _736 = _728;
        _737 = _731;
        _738 = _734;
      } else {
        _736 = _615;
        _737 = _616;
        _738 = _617;
      }
    }
    float _739 = 1.0f - _619.w;
    float _740 = _736 * _739;
    float _741 = _737 * _739;
    float _742 = _738 * _739;
    float _743 = _740 + _619.x;
    float _744 = _741 + _619.y;
    float _745 = _742 + _619.z;
    [branch]
    if (_631) {
      float _747 = abs(_743);
      float _748 = abs(_744);
      float _749 = abs(_745);
      float _750 = log2(_747);
      float _751 = log2(_748);
      float _752 = log2(_749);
      float _753 = _750 * resolver_output_params.x;
      float _754 = _751 * resolver_output_params.x;
      float _755 = _752 * resolver_output_params.x;
      float _756 = exp2(_753);
      float _757 = exp2(_754);
      float _758 = exp2(_755);
      bool _759 = (_756 < 0.003100000089034438f);
      if (_759) {
        float _761 = _756 * 12.920000076293945f;
        _770 = _761;
      } else {
        float _763 = abs(_756);
        float _764 = log2(_763);
        float _765 = _764 * 0.4166666567325592f;
        float _766 = exp2(_765);
        float _767 = _766 * 1.0549999475479126f;
        float _768 = _767 + -0.054999999701976776f;
        _770 = _768;
      }
      bool _771 = (_757 < 0.003100000089034438f);
      if (_771) {
        float _773 = _757 * 12.920000076293945f;
        _782 = _773;
      } else {
        float _775 = abs(_757);
        float _776 = log2(_775);
        float _777 = _776 * 0.4166666567325592f;
        float _778 = exp2(_777);
        float _779 = _778 * 1.0549999475479126f;
        float _780 = _779 + -0.054999999701976776f;
        _782 = _780;
      }
      bool _783 = (_758 < 0.003100000089034438f);
      if (_783) {
        float _785 = _758 * 12.920000076293945f;
        _848 = _770;
        _849 = _782;
        _850 = _785;
      } else {
        float _787 = abs(_758);
        float _788 = log2(_787);
        float _789 = _788 * 0.4166666567325592f;
        float _790 = exp2(_789);
        float _791 = _790 * 1.0549999475479126f;
        float _792 = _791 + -0.054999999701976776f;
        _848 = _770;
        _849 = _782;
        _850 = _792;
      }
    } else {
      bool _794 = (_630 == 2);
      if (_794) {
        float _796 = _743 * 0.6274039149284363f;
        float _797 = mad(0.3292830288410187f, _744, _796);
        float _798 = mad(0.04331306740641594f, _745, _797);
        float _799 = _743 * 0.06909728795289993f;
        float _800 = mad(0.9195404052734375f, _744, _799);
        float _801 = mad(0.011362316086888313f, _745, _800);
        float _802 = _743 * 0.016391439363360405f;
        float _803 = mad(0.08801330626010895f, _744, _802);
        float _804 = mad(0.8955952525138855f, _745, _803);
        float _805 = _798 * resolver_output_params.y;
        float _806 = _801 * resolver_output_params.y;
        float _807 = _804 * resolver_output_params.y;
        float _808 = abs(_805);
        float _809 = abs(_806);
        float _810 = abs(_807);
        float _811 = log2(_808);
        float _812 = log2(_809);
        float _813 = log2(_810);
        float _814 = _811 * resolver_output_params.x;
        float _815 = _812 * resolver_output_params.x;
        float _816 = _813 * resolver_output_params.x;
        float _817 = exp2(_814);
        float _818 = exp2(_815);
        float _819 = exp2(_816);
        float _820 = _817 * 18.8515625f;
        float _821 = _820 + 0.8359375f;
        float _822 = _817 * 18.6875f;
        float _823 = _822 + 1.0f;
        float _824 = _821 / _823;
        float _825 = abs(_824);
        float _826 = log2(_825);
        float _827 = _826 * 78.84375f;
        float _828 = exp2(_827);
        float _829 = _818 * 18.8515625f;
        float _830 = _829 + 0.8359375f;
        float _831 = _818 * 18.6875f;
        float _832 = _831 + 1.0f;
        float _833 = _830 / _832;
        float _834 = abs(_833);
        float _835 = log2(_834);
        float _836 = _835 * 78.84375f;
        float _837 = exp2(_836);
        float _838 = _819 * 18.8515625f;
        float _839 = _838 + 0.8359375f;
        float _840 = _819 * 18.6875f;
        float _841 = _840 + 1.0f;
        float _842 = _839 / _841;
        float _843 = abs(_842);
        float _844 = log2(_843);
        float _845 = _844 * 78.84375f;
        float _846 = exp2(_845);
        _848 = _828;
        _849 = _837;
        _850 = _846;
      } else {
        _848 = _743;
        _849 = _744;
        _850 = _745;
      }
    }
    u0_space6[int2(_505, _33)] = float4(_848, _849, _850, 1.0f);
    bool _852 = (_157 == 0);
    if (!_852) {
      [branch]
      if (_631) {
        float _855 = abs(_619.x);
        float _856 = abs(_619.y);
        float _857 = abs(_619.z);
        float _858 = log2(_855);
        float _859 = log2(_856);
        float _860 = log2(_857);
        float _861 = _858 * resolver_output_params.x;
        float _862 = _859 * resolver_output_params.x;
        float _863 = _860 * resolver_output_params.x;
        float _864 = exp2(_861);
        float _865 = exp2(_862);
        float _866 = exp2(_863);
        bool _867 = (_864 < 0.003100000089034438f);
        if (_867) {
          float _869 = _864 * 12.920000076293945f;
          _878 = _869;
        } else {
          float _871 = abs(_864);
          float _872 = log2(_871);
          float _873 = _872 * 0.4166666567325592f;
          float _874 = exp2(_873);
          float _875 = _874 * 1.0549999475479126f;
          float _876 = _875 + -0.054999999701976776f;
          _878 = _876;
        }
        bool _879 = (_865 < 0.003100000089034438f);
        if (_879) {
          float _881 = _865 * 12.920000076293945f;
          _890 = _881;
        } else {
          float _883 = abs(_865);
          float _884 = log2(_883);
          float _885 = _884 * 0.4166666567325592f;
          float _886 = exp2(_885);
          float _887 = _886 * 1.0549999475479126f;
          float _888 = _887 + -0.054999999701976776f;
          _890 = _888;
        }
        bool _891 = (_866 < 0.003100000089034438f);
        if (_891) {
          float _893 = _866 * 12.920000076293945f;
          _956 = _878;
          _957 = _890;
          _958 = _893;
        } else {
          float _895 = abs(_866);
          float _896 = log2(_895);
          float _897 = _896 * 0.4166666567325592f;
          float _898 = exp2(_897);
          float _899 = _898 * 1.0549999475479126f;
          float _900 = _899 + -0.054999999701976776f;
          _956 = _878;
          _957 = _890;
          _958 = _900;
        }
      } else {
        bool _902 = (_630 == 2);
        if (_902) {
          float _904 = _619.x * 0.6274039149284363f;
          float _905 = mad(0.3292830288410187f, _619.y, _904);
          float _906 = mad(0.04331306740641594f, _619.z, _905);
          float _907 = _619.x * 0.06909728795289993f;
          float _908 = mad(0.9195404052734375f, _619.y, _907);
          float _909 = mad(0.011362316086888313f, _619.z, _908);
          float _910 = _619.x * 0.016391439363360405f;
          float _911 = mad(0.08801330626010895f, _619.y, _910);
          float _912 = mad(0.8955952525138855f, _619.z, _911);
          float _913 = _906 * resolver_output_params.y;
          float _914 = _909 * resolver_output_params.y;
          float _915 = _912 * resolver_output_params.y;
          float _916 = abs(_913);
          float _917 = abs(_914);
          float _918 = abs(_915);
          float _919 = log2(_916);
          float _920 = log2(_917);
          float _921 = log2(_918);
          float _922 = _919 * resolver_output_params.x;
          float _923 = _920 * resolver_output_params.x;
          float _924 = _921 * resolver_output_params.x;
          float _925 = exp2(_922);
          float _926 = exp2(_923);
          float _927 = exp2(_924);
          float _928 = _925 * 18.8515625f;
          float _929 = _928 + 0.8359375f;
          float _930 = _925 * 18.6875f;
          float _931 = _930 + 1.0f;
          float _932 = _929 / _931;
          float _933 = abs(_932);
          float _934 = log2(_933);
          float _935 = _934 * 78.84375f;
          float _936 = exp2(_935);
          float _937 = _926 * 18.8515625f;
          float _938 = _937 + 0.8359375f;
          float _939 = _926 * 18.6875f;
          float _940 = _939 + 1.0f;
          float _941 = _938 / _940;
          float _942 = abs(_941);
          float _943 = log2(_942);
          float _944 = _943 * 78.84375f;
          float _945 = exp2(_944);
          float _946 = _927 * 18.8515625f;
          float _947 = _946 + 0.8359375f;
          float _948 = _927 * 18.6875f;
          float _949 = _948 + 1.0f;
          float _950 = _947 / _949;
          float _951 = abs(_950);
          float _952 = log2(_951);
          float _953 = _952 * 78.84375f;
          float _954 = exp2(_953);
          _956 = _936;
          _957 = _945;
          _958 = _954;
        } else {
          _956 = _619.x;
          _957 = _619.y;
          _958 = _619.z;
        }
      }
      u1_space6[int2(_505, _33)] = float4(_956, _957, _958, _619.w);
    }
  } else {
    u0_space6[int2(_505, _33)] = float4(_615, _616, _617, 1.0f);
  }
  int _963 = _33 | 8;
  uint _964 = _963 + -1u;
  float _965 = float((int)(_964));
  float _966 = _965 + 0.5f;
  float _967 = _966 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _970 = t0_space6.SampleLevel(s0_space5, float2(_508, _967), 0.0f);
  float _974 = float((int)(_963));
  float _975 = _974 + 0.5f;
  float _976 = _975 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _977 = t0_space6.SampleLevel(s0_space5, float2(_518, _976), 0.0f);
  float4 _981 = t0_space6.SampleLevel(s0_space5, float2(_508, _976), 0.0f);
  float4 _985 = t0_space6.SampleLevel(s0_space5, float2(_530, _976), 0.0f);
  uint _989 = _963 + 1u;
  float _990 = float((int)(_989));
  float _991 = _990 + 0.5f;
  float _992 = _991 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _993 = t0_space6.SampleLevel(s0_space5, float2(_508, _992), 0.0f);
  float _997 = min(_977.x, _985.x);
  float _998 = min(_970.x, _997);
  float _999 = min(_998, _993.x);
  float _1000 = min(_977.y, _985.y);
  float _1001 = min(_970.y, _1000);
  float _1002 = min(_1001, _993.y);
  float _1003 = min(_977.z, _985.z);
  float _1004 = min(_970.z, _1003);
  float _1005 = min(_1004, _993.z);
  float _1006 = max(_977.x, _985.x);
  float _1007 = max(_970.x, _1006);
  float _1008 = max(_1007, _993.x);
  float _1009 = max(_977.y, _985.y);
  float _1010 = max(_970.y, _1009);
  float _1011 = max(_1010, _993.y);
  float _1012 = max(_977.z, _985.z);
  float _1013 = max(_970.z, _1012);
  float _1014 = max(_1013, _993.z);
  float _1015 = 0.25f / _1008;
  float _1016 = 0.25f / _1011;
  float _1017 = 0.25f / _1014;
  float _1018 = 1.0f - _1008;
  float _1019 = _999 * 4.0f;
  float _1020 = _1019 + -4.0f;
  float _1021 = 1.0f / _1020;
  float _1022 = _1021 * _1018;
  float _1023 = 1.0f - _1011;
  float _1024 = _1002 * 4.0f;
  float _1025 = _1024 + -4.0f;
  float _1026 = 1.0f / _1025;
  float _1027 = _1026 * _1023;
  float _1028 = 1.0f - _1014;
  float _1029 = _1005 * 4.0f;
  float _1030 = _1029 + -4.0f;
  float _1031 = 1.0f / _1030;
  float _1032 = _1031 * _1028;
  float _1033 = _999 * _1015;
  float _1034 = -0.0f - _1033;
  float _1035 = max(_1034, _1022);
  float _1036 = _1002 * _1016;
  float _1037 = -0.0f - _1036;
  float _1038 = max(_1037, _1027);
  float _1039 = _1005 * _1017;
  float _1040 = -0.0f - _1039;
  float _1041 = max(_1040, _1032);
  float _1042 = max(_1038, _1041);
  float _1043 = max(_1035, _1042);
  float _1044 = min(_1043, 0.0f);
  float _1045 = max(-0.1875f, _1044);
  float _1046 = _1045 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _1047 = _1046 * 4.0f;
  float _1048 = _1047 + 1.0f;
  int _1049 = asint(_1048);
  uint _1050 = 2129764351u - _1049;
  float _1051 = asfloat(_1050);
  float _1052 = _1051 * _1048;
  float _1053 = 2.0f - _1052;
  float _1054 = _1053 * _1051;
  float _1055 = _977.x + _970.x;
  float _1056 = _1055 + _985.x;
  float _1057 = _1056 + _993.x;
  float _1058 = _1046 * _1057;
  float _1059 = _1058 + _981.x;
  float _1060 = _1054 * _1059;
  float _1061 = _977.y + _970.y;
  float _1062 = _1061 + _985.y;
  float _1063 = _1062 + _993.y;
  float _1064 = _1046 * _1063;
  float _1065 = _1064 + _981.y;
  float _1066 = _1054 * _1065;
  float _1067 = _977.z + _970.z;
  float _1068 = _1067 + _985.z;
  float _1069 = _1068 + _993.z;
  float _1070 = _1046 * _1069;
  float _1071 = _1070 + _981.z;
  float _1072 = _1054 * _1071;
  const float3 resolver_color_2 = SelectResolverSharpening(
      float3(_1060, _1066, _1072), _970.rgb, _977.rgb, _981.rgb, _985.rgb, _993.rgb,
      resolver_output_params, resolver_normalization_point);
  float _1073 = min(resolver_color_2.x, scene_cap);
  float _1074 = min(resolver_color_2.y, scene_cap);
  float _1075 = min(resolver_color_2.z, scene_cap);
  float4 _1077 = t1_space6.Load(int3(_505, _963, 0));
  float _1082 = max(_1077.y, _1077.z);
  float _1083 = max(_1077.x, _1082);
  float _1084 = _1083 + _1077.w;
  bool _1085 = !(_1084 > 0.0f);
  bool _1086 = _169 || _1085;
  if (!_1086) {
    int _1088 = int(resolver_output_params.w);
    bool _1089 = (_1088 == 1);
    [branch]
    if (_1089) {
      bool _1091 = (_1073 < 0.040449999272823334f);
      if (_1091) {
        float _1093 = _1073 * 0.07739938050508499f;
        _1102 = _1093;
      } else {
        float _1095 = _1073 * 0.9478672742843628f;
        float _1096 = _1095 + 0.05213269963860512f;
        float _1097 = abs(_1096);
        float _1098 = log2(_1097);
        float _1099 = _1098 * 2.4000000953674316f;
        float _1100 = exp2(_1099);
        _1102 = _1100;
      }
      bool _1103 = (_1074 < 0.040449999272823334f);
      if (_1103) {
        float _1105 = _1074 * 0.07739938050508499f;
        _1114 = _1105;
      } else {
        float _1107 = _1074 * 0.9478672742843628f;
        float _1108 = _1107 + 0.05213269963860512f;
        float _1109 = abs(_1108);
        float _1110 = log2(_1109);
        float _1111 = _1110 * 2.4000000953674316f;
        float _1112 = exp2(_1111);
        _1114 = _1112;
      }
      bool _1115 = (_1075 < 0.040449999272823334f);
      if (_1115) {
        float _1117 = _1075 * 0.07739938050508499f;
        _1126 = _1117;
      } else {
        float _1119 = _1075 * 0.9478672742843628f;
        float _1120 = _1119 + 0.05213269963860512f;
        float _1121 = abs(_1120);
        float _1122 = log2(_1121);
        float _1123 = _1122 * 2.4000000953674316f;
        float _1124 = exp2(_1123);
        _1126 = _1124;
      }
      float _1127 = 1.0f / resolver_output_params.x;
      float _1128 = abs(_1102);
      float _1129 = abs(_1114);
      float _1130 = abs(_1126);
      float _1131 = log2(_1128);
      float _1132 = log2(_1129);
      float _1133 = log2(_1130);
      float _1134 = _1131 * _1127;
      float _1135 = _1132 * _1127;
      float _1136 = _1133 * _1127;
      float _1137 = exp2(_1134);
      float _1138 = exp2(_1135);
      float _1139 = exp2(_1136);
      _1194 = _1137;
      _1195 = _1138;
      _1196 = _1139;
    } else {
      bool _1141 = (_1088 == 2);
      if (_1141) {
        float _1143 = abs(_1073);
        float _1144 = abs(_1074);
        float _1145 = abs(_1075);
        float _1146 = log2(_1143);
        float _1147 = log2(_1144);
        float _1148 = log2(_1145);
        float _1149 = _1146 * 0.012683313339948654f;
        float _1150 = _1147 * 0.012683313339948654f;
        float _1151 = _1148 * 0.012683313339948654f;
        float _1152 = exp2(_1149);
        float _1153 = exp2(_1150);
        float _1154 = exp2(_1151);
        float _1155 = _1152 + -0.8359375f;
        float _1156 = _1152 * 18.6875f;
        float _1157 = 18.8515625f - _1156;
        float _1158 = _1155 / _1157;
        float _1159 = _1153 + -0.8359375f;
        float _1160 = _1153 * 18.6875f;
        float _1161 = 18.8515625f - _1160;
        float _1162 = _1159 / _1161;
        float _1163 = _1154 + -0.8359375f;
        float _1164 = _1154 * 18.6875f;
        float _1165 = 18.8515625f - _1164;
        float _1166 = _1163 / _1165;
        float _1167 = 1.0f / resolver_output_params.x;
        float _1168 = abs(_1158);
        float _1169 = abs(_1162);
        float _1170 = abs(_1166);
        float _1171 = log2(_1168);
        float _1172 = log2(_1169);
        float _1173 = log2(_1170);
        float _1174 = _1171 * _1167;
        float _1175 = _1172 * _1167;
        float _1176 = _1173 * _1167;
        float _1177 = exp2(_1174);
        float _1178 = exp2(_1175);
        float _1179 = exp2(_1176);
        float _1180 = 1.0f / resolver_output_params.y;
        float _1181 = _1180 * _1177;
        float _1182 = _1180 * _1178;
        float _1183 = _1180 * _1179;
        float _1184 = _1181 * 1.6604900360107422f;
        float _1185 = mad(-0.5876410007476807f, _1182, _1184);
        float _1186 = mad(-0.07284989953041077f, _1183, _1185);
        float _1187 = _1181 * -0.124549999833107f;
        float _1188 = mad(1.1328999996185303f, _1182, _1187);
        float _1189 = mad(-0.008349419571459293f, _1183, _1188);
        float _1190 = _1181 * -0.018150800839066505f;
        float _1191 = mad(-0.10057900100946426f, _1182, _1190);
        float _1192 = mad(1.1187299489974976f, _1183, _1191);
        _1194 = _1186;
        _1195 = _1189;
        _1196 = _1192;
      } else {
        _1194 = _1073;
        _1195 = _1074;
        _1196 = _1075;
      }
    }
    float _1197 = 1.0f - _1077.w;
    float _1198 = _1194 * _1197;
    float _1199 = _1195 * _1197;
    float _1200 = _1196 * _1197;
    float _1201 = _1198 + _1077.x;
    float _1202 = _1199 + _1077.y;
    float _1203 = _1200 + _1077.z;
    [branch]
    if (_1089) {
      float _1205 = abs(_1201);
      float _1206 = abs(_1202);
      float _1207 = abs(_1203);
      float _1208 = log2(_1205);
      float _1209 = log2(_1206);
      float _1210 = log2(_1207);
      float _1211 = _1208 * resolver_output_params.x;
      float _1212 = _1209 * resolver_output_params.x;
      float _1213 = _1210 * resolver_output_params.x;
      float _1214 = exp2(_1211);
      float _1215 = exp2(_1212);
      float _1216 = exp2(_1213);
      bool _1217 = (_1214 < 0.003100000089034438f);
      if (_1217) {
        float _1219 = _1214 * 12.920000076293945f;
        _1228 = _1219;
      } else {
        float _1221 = abs(_1214);
        float _1222 = log2(_1221);
        float _1223 = _1222 * 0.4166666567325592f;
        float _1224 = exp2(_1223);
        float _1225 = _1224 * 1.0549999475479126f;
        float _1226 = _1225 + -0.054999999701976776f;
        _1228 = _1226;
      }
      bool _1229 = (_1215 < 0.003100000089034438f);
      if (_1229) {
        float _1231 = _1215 * 12.920000076293945f;
        _1240 = _1231;
      } else {
        float _1233 = abs(_1215);
        float _1234 = log2(_1233);
        float _1235 = _1234 * 0.4166666567325592f;
        float _1236 = exp2(_1235);
        float _1237 = _1236 * 1.0549999475479126f;
        float _1238 = _1237 + -0.054999999701976776f;
        _1240 = _1238;
      }
      bool _1241 = (_1216 < 0.003100000089034438f);
      if (_1241) {
        float _1243 = _1216 * 12.920000076293945f;
        _1306 = _1228;
        _1307 = _1240;
        _1308 = _1243;
      } else {
        float _1245 = abs(_1216);
        float _1246 = log2(_1245);
        float _1247 = _1246 * 0.4166666567325592f;
        float _1248 = exp2(_1247);
        float _1249 = _1248 * 1.0549999475479126f;
        float _1250 = _1249 + -0.054999999701976776f;
        _1306 = _1228;
        _1307 = _1240;
        _1308 = _1250;
      }
    } else {
      bool _1252 = (_1088 == 2);
      if (_1252) {
        float _1254 = _1201 * 0.6274039149284363f;
        float _1255 = mad(0.3292830288410187f, _1202, _1254);
        float _1256 = mad(0.04331306740641594f, _1203, _1255);
        float _1257 = _1201 * 0.06909728795289993f;
        float _1258 = mad(0.9195404052734375f, _1202, _1257);
        float _1259 = mad(0.011362316086888313f, _1203, _1258);
        float _1260 = _1201 * 0.016391439363360405f;
        float _1261 = mad(0.08801330626010895f, _1202, _1260);
        float _1262 = mad(0.8955952525138855f, _1203, _1261);
        float _1263 = _1256 * resolver_output_params.y;
        float _1264 = _1259 * resolver_output_params.y;
        float _1265 = _1262 * resolver_output_params.y;
        float _1266 = abs(_1263);
        float _1267 = abs(_1264);
        float _1268 = abs(_1265);
        float _1269 = log2(_1266);
        float _1270 = log2(_1267);
        float _1271 = log2(_1268);
        float _1272 = _1269 * resolver_output_params.x;
        float _1273 = _1270 * resolver_output_params.x;
        float _1274 = _1271 * resolver_output_params.x;
        float _1275 = exp2(_1272);
        float _1276 = exp2(_1273);
        float _1277 = exp2(_1274);
        float _1278 = _1275 * 18.8515625f;
        float _1279 = _1278 + 0.8359375f;
        float _1280 = _1275 * 18.6875f;
        float _1281 = _1280 + 1.0f;
        float _1282 = _1279 / _1281;
        float _1283 = abs(_1282);
        float _1284 = log2(_1283);
        float _1285 = _1284 * 78.84375f;
        float _1286 = exp2(_1285);
        float _1287 = _1276 * 18.8515625f;
        float _1288 = _1287 + 0.8359375f;
        float _1289 = _1276 * 18.6875f;
        float _1290 = _1289 + 1.0f;
        float _1291 = _1288 / _1290;
        float _1292 = abs(_1291);
        float _1293 = log2(_1292);
        float _1294 = _1293 * 78.84375f;
        float _1295 = exp2(_1294);
        float _1296 = _1277 * 18.8515625f;
        float _1297 = _1296 + 0.8359375f;
        float _1298 = _1277 * 18.6875f;
        float _1299 = _1298 + 1.0f;
        float _1300 = _1297 / _1299;
        float _1301 = abs(_1300);
        float _1302 = log2(_1301);
        float _1303 = _1302 * 78.84375f;
        float _1304 = exp2(_1303);
        _1306 = _1286;
        _1307 = _1295;
        _1308 = _1304;
      } else {
        _1306 = _1201;
        _1307 = _1202;
        _1308 = _1203;
      }
    }
    u0_space6[int2(_505, _963)] = float4(_1306, _1307, _1308, 1.0f);
    bool _1310 = (_157 == 0);
    if (!_1310) {
      [branch]
      if (_1089) {
        float _1313 = abs(_1077.x);
        float _1314 = abs(_1077.y);
        float _1315 = abs(_1077.z);
        float _1316 = log2(_1313);
        float _1317 = log2(_1314);
        float _1318 = log2(_1315);
        float _1319 = _1316 * resolver_output_params.x;
        float _1320 = _1317 * resolver_output_params.x;
        float _1321 = _1318 * resolver_output_params.x;
        float _1322 = exp2(_1319);
        float _1323 = exp2(_1320);
        float _1324 = exp2(_1321);
        bool _1325 = (_1322 < 0.003100000089034438f);
        if (_1325) {
          float _1327 = _1322 * 12.920000076293945f;
          _1336 = _1327;
        } else {
          float _1329 = abs(_1322);
          float _1330 = log2(_1329);
          float _1331 = _1330 * 0.4166666567325592f;
          float _1332 = exp2(_1331);
          float _1333 = _1332 * 1.0549999475479126f;
          float _1334 = _1333 + -0.054999999701976776f;
          _1336 = _1334;
        }
        bool _1337 = (_1323 < 0.003100000089034438f);
        if (_1337) {
          float _1339 = _1323 * 12.920000076293945f;
          _1348 = _1339;
        } else {
          float _1341 = abs(_1323);
          float _1342 = log2(_1341);
          float _1343 = _1342 * 0.4166666567325592f;
          float _1344 = exp2(_1343);
          float _1345 = _1344 * 1.0549999475479126f;
          float _1346 = _1345 + -0.054999999701976776f;
          _1348 = _1346;
        }
        bool _1349 = (_1324 < 0.003100000089034438f);
        if (_1349) {
          float _1351 = _1324 * 12.920000076293945f;
          _1414 = _1336;
          _1415 = _1348;
          _1416 = _1351;
        } else {
          float _1353 = abs(_1324);
          float _1354 = log2(_1353);
          float _1355 = _1354 * 0.4166666567325592f;
          float _1356 = exp2(_1355);
          float _1357 = _1356 * 1.0549999475479126f;
          float _1358 = _1357 + -0.054999999701976776f;
          _1414 = _1336;
          _1415 = _1348;
          _1416 = _1358;
        }
      } else {
        bool _1360 = (_1088 == 2);
        if (_1360) {
          float _1362 = _1077.x * 0.6274039149284363f;
          float _1363 = mad(0.3292830288410187f, _1077.y, _1362);
          float _1364 = mad(0.04331306740641594f, _1077.z, _1363);
          float _1365 = _1077.x * 0.06909728795289993f;
          float _1366 = mad(0.9195404052734375f, _1077.y, _1365);
          float _1367 = mad(0.011362316086888313f, _1077.z, _1366);
          float _1368 = _1077.x * 0.016391439363360405f;
          float _1369 = mad(0.08801330626010895f, _1077.y, _1368);
          float _1370 = mad(0.8955952525138855f, _1077.z, _1369);
          float _1371 = _1364 * resolver_output_params.y;
          float _1372 = _1367 * resolver_output_params.y;
          float _1373 = _1370 * resolver_output_params.y;
          float _1374 = abs(_1371);
          float _1375 = abs(_1372);
          float _1376 = abs(_1373);
          float _1377 = log2(_1374);
          float _1378 = log2(_1375);
          float _1379 = log2(_1376);
          float _1380 = _1377 * resolver_output_params.x;
          float _1381 = _1378 * resolver_output_params.x;
          float _1382 = _1379 * resolver_output_params.x;
          float _1383 = exp2(_1380);
          float _1384 = exp2(_1381);
          float _1385 = exp2(_1382);
          float _1386 = _1383 * 18.8515625f;
          float _1387 = _1386 + 0.8359375f;
          float _1388 = _1383 * 18.6875f;
          float _1389 = _1388 + 1.0f;
          float _1390 = _1387 / _1389;
          float _1391 = abs(_1390);
          float _1392 = log2(_1391);
          float _1393 = _1392 * 78.84375f;
          float _1394 = exp2(_1393);
          float _1395 = _1384 * 18.8515625f;
          float _1396 = _1395 + 0.8359375f;
          float _1397 = _1384 * 18.6875f;
          float _1398 = _1397 + 1.0f;
          float _1399 = _1396 / _1398;
          float _1400 = abs(_1399);
          float _1401 = log2(_1400);
          float _1402 = _1401 * 78.84375f;
          float _1403 = exp2(_1402);
          float _1404 = _1385 * 18.8515625f;
          float _1405 = _1404 + 0.8359375f;
          float _1406 = _1385 * 18.6875f;
          float _1407 = _1406 + 1.0f;
          float _1408 = _1405 / _1407;
          float _1409 = abs(_1408);
          float _1410 = log2(_1409);
          float _1411 = _1410 * 78.84375f;
          float _1412 = exp2(_1411);
          _1414 = _1394;
          _1415 = _1403;
          _1416 = _1412;
        } else {
          _1414 = _1077.x;
          _1415 = _1077.y;
          _1416 = _1077.z;
        }
      }
      u1_space6[int2(_505, _963)] = float4(_1414, _1415, _1416, _1077.w);
    }
  } else {
    u0_space6[int2(_505, _963)] = float4(_1073, _1074, _1075, 1.0f);
  }
  float4 _1423 = t0_space6.SampleLevel(s0_space5, float2(_39, _967), 0.0f);
  float4 _1427 = t0_space6.SampleLevel(s0_space5, float2(_52, _976), 0.0f);
  float4 _1431 = t0_space6.SampleLevel(s0_space5, float2(_39, _976), 0.0f);
  float4 _1435 = t0_space6.SampleLevel(s0_space5, float2(_65, _976), 0.0f);
  float4 _1439 = t0_space6.SampleLevel(s0_space5, float2(_39, _992), 0.0f);
  float _1443 = min(_1427.x, _1435.x);
  float _1444 = min(_1423.x, _1443);
  float _1445 = min(_1444, _1439.x);
  float _1446 = min(_1427.y, _1435.y);
  float _1447 = min(_1423.y, _1446);
  float _1448 = min(_1447, _1439.y);
  float _1449 = min(_1427.z, _1435.z);
  float _1450 = min(_1423.z, _1449);
  float _1451 = min(_1450, _1439.z);
  float _1452 = max(_1427.x, _1435.x);
  float _1453 = max(_1423.x, _1452);
  float _1454 = max(_1453, _1439.x);
  float _1455 = max(_1427.y, _1435.y);
  float _1456 = max(_1423.y, _1455);
  float _1457 = max(_1456, _1439.y);
  float _1458 = max(_1427.z, _1435.z);
  float _1459 = max(_1423.z, _1458);
  float _1460 = max(_1459, _1439.z);
  float _1461 = 0.25f / _1454;
  float _1462 = 0.25f / _1457;
  float _1463 = 0.25f / _1460;
  float _1464 = 1.0f - _1454;
  float _1465 = _1445 * 4.0f;
  float _1466 = _1465 + -4.0f;
  float _1467 = 1.0f / _1466;
  float _1468 = _1467 * _1464;
  float _1469 = 1.0f - _1457;
  float _1470 = _1448 * 4.0f;
  float _1471 = _1470 + -4.0f;
  float _1472 = 1.0f / _1471;
  float _1473 = _1472 * _1469;
  float _1474 = 1.0f - _1460;
  float _1475 = _1451 * 4.0f;
  float _1476 = _1475 + -4.0f;
  float _1477 = 1.0f / _1476;
  float _1478 = _1477 * _1474;
  float _1479 = _1445 * _1461;
  float _1480 = -0.0f - _1479;
  float _1481 = max(_1480, _1468);
  float _1482 = _1448 * _1462;
  float _1483 = -0.0f - _1482;
  float _1484 = max(_1483, _1473);
  float _1485 = _1451 * _1463;
  float _1486 = -0.0f - _1485;
  float _1487 = max(_1486, _1478);
  float _1488 = max(_1484, _1487);
  float _1489 = max(_1481, _1488);
  float _1490 = min(_1489, 0.0f);
  float _1491 = max(-0.1875f, _1490);
  float _1492 = _1491 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _1493 = _1492 * 4.0f;
  float _1494 = _1493 + 1.0f;
  int _1495 = asint(_1494);
  uint _1496 = 2129764351u - _1495;
  float _1497 = asfloat(_1496);
  float _1498 = _1497 * _1494;
  float _1499 = 2.0f - _1498;
  float _1500 = _1499 * _1497;
  float _1501 = _1427.x + _1423.x;
  float _1502 = _1501 + _1435.x;
  float _1503 = _1502 + _1439.x;
  float _1504 = _1492 * _1503;
  float _1505 = _1504 + _1431.x;
  float _1506 = _1500 * _1505;
  float _1507 = _1427.y + _1423.y;
  float _1508 = _1507 + _1435.y;
  float _1509 = _1508 + _1439.y;
  float _1510 = _1492 * _1509;
  float _1511 = _1510 + _1431.y;
  float _1512 = _1500 * _1511;
  float _1513 = _1427.z + _1423.z;
  float _1514 = _1513 + _1435.z;
  float _1515 = _1514 + _1439.z;
  float _1516 = _1492 * _1515;
  float _1517 = _1516 + _1431.z;
  float _1518 = _1500 * _1517;
  const float3 resolver_color_3 = SelectResolverSharpening(
      float3(_1506, _1512, _1518), _1423.rgb, _1427.rgb, _1431.rgb, _1435.rgb, _1439.rgb,
      resolver_output_params, resolver_normalization_point);
  float _1519 = min(resolver_color_3.x, scene_cap);
  float _1520 = min(resolver_color_3.y, scene_cap);
  float _1521 = min(resolver_color_3.z, scene_cap);
  float4 _1523 = t1_space6.Load(int3(_32, _963, 0));
  float _1528 = max(_1523.y, _1523.z);
  float _1529 = max(_1523.x, _1528);
  float _1530 = _1529 + _1523.w;
  bool _1531 = !(_1530 > 0.0f);
  bool _1532 = _169 || _1531;
  if (!_1532) {
    int _1534 = int(resolver_output_params.w);
    bool _1535 = (_1534 == 1);
    [branch]
    if (_1535) {
      bool _1537 = (_1519 < 0.040449999272823334f);
      if (_1537) {
        float _1539 = _1519 * 0.07739938050508499f;
        _1548 = _1539;
      } else {
        float _1541 = _1519 * 0.9478672742843628f;
        float _1542 = _1541 + 0.05213269963860512f;
        float _1543 = abs(_1542);
        float _1544 = log2(_1543);
        float _1545 = _1544 * 2.4000000953674316f;
        float _1546 = exp2(_1545);
        _1548 = _1546;
      }
      bool _1549 = (_1520 < 0.040449999272823334f);
      if (_1549) {
        float _1551 = _1520 * 0.07739938050508499f;
        _1560 = _1551;
      } else {
        float _1553 = _1520 * 0.9478672742843628f;
        float _1554 = _1553 + 0.05213269963860512f;
        float _1555 = abs(_1554);
        float _1556 = log2(_1555);
        float _1557 = _1556 * 2.4000000953674316f;
        float _1558 = exp2(_1557);
        _1560 = _1558;
      }
      bool _1561 = (_1521 < 0.040449999272823334f);
      if (_1561) {
        float _1563 = _1521 * 0.07739938050508499f;
        _1572 = _1563;
      } else {
        float _1565 = _1521 * 0.9478672742843628f;
        float _1566 = _1565 + 0.05213269963860512f;
        float _1567 = abs(_1566);
        float _1568 = log2(_1567);
        float _1569 = _1568 * 2.4000000953674316f;
        float _1570 = exp2(_1569);
        _1572 = _1570;
      }
      float _1573 = 1.0f / resolver_output_params.x;
      float _1574 = abs(_1548);
      float _1575 = abs(_1560);
      float _1576 = abs(_1572);
      float _1577 = log2(_1574);
      float _1578 = log2(_1575);
      float _1579 = log2(_1576);
      float _1580 = _1577 * _1573;
      float _1581 = _1578 * _1573;
      float _1582 = _1579 * _1573;
      float _1583 = exp2(_1580);
      float _1584 = exp2(_1581);
      float _1585 = exp2(_1582);
      _1640 = _1583;
      _1641 = _1584;
      _1642 = _1585;
    } else {
      bool _1587 = (_1534 == 2);
      if (_1587) {
        float _1589 = abs(_1519);
        float _1590 = abs(_1520);
        float _1591 = abs(_1521);
        float _1592 = log2(_1589);
        float _1593 = log2(_1590);
        float _1594 = log2(_1591);
        float _1595 = _1592 * 0.012683313339948654f;
        float _1596 = _1593 * 0.012683313339948654f;
        float _1597 = _1594 * 0.012683313339948654f;
        float _1598 = exp2(_1595);
        float _1599 = exp2(_1596);
        float _1600 = exp2(_1597);
        float _1601 = _1598 + -0.8359375f;
        float _1602 = _1598 * 18.6875f;
        float _1603 = 18.8515625f - _1602;
        float _1604 = _1601 / _1603;
        float _1605 = _1599 + -0.8359375f;
        float _1606 = _1599 * 18.6875f;
        float _1607 = 18.8515625f - _1606;
        float _1608 = _1605 / _1607;
        float _1609 = _1600 + -0.8359375f;
        float _1610 = _1600 * 18.6875f;
        float _1611 = 18.8515625f - _1610;
        float _1612 = _1609 / _1611;
        float _1613 = 1.0f / resolver_output_params.x;
        float _1614 = abs(_1604);
        float _1615 = abs(_1608);
        float _1616 = abs(_1612);
        float _1617 = log2(_1614);
        float _1618 = log2(_1615);
        float _1619 = log2(_1616);
        float _1620 = _1617 * _1613;
        float _1621 = _1618 * _1613;
        float _1622 = _1619 * _1613;
        float _1623 = exp2(_1620);
        float _1624 = exp2(_1621);
        float _1625 = exp2(_1622);
        float _1626 = 1.0f / resolver_output_params.y;
        float _1627 = _1626 * _1623;
        float _1628 = _1626 * _1624;
        float _1629 = _1626 * _1625;
        float _1630 = _1627 * 1.6604900360107422f;
        float _1631 = mad(-0.5876410007476807f, _1628, _1630);
        float _1632 = mad(-0.07284989953041077f, _1629, _1631);
        float _1633 = _1627 * -0.124549999833107f;
        float _1634 = mad(1.1328999996185303f, _1628, _1633);
        float _1635 = mad(-0.008349419571459293f, _1629, _1634);
        float _1636 = _1627 * -0.018150800839066505f;
        float _1637 = mad(-0.10057900100946426f, _1628, _1636);
        float _1638 = mad(1.1187299489974976f, _1629, _1637);
        _1640 = _1632;
        _1641 = _1635;
        _1642 = _1638;
      } else {
        _1640 = _1519;
        _1641 = _1520;
        _1642 = _1521;
      }
    }
    float _1643 = 1.0f - _1523.w;
    float _1644 = _1640 * _1643;
    float _1645 = _1641 * _1643;
    float _1646 = _1642 * _1643;
    float _1647 = _1644 + _1523.x;
    float _1648 = _1645 + _1523.y;
    float _1649 = _1646 + _1523.z;
    [branch]
    if (_1535) {
      float _1651 = abs(_1647);
      float _1652 = abs(_1648);
      float _1653 = abs(_1649);
      float _1654 = log2(_1651);
      float _1655 = log2(_1652);
      float _1656 = log2(_1653);
      float _1657 = _1654 * resolver_output_params.x;
      float _1658 = _1655 * resolver_output_params.x;
      float _1659 = _1656 * resolver_output_params.x;
      float _1660 = exp2(_1657);
      float _1661 = exp2(_1658);
      float _1662 = exp2(_1659);
      bool _1663 = (_1660 < 0.003100000089034438f);
      if (_1663) {
        float _1665 = _1660 * 12.920000076293945f;
        _1674 = _1665;
      } else {
        float _1667 = abs(_1660);
        float _1668 = log2(_1667);
        float _1669 = _1668 * 0.4166666567325592f;
        float _1670 = exp2(_1669);
        float _1671 = _1670 * 1.0549999475479126f;
        float _1672 = _1671 + -0.054999999701976776f;
        _1674 = _1672;
      }
      bool _1675 = (_1661 < 0.003100000089034438f);
      if (_1675) {
        float _1677 = _1661 * 12.920000076293945f;
        _1686 = _1677;
      } else {
        float _1679 = abs(_1661);
        float _1680 = log2(_1679);
        float _1681 = _1680 * 0.4166666567325592f;
        float _1682 = exp2(_1681);
        float _1683 = _1682 * 1.0549999475479126f;
        float _1684 = _1683 + -0.054999999701976776f;
        _1686 = _1684;
      }
      bool _1687 = (_1662 < 0.003100000089034438f);
      if (_1687) {
        float _1689 = _1662 * 12.920000076293945f;
        _1752 = _1674;
        _1753 = _1686;
        _1754 = _1689;
      } else {
        float _1691 = abs(_1662);
        float _1692 = log2(_1691);
        float _1693 = _1692 * 0.4166666567325592f;
        float _1694 = exp2(_1693);
        float _1695 = _1694 * 1.0549999475479126f;
        float _1696 = _1695 + -0.054999999701976776f;
        _1752 = _1674;
        _1753 = _1686;
        _1754 = _1696;
      }
    } else {
      bool _1698 = (_1534 == 2);
      if (_1698) {
        float _1700 = _1647 * 0.6274039149284363f;
        float _1701 = mad(0.3292830288410187f, _1648, _1700);
        float _1702 = mad(0.04331306740641594f, _1649, _1701);
        float _1703 = _1647 * 0.06909728795289993f;
        float _1704 = mad(0.9195404052734375f, _1648, _1703);
        float _1705 = mad(0.011362316086888313f, _1649, _1704);
        float _1706 = _1647 * 0.016391439363360405f;
        float _1707 = mad(0.08801330626010895f, _1648, _1706);
        float _1708 = mad(0.8955952525138855f, _1649, _1707);
        float _1709 = _1702 * resolver_output_params.y;
        float _1710 = _1705 * resolver_output_params.y;
        float _1711 = _1708 * resolver_output_params.y;
        float _1712 = abs(_1709);
        float _1713 = abs(_1710);
        float _1714 = abs(_1711);
        float _1715 = log2(_1712);
        float _1716 = log2(_1713);
        float _1717 = log2(_1714);
        float _1718 = _1715 * resolver_output_params.x;
        float _1719 = _1716 * resolver_output_params.x;
        float _1720 = _1717 * resolver_output_params.x;
        float _1721 = exp2(_1718);
        float _1722 = exp2(_1719);
        float _1723 = exp2(_1720);
        float _1724 = _1721 * 18.8515625f;
        float _1725 = _1724 + 0.8359375f;
        float _1726 = _1721 * 18.6875f;
        float _1727 = _1726 + 1.0f;
        float _1728 = _1725 / _1727;
        float _1729 = abs(_1728);
        float _1730 = log2(_1729);
        float _1731 = _1730 * 78.84375f;
        float _1732 = exp2(_1731);
        float _1733 = _1722 * 18.8515625f;
        float _1734 = _1733 + 0.8359375f;
        float _1735 = _1722 * 18.6875f;
        float _1736 = _1735 + 1.0f;
        float _1737 = _1734 / _1736;
        float _1738 = abs(_1737);
        float _1739 = log2(_1738);
        float _1740 = _1739 * 78.84375f;
        float _1741 = exp2(_1740);
        float _1742 = _1723 * 18.8515625f;
        float _1743 = _1742 + 0.8359375f;
        float _1744 = _1723 * 18.6875f;
        float _1745 = _1744 + 1.0f;
        float _1746 = _1743 / _1745;
        float _1747 = abs(_1746);
        float _1748 = log2(_1747);
        float _1749 = _1748 * 78.84375f;
        float _1750 = exp2(_1749);
        _1752 = _1732;
        _1753 = _1741;
        _1754 = _1750;
      } else {
        _1752 = _1647;
        _1753 = _1648;
        _1754 = _1649;
      }
    }
    u0_space6[int2(_32, _963)] = float4(_1752, _1753, _1754, 1.0f);
    bool _1756 = (_157 == 0);
    if (!_1756) {
      [branch]
      if (_1535) {
        float _1759 = abs(_1523.x);
        float _1760 = abs(_1523.y);
        float _1761 = abs(_1523.z);
        float _1762 = log2(_1759);
        float _1763 = log2(_1760);
        float _1764 = log2(_1761);
        float _1765 = _1762 * resolver_output_params.x;
        float _1766 = _1763 * resolver_output_params.x;
        float _1767 = _1764 * resolver_output_params.x;
        float _1768 = exp2(_1765);
        float _1769 = exp2(_1766);
        float _1770 = exp2(_1767);
        bool _1771 = (_1768 < 0.003100000089034438f);
        if (_1771) {
          float _1773 = _1768 * 12.920000076293945f;
          _1782 = _1773;
        } else {
          float _1775 = abs(_1768);
          float _1776 = log2(_1775);
          float _1777 = _1776 * 0.4166666567325592f;
          float _1778 = exp2(_1777);
          float _1779 = _1778 * 1.0549999475479126f;
          float _1780 = _1779 + -0.054999999701976776f;
          _1782 = _1780;
        }
        bool _1783 = (_1769 < 0.003100000089034438f);
        if (_1783) {
          float _1785 = _1769 * 12.920000076293945f;
          _1794 = _1785;
        } else {
          float _1787 = abs(_1769);
          float _1788 = log2(_1787);
          float _1789 = _1788 * 0.4166666567325592f;
          float _1790 = exp2(_1789);
          float _1791 = _1790 * 1.0549999475479126f;
          float _1792 = _1791 + -0.054999999701976776f;
          _1794 = _1792;
        }
        bool _1795 = (_1770 < 0.003100000089034438f);
        if (_1795) {
          float _1797 = _1770 * 12.920000076293945f;
          _1860 = _1782;
          _1861 = _1794;
          _1862 = _1797;
        } else {
          float _1799 = abs(_1770);
          float _1800 = log2(_1799);
          float _1801 = _1800 * 0.4166666567325592f;
          float _1802 = exp2(_1801);
          float _1803 = _1802 * 1.0549999475479126f;
          float _1804 = _1803 + -0.054999999701976776f;
          _1860 = _1782;
          _1861 = _1794;
          _1862 = _1804;
        }
      } else {
        bool _1806 = (_1534 == 2);
        if (_1806) {
          float _1808 = _1523.x * 0.6274039149284363f;
          float _1809 = mad(0.3292830288410187f, _1523.y, _1808);
          float _1810 = mad(0.04331306740641594f, _1523.z, _1809);
          float _1811 = _1523.x * 0.06909728795289993f;
          float _1812 = mad(0.9195404052734375f, _1523.y, _1811);
          float _1813 = mad(0.011362316086888313f, _1523.z, _1812);
          float _1814 = _1523.x * 0.016391439363360405f;
          float _1815 = mad(0.08801330626010895f, _1523.y, _1814);
          float _1816 = mad(0.8955952525138855f, _1523.z, _1815);
          float _1817 = _1810 * resolver_output_params.y;
          float _1818 = _1813 * resolver_output_params.y;
          float _1819 = _1816 * resolver_output_params.y;
          float _1820 = abs(_1817);
          float _1821 = abs(_1818);
          float _1822 = abs(_1819);
          float _1823 = log2(_1820);
          float _1824 = log2(_1821);
          float _1825 = log2(_1822);
          float _1826 = _1823 * resolver_output_params.x;
          float _1827 = _1824 * resolver_output_params.x;
          float _1828 = _1825 * resolver_output_params.x;
          float _1829 = exp2(_1826);
          float _1830 = exp2(_1827);
          float _1831 = exp2(_1828);
          float _1832 = _1829 * 18.8515625f;
          float _1833 = _1832 + 0.8359375f;
          float _1834 = _1829 * 18.6875f;
          float _1835 = _1834 + 1.0f;
          float _1836 = _1833 / _1835;
          float _1837 = abs(_1836);
          float _1838 = log2(_1837);
          float _1839 = _1838 * 78.84375f;
          float _1840 = exp2(_1839);
          float _1841 = _1830 * 18.8515625f;
          float _1842 = _1841 + 0.8359375f;
          float _1843 = _1830 * 18.6875f;
          float _1844 = _1843 + 1.0f;
          float _1845 = _1842 / _1844;
          float _1846 = abs(_1845);
          float _1847 = log2(_1846);
          float _1848 = _1847 * 78.84375f;
          float _1849 = exp2(_1848);
          float _1850 = _1831 * 18.8515625f;
          float _1851 = _1850 + 0.8359375f;
          float _1852 = _1831 * 18.6875f;
          float _1853 = _1852 + 1.0f;
          float _1854 = _1851 / _1853;
          float _1855 = abs(_1854);
          float _1856 = log2(_1855);
          float _1857 = _1856 * 78.84375f;
          float _1858 = exp2(_1857);
          _1860 = _1840;
          _1861 = _1849;
          _1862 = _1858;
        } else {
          _1860 = _1523.x;
          _1861 = _1523.y;
          _1862 = _1523.z;
        }
      }
      u1_space6[int2(_32, _963)] = float4(_1860, _1861, _1862, _1523.w);
    }
  } else {
    u0_space6[int2(_32, _963)] = float4(_1519, _1520, _1521, 1.0f);
  }
}

#endif  // SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0X9C79EDC7_HLSLI_
