#ifndef SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0X6089C217_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0X6089C217_HLSLI_

// AA/upscale resolver over the encoded frame: decode -> temporal resolve -> encode.
// Decompiled from the game's DXIL. The RenoDX edits are GetResolverOutputParams and the
// optional RCAS in SelectResolverSharpening; both are documented where they are defined.
//
// Shared by HZDR 0x6089C217 and HFW 0x65C56B76: both games ship this program with the same
// instructions and the same constants. This variant binds no sampler in either game.

#include "../common.hlsli"
#include "./resolver_bindings.hlsli"

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
  int _20 = (uint)(SV_GroupThreadID.x) >> 1;
  int _21 = _20 & 7;
  int _22 = (uint)(SV_GroupThreadID.x) >> 3;
  int _23 = (uint)(SV_GroupThreadID.x) & 1;
  int _24 = _22 & 6;
  int _25 = _24 | _23;
  uint _26 = (uint)(SV_GroupID.x) << 4;
  uint _27 = (uint)(SV_GroupID.y) << 4;
  int _28 = _21 | _26;
  int _29 = _25 | _27;
  int _30 = asint(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.y);
  uint _31 = _28 << 16;
  uint _32 = _31 >> 16;
  uint _33 = _29 << 16;
  uint _34 = _33 + -65536u;
  uint _35 = _34 >> 16;
  float4 _37 = t0_space6.Load(int3(_32, _35, 0));
  half _41 = half(_37.x);
  half _42 = half(_37.y);
  half _43 = half(_37.z);
  uint _44 = _31 + -65536u;
  uint _45 = _44 >> 16;
  uint _46 = _33 >> 16;
  float4 _47 = t0_space6.Load(int3(_45, _46, 0));
  half _51 = half(_47.x);
  half _52 = half(_47.y);
  half _53 = half(_47.z);
  float4 _54 = t0_space6.Load(int3(_32, _46, 0));
  half _58 = half(_54.x);
  half _59 = half(_54.y);
  half _60 = half(_54.z);
  int _61 = _31 + 65536;
  uint _62 = _61 >> 16;
  float4 _63 = t0_space6.Load(int3(_62, _46, 0));
  half _67 = half(_63.x);
  half _68 = half(_63.y);
  half _69 = half(_63.z);
  int _70 = _33 + 65536;
  uint _71 = _70 >> 16;
  float4 _72 = t0_space6.Load(int3(_32, _71, 0));
  half _76 = half(_72.x);
  half _77 = half(_72.y);
  half _78 = half(_72.z);
  half _79 = min(_51, _67);
  half _80 = min(_41, _79);
  half _81 = min(_80, _76);
  half _82 = min(_52, _68);
  half _83 = min(_42, _82);
  half _84 = min(_83, _77);
  half _85 = min(_53, _69);
  half _86 = min(_43, _85);
  half _87 = min(_86, _78);
  half _88 = max(_51, _67);
  half _89 = max(_41, _88);
  half _90 = max(_89, _76);
  half _91 = max(_52, _68);
  half _92 = max(_42, _91);
  half _93 = max(_92, _77);
  half _94 = max(_53, _69);
  half _95 = max(_43, _94);
  half _96 = max(_95, _78);
  half _97 = 0.25h / _90;
  half _98 = 0.25h / _93;
  half _99 = 0.25h / _96;
  half _100 = 1.0h - _90;
  half _101 = _81 * 4.0h;
  half _102 = _101 + -4.0h;
  half _103 = 1.0h / _102;
  half _104 = _103 * _100;
  half _105 = 1.0h - _93;
  half _106 = _84 * 4.0h;
  half _107 = _106 + -4.0h;
  half _108 = 1.0h / _107;
  half _109 = _108 * _105;
  half _110 = 1.0h - _96;
  half _111 = _87 * 4.0h;
  half _112 = _111 + -4.0h;
  half _113 = 1.0h / _112;
  half _114 = _113 * _110;
  half _115 = _81 * _97;
  half _116 = -0.0h - _115;
  half _117 = max(_116, _104);
  half _118 = _84 * _98;
  half _119 = -0.0h - _118;
  half _120 = max(_119, _109);
  half _121 = _87 * _99;
  half _122 = -0.0h - _121;
  half _123 = max(_122, _114);
  half _124 = max(_120, _123);
  half _125 = max(_117, _124);
  half _126 = min(_125, 0.0h);
  half _127 = max(-0.1875h, _126);
  int _128 = _30 & 65535;
  float _129 = f16tof32(_128);
  half _130 = half(_129);
  half _131 = _130 * _127;
  half _132 = _131 * 4.0h;
  half _133 = _132 + 1.0h;
  float _134 = float(_133);
  uint _135 = f32tof16(_134);
  uint _136 = 30605u - _135;
  int _137 = _136 & 65535;
  float _138 = f16tof32(_137);
  half _139 = half(_138);
  half _140 = _133 * _139;
  half _141 = 2.0h - _140;
  half _142 = _141 * _139;
  half _143 = _51 + _41;
  half _144 = _143 + _67;
  half _145 = _144 + _76;
  half _146 = _131 * _145;
  half _147 = _146 + _58;
  half _148 = _142 * _147;
  half _149 = _52 + _42;
  half _150 = _149 + _68;
  half _151 = _150 + _77;
  half _152 = _131 * _151;
  half _153 = _152 + _59;
  half _154 = _142 * _153;
  half _155 = _53 + _43;
  half _156 = _155 + _69;
  half _157 = _156 + _78;
  half _158 = _131 * _157;
  half _159 = _158 + _60;
  half _160 = _142 * _159;
  const float3 resolver_color_0 = SelectResolverSharpening(
      float3(_148, _154, _160), _37.rgb, _47.rgb, _54.rgb, _63.rgb, _72.rgb,
      resolver_output_params, resolver_normalization_point);
  half _161 = half(resolver_output_params.z);
  half _162 = min(half(resolver_color_0.x), _161);
  half _163 = min(half(resolver_color_0.y), _161);
  half _164 = min(half(resolver_color_0.z), _161);
  int _165 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.x);
  int _166 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.y);
  float4 _168 = t1_space6.Load(int3(_28, _29, 0));
  float _173 = max(_168.y, _168.z);
  float _174 = max(_168.x, _173);
  float _175 = _174 + _168.w;
  bool _176 = !(_175 > 0.0f);
  bool _177 = (_166 != 0);
  bool _178 = _177 || _176;
  float _179 = float(_162);
  float _180 = float(_163);
  float _181 = float(_164);
  float _197;
  float _209;
  float _221;
  float _289;
  float _290;
  float _291;
  float _323;
  float _335;
  float _401;
  float _402;
  float _403;
  float _431;
  float _443;
  float _509;
  float _510;
  float _511;
  float _670;
  float _682;
  float _694;
  float _762;
  float _763;
  float _764;
  float _796;
  float _808;
  float _874;
  float _875;
  float _876;
  float _904;
  float _916;
  float _982;
  float _983;
  float _984;
  float _1143;
  float _1155;
  float _1167;
  float _1235;
  float _1236;
  float _1237;
  float _1269;
  float _1281;
  float _1347;
  float _1348;
  float _1349;
  float _1377;
  float _1389;
  float _1455;
  float _1456;
  float _1457;
  float _1609;
  float _1621;
  float _1633;
  float _1701;
  float _1702;
  float _1703;
  float _1735;
  float _1747;
  float _1813;
  float _1814;
  float _1815;
  float _1843;
  float _1855;
  float _1921;
  float _1922;
  float _1923;
  if (!_178) {
    int _183 = int(resolver_output_params.w);
    bool _184 = (_183 == 1);
    [branch]
    if (_184) {
      bool _186 = (_179 < 0.040449999272823334f);
      if (_186) {
        float _188 = _179 * 0.07739938050508499f;
        _197 = _188;
      } else {
        float _190 = _179 * 0.9478672742843628f;
        float _191 = _190 + 0.05213269963860512f;
        float _192 = abs(_191);
        float _193 = log2(_192);
        float _194 = _193 * 2.4000000953674316f;
        float _195 = exp2(_194);
        _197 = _195;
      }
      bool _198 = (_180 < 0.040449999272823334f);
      if (_198) {
        float _200 = _180 * 0.07739938050508499f;
        _209 = _200;
      } else {
        float _202 = _180 * 0.9478672742843628f;
        float _203 = _202 + 0.05213269963860512f;
        float _204 = abs(_203);
        float _205 = log2(_204);
        float _206 = _205 * 2.4000000953674316f;
        float _207 = exp2(_206);
        _209 = _207;
      }
      bool _210 = (_181 < 0.040449999272823334f);
      if (_210) {
        float _212 = _181 * 0.07739938050508499f;
        _221 = _212;
      } else {
        float _214 = _181 * 0.9478672742843628f;
        float _215 = _214 + 0.05213269963860512f;
        float _216 = abs(_215);
        float _217 = log2(_216);
        float _218 = _217 * 2.4000000953674316f;
        float _219 = exp2(_218);
        _221 = _219;
      }
      float _222 = 1.0f / resolver_output_params.x;
      float _223 = abs(_197);
      float _224 = abs(_209);
      float _225 = abs(_221);
      float _226 = log2(_223);
      float _227 = log2(_224);
      float _228 = log2(_225);
      float _229 = _226 * _222;
      float _230 = _227 * _222;
      float _231 = _228 * _222;
      float _232 = exp2(_229);
      float _233 = exp2(_230);
      float _234 = exp2(_231);
      _289 = _232;
      _290 = _233;
      _291 = _234;
    } else {
      bool _236 = (_183 == 2);
      if (_236) {
        float _238 = abs(_179);
        float _239 = abs(_180);
        float _240 = abs(_181);
        float _241 = log2(_238);
        float _242 = log2(_239);
        float _243 = log2(_240);
        float _244 = _241 * 0.012683313339948654f;
        float _245 = _242 * 0.012683313339948654f;
        float _246 = _243 * 0.012683313339948654f;
        float _247 = exp2(_244);
        float _248 = exp2(_245);
        float _249 = exp2(_246);
        float _250 = _247 + -0.8359375f;
        float _251 = _247 * 18.6875f;
        float _252 = 18.8515625f - _251;
        float _253 = _250 / _252;
        float _254 = _248 + -0.8359375f;
        float _255 = _248 * 18.6875f;
        float _256 = 18.8515625f - _255;
        float _257 = _254 / _256;
        float _258 = _249 + -0.8359375f;
        float _259 = _249 * 18.6875f;
        float _260 = 18.8515625f - _259;
        float _261 = _258 / _260;
        float _262 = 1.0f / resolver_output_params.x;
        float _263 = abs(_253);
        float _264 = abs(_257);
        float _265 = abs(_261);
        float _266 = log2(_263);
        float _267 = log2(_264);
        float _268 = log2(_265);
        float _269 = _266 * _262;
        float _270 = _267 * _262;
        float _271 = _268 * _262;
        float _272 = exp2(_269);
        float _273 = exp2(_270);
        float _274 = exp2(_271);
        float _275 = 1.0f / resolver_output_params.y;
        float _276 = _275 * _272;
        float _277 = _275 * _273;
        float _278 = _275 * _274;
        float _279 = _276 * 1.6604900360107422f;
        float _280 = mad(-0.5876410007476807f, _277, _279);
        float _281 = mad(-0.07284989953041077f, _278, _280);
        float _282 = _276 * -0.124549999833107f;
        float _283 = mad(1.1328999996185303f, _277, _282);
        float _284 = mad(-0.008349419571459293f, _278, _283);
        float _285 = _276 * -0.018150800839066505f;
        float _286 = mad(-0.10057900100946426f, _277, _285);
        float _287 = mad(1.1187299489974976f, _278, _286);
        _289 = _281;
        _290 = _284;
        _291 = _287;
      } else {
        _289 = _179;
        _290 = _180;
        _291 = _181;
      }
    }
    float _292 = 1.0f - _168.w;
    float _293 = _289 * _292;
    float _294 = _290 * _292;
    float _295 = _291 * _292;
    float _296 = _293 + _168.x;
    float _297 = _294 + _168.y;
    float _298 = _295 + _168.z;
    [branch]
    if (_184) {
      float _300 = abs(_296);
      float _301 = abs(_297);
      float _302 = abs(_298);
      float _303 = log2(_300);
      float _304 = log2(_301);
      float _305 = log2(_302);
      float _306 = _303 * resolver_output_params.x;
      float _307 = _304 * resolver_output_params.x;
      float _308 = _305 * resolver_output_params.x;
      float _309 = exp2(_306);
      float _310 = exp2(_307);
      float _311 = exp2(_308);
      bool _312 = (_309 < 0.003100000089034438f);
      if (_312) {
        float _314 = _309 * 12.920000076293945f;
        _323 = _314;
      } else {
        float _316 = abs(_309);
        float _317 = log2(_316);
        float _318 = _317 * 0.4166666567325592f;
        float _319 = exp2(_318);
        float _320 = _319 * 1.0549999475479126f;
        float _321 = _320 + -0.054999999701976776f;
        _323 = _321;
      }
      bool _324 = (_310 < 0.003100000089034438f);
      if (_324) {
        float _326 = _310 * 12.920000076293945f;
        _335 = _326;
      } else {
        float _328 = abs(_310);
        float _329 = log2(_328);
        float _330 = _329 * 0.4166666567325592f;
        float _331 = exp2(_330);
        float _332 = _331 * 1.0549999475479126f;
        float _333 = _332 + -0.054999999701976776f;
        _335 = _333;
      }
      bool _336 = (_311 < 0.003100000089034438f);
      if (_336) {
        float _338 = _311 * 12.920000076293945f;
        _401 = _323;
        _402 = _335;
        _403 = _338;
      } else {
        float _340 = abs(_311);
        float _341 = log2(_340);
        float _342 = _341 * 0.4166666567325592f;
        float _343 = exp2(_342);
        float _344 = _343 * 1.0549999475479126f;
        float _345 = _344 + -0.054999999701976776f;
        _401 = _323;
        _402 = _335;
        _403 = _345;
      }
    } else {
      bool _347 = (_183 == 2);
      if (_347) {
        float _349 = _296 * 0.6274039149284363f;
        float _350 = mad(0.3292830288410187f, _297, _349);
        float _351 = mad(0.04331306740641594f, _298, _350);
        float _352 = _296 * 0.06909728795289993f;
        float _353 = mad(0.9195404052734375f, _297, _352);
        float _354 = mad(0.011362316086888313f, _298, _353);
        float _355 = _296 * 0.016391439363360405f;
        float _356 = mad(0.08801330626010895f, _297, _355);
        float _357 = mad(0.8955952525138855f, _298, _356);
        float _358 = _351 * resolver_output_params.y;
        float _359 = _354 * resolver_output_params.y;
        float _360 = _357 * resolver_output_params.y;
        float _361 = abs(_358);
        float _362 = abs(_359);
        float _363 = abs(_360);
        float _364 = log2(_361);
        float _365 = log2(_362);
        float _366 = log2(_363);
        float _367 = _364 * resolver_output_params.x;
        float _368 = _365 * resolver_output_params.x;
        float _369 = _366 * resolver_output_params.x;
        float _370 = exp2(_367);
        float _371 = exp2(_368);
        float _372 = exp2(_369);
        float _373 = _370 * 18.8515625f;
        float _374 = _373 + 0.8359375f;
        float _375 = _370 * 18.6875f;
        float _376 = _375 + 1.0f;
        float _377 = _374 / _376;
        float _378 = abs(_377);
        float _379 = log2(_378);
        float _380 = _379 * 78.84375f;
        float _381 = exp2(_380);
        float _382 = _371 * 18.8515625f;
        float _383 = _382 + 0.8359375f;
        float _384 = _371 * 18.6875f;
        float _385 = _384 + 1.0f;
        float _386 = _383 / _385;
        float _387 = abs(_386);
        float _388 = log2(_387);
        float _389 = _388 * 78.84375f;
        float _390 = exp2(_389);
        float _391 = _372 * 18.8515625f;
        float _392 = _391 + 0.8359375f;
        float _393 = _372 * 18.6875f;
        float _394 = _393 + 1.0f;
        float _395 = _392 / _394;
        float _396 = abs(_395);
        float _397 = log2(_396);
        float _398 = _397 * 78.84375f;
        float _399 = exp2(_398);
        _401 = _381;
        _402 = _390;
        _403 = _399;
      } else {
        _401 = _296;
        _402 = _297;
        _403 = _298;
      }
    }
    u0_space6[int2(_28, _29)] = float4(_401, _402, _403, 1.0f);
    bool _405 = (_165 == 0);
    if (!_405) {
      [branch]
      if (_184) {
        float _408 = abs(_168.x);
        float _409 = abs(_168.y);
        float _410 = abs(_168.z);
        float _411 = log2(_408);
        float _412 = log2(_409);
        float _413 = log2(_410);
        float _414 = _411 * resolver_output_params.x;
        float _415 = _412 * resolver_output_params.x;
        float _416 = _413 * resolver_output_params.x;
        float _417 = exp2(_414);
        float _418 = exp2(_415);
        float _419 = exp2(_416);
        bool _420 = (_417 < 0.003100000089034438f);
        if (_420) {
          float _422 = _417 * 12.920000076293945f;
          _431 = _422;
        } else {
          float _424 = abs(_417);
          float _425 = log2(_424);
          float _426 = _425 * 0.4166666567325592f;
          float _427 = exp2(_426);
          float _428 = _427 * 1.0549999475479126f;
          float _429 = _428 + -0.054999999701976776f;
          _431 = _429;
        }
        bool _432 = (_418 < 0.003100000089034438f);
        if (_432) {
          float _434 = _418 * 12.920000076293945f;
          _443 = _434;
        } else {
          float _436 = abs(_418);
          float _437 = log2(_436);
          float _438 = _437 * 0.4166666567325592f;
          float _439 = exp2(_438);
          float _440 = _439 * 1.0549999475479126f;
          float _441 = _440 + -0.054999999701976776f;
          _443 = _441;
        }
        bool _444 = (_419 < 0.003100000089034438f);
        if (_444) {
          float _446 = _419 * 12.920000076293945f;
          _509 = _431;
          _510 = _443;
          _511 = _446;
        } else {
          float _448 = abs(_419);
          float _449 = log2(_448);
          float _450 = _449 * 0.4166666567325592f;
          float _451 = exp2(_450);
          float _452 = _451 * 1.0549999475479126f;
          float _453 = _452 + -0.054999999701976776f;
          _509 = _431;
          _510 = _443;
          _511 = _453;
        }
      } else {
        bool _455 = (_183 == 2);
        if (_455) {
          float _457 = _168.x * 0.6274039149284363f;
          float _458 = mad(0.3292830288410187f, _168.y, _457);
          float _459 = mad(0.04331306740641594f, _168.z, _458);
          float _460 = _168.x * 0.06909728795289993f;
          float _461 = mad(0.9195404052734375f, _168.y, _460);
          float _462 = mad(0.011362316086888313f, _168.z, _461);
          float _463 = _168.x * 0.016391439363360405f;
          float _464 = mad(0.08801330626010895f, _168.y, _463);
          float _465 = mad(0.8955952525138855f, _168.z, _464);
          float _466 = _459 * resolver_output_params.y;
          float _467 = _462 * resolver_output_params.y;
          float _468 = _465 * resolver_output_params.y;
          float _469 = abs(_466);
          float _470 = abs(_467);
          float _471 = abs(_468);
          float _472 = log2(_469);
          float _473 = log2(_470);
          float _474 = log2(_471);
          float _475 = _472 * resolver_output_params.x;
          float _476 = _473 * resolver_output_params.x;
          float _477 = _474 * resolver_output_params.x;
          float _478 = exp2(_475);
          float _479 = exp2(_476);
          float _480 = exp2(_477);
          float _481 = _478 * 18.8515625f;
          float _482 = _481 + 0.8359375f;
          float _483 = _478 * 18.6875f;
          float _484 = _483 + 1.0f;
          float _485 = _482 / _484;
          float _486 = abs(_485);
          float _487 = log2(_486);
          float _488 = _487 * 78.84375f;
          float _489 = exp2(_488);
          float _490 = _479 * 18.8515625f;
          float _491 = _490 + 0.8359375f;
          float _492 = _479 * 18.6875f;
          float _493 = _492 + 1.0f;
          float _494 = _491 / _493;
          float _495 = abs(_494);
          float _496 = log2(_495);
          float _497 = _496 * 78.84375f;
          float _498 = exp2(_497);
          float _499 = _480 * 18.8515625f;
          float _500 = _499 + 0.8359375f;
          float _501 = _480 * 18.6875f;
          float _502 = _501 + 1.0f;
          float _503 = _500 / _502;
          float _504 = abs(_503);
          float _505 = log2(_504);
          float _506 = _505 * 78.84375f;
          float _507 = exp2(_506);
          _509 = _489;
          _510 = _498;
          _511 = _507;
        } else {
          _509 = _168.x;
          _510 = _168.y;
          _511 = _168.z;
        }
      }
      u1_space6[int2(_28, _29)] = float4(_509, _510, _511, _168.w);
    }
  } else {
    u0_space6[int2(_28, _29)] = float4(_179, _180, _181, 1.0f);
  }
  int _516 = _28 | 8;
  uint _517 = _516 << 16;
  uint _518 = _517 >> 16;
  float4 _520 = t0_space6.Load(int3(_518, _35, 0));
  half _524 = half(_520.x);
  half _525 = half(_520.y);
  half _526 = half(_520.z);
  uint _527 = _517 + -65536u;
  uint _528 = _527 >> 16;
  float4 _529 = t0_space6.Load(int3(_528, _46, 0));
  half _533 = half(_529.x);
  half _534 = half(_529.y);
  half _535 = half(_529.z);
  float4 _536 = t0_space6.Load(int3(_518, _46, 0));
  half _540 = half(_536.x);
  half _541 = half(_536.y);
  half _542 = half(_536.z);
  uint _543 = _517 + 65536u;
  uint _544 = _543 >> 16;
  float4 _545 = t0_space6.Load(int3(_544, _46, 0));
  half _549 = half(_545.x);
  half _550 = half(_545.y);
  half _551 = half(_545.z);
  float4 _552 = t0_space6.Load(int3(_518, _71, 0));
  half _556 = half(_552.x);
  half _557 = half(_552.y);
  half _558 = half(_552.z);
  half _559 = min(_533, _549);
  half _560 = min(_524, _559);
  half _561 = min(_560, _556);
  half _562 = min(_534, _550);
  half _563 = min(_525, _562);
  half _564 = min(_563, _557);
  half _565 = min(_535, _551);
  half _566 = min(_526, _565);
  half _567 = min(_566, _558);
  half _568 = max(_533, _549);
  half _569 = max(_524, _568);
  half _570 = max(_569, _556);
  half _571 = max(_534, _550);
  half _572 = max(_525, _571);
  half _573 = max(_572, _557);
  half _574 = max(_535, _551);
  half _575 = max(_526, _574);
  half _576 = max(_575, _558);
  half _577 = 0.25h / _570;
  half _578 = 0.25h / _573;
  half _579 = 0.25h / _576;
  half _580 = 1.0h - _570;
  half _581 = _561 * 4.0h;
  half _582 = _581 + -4.0h;
  half _583 = 1.0h / _582;
  half _584 = _583 * _580;
  half _585 = 1.0h - _573;
  half _586 = _564 * 4.0h;
  half _587 = _586 + -4.0h;
  half _588 = 1.0h / _587;
  half _589 = _588 * _585;
  half _590 = 1.0h - _576;
  half _591 = _567 * 4.0h;
  half _592 = _591 + -4.0h;
  half _593 = 1.0h / _592;
  half _594 = _593 * _590;
  half _595 = _561 * _577;
  half _596 = -0.0h - _595;
  half _597 = max(_596, _584);
  half _598 = _564 * _578;
  half _599 = -0.0h - _598;
  half _600 = max(_599, _589);
  half _601 = _567 * _579;
  half _602 = -0.0h - _601;
  half _603 = max(_602, _594);
  half _604 = max(_600, _603);
  half _605 = max(_597, _604);
  half _606 = min(_605, 0.0h);
  half _607 = max(-0.1875h, _606);
  half _608 = _130 * _607;
  half _609 = _608 * 4.0h;
  half _610 = _609 + 1.0h;
  float _611 = float(_610);
  uint _612 = f32tof16(_611);
  uint _613 = 30605u - _612;
  int _614 = _613 & 65535;
  float _615 = f16tof32(_614);
  half _616 = half(_615);
  half _617 = _610 * _616;
  half _618 = 2.0h - _617;
  half _619 = _618 * _616;
  half _620 = _533 + _524;
  half _621 = _620 + _549;
  half _622 = _621 + _556;
  half _623 = _608 * _622;
  half _624 = _623 + _540;
  half _625 = _619 * _624;
  half _626 = _534 + _525;
  half _627 = _626 + _550;
  half _628 = _627 + _557;
  half _629 = _608 * _628;
  half _630 = _629 + _541;
  half _631 = _619 * _630;
  half _632 = _535 + _526;
  half _633 = _632 + _551;
  half _634 = _633 + _558;
  half _635 = _608 * _634;
  half _636 = _635 + _542;
  half _637 = _619 * _636;
  const float3 resolver_color_1 = SelectResolverSharpening(
      float3(_625, _631, _637), _520.rgb, _529.rgb, _536.rgb, _545.rgb, _552.rgb,
      resolver_output_params, resolver_normalization_point);
  half _638 = min(half(resolver_color_1.x), _161);
  half _639 = min(half(resolver_color_1.y), _161);
  half _640 = min(half(resolver_color_1.z), _161);
  float4 _642 = t1_space6.Load(int3(_516, _29, 0));
  float _647 = max(_642.y, _642.z);
  float _648 = max(_642.x, _647);
  float _649 = _648 + _642.w;
  bool _650 = !(_649 > 0.0f);
  bool _651 = _177 || _650;
  float _652 = float(_638);
  float _653 = float(_639);
  float _654 = float(_640);
  if (!_651) {
    int _656 = int(resolver_output_params.w);
    bool _657 = (_656 == 1);
    [branch]
    if (_657) {
      bool _659 = (_652 < 0.040449999272823334f);
      if (_659) {
        float _661 = _652 * 0.07739938050508499f;
        _670 = _661;
      } else {
        float _663 = _652 * 0.9478672742843628f;
        float _664 = _663 + 0.05213269963860512f;
        float _665 = abs(_664);
        float _666 = log2(_665);
        float _667 = _666 * 2.4000000953674316f;
        float _668 = exp2(_667);
        _670 = _668;
      }
      bool _671 = (_653 < 0.040449999272823334f);
      if (_671) {
        float _673 = _653 * 0.07739938050508499f;
        _682 = _673;
      } else {
        float _675 = _653 * 0.9478672742843628f;
        float _676 = _675 + 0.05213269963860512f;
        float _677 = abs(_676);
        float _678 = log2(_677);
        float _679 = _678 * 2.4000000953674316f;
        float _680 = exp2(_679);
        _682 = _680;
      }
      bool _683 = (_654 < 0.040449999272823334f);
      if (_683) {
        float _685 = _654 * 0.07739938050508499f;
        _694 = _685;
      } else {
        float _687 = _654 * 0.9478672742843628f;
        float _688 = _687 + 0.05213269963860512f;
        float _689 = abs(_688);
        float _690 = log2(_689);
        float _691 = _690 * 2.4000000953674316f;
        float _692 = exp2(_691);
        _694 = _692;
      }
      float _695 = 1.0f / resolver_output_params.x;
      float _696 = abs(_670);
      float _697 = abs(_682);
      float _698 = abs(_694);
      float _699 = log2(_696);
      float _700 = log2(_697);
      float _701 = log2(_698);
      float _702 = _699 * _695;
      float _703 = _700 * _695;
      float _704 = _701 * _695;
      float _705 = exp2(_702);
      float _706 = exp2(_703);
      float _707 = exp2(_704);
      _762 = _705;
      _763 = _706;
      _764 = _707;
    } else {
      bool _709 = (_656 == 2);
      if (_709) {
        float _711 = abs(_652);
        float _712 = abs(_653);
        float _713 = abs(_654);
        float _714 = log2(_711);
        float _715 = log2(_712);
        float _716 = log2(_713);
        float _717 = _714 * 0.012683313339948654f;
        float _718 = _715 * 0.012683313339948654f;
        float _719 = _716 * 0.012683313339948654f;
        float _720 = exp2(_717);
        float _721 = exp2(_718);
        float _722 = exp2(_719);
        float _723 = _720 + -0.8359375f;
        float _724 = _720 * 18.6875f;
        float _725 = 18.8515625f - _724;
        float _726 = _723 / _725;
        float _727 = _721 + -0.8359375f;
        float _728 = _721 * 18.6875f;
        float _729 = 18.8515625f - _728;
        float _730 = _727 / _729;
        float _731 = _722 + -0.8359375f;
        float _732 = _722 * 18.6875f;
        float _733 = 18.8515625f - _732;
        float _734 = _731 / _733;
        float _735 = 1.0f / resolver_output_params.x;
        float _736 = abs(_726);
        float _737 = abs(_730);
        float _738 = abs(_734);
        float _739 = log2(_736);
        float _740 = log2(_737);
        float _741 = log2(_738);
        float _742 = _739 * _735;
        float _743 = _740 * _735;
        float _744 = _741 * _735;
        float _745 = exp2(_742);
        float _746 = exp2(_743);
        float _747 = exp2(_744);
        float _748 = 1.0f / resolver_output_params.y;
        float _749 = _748 * _745;
        float _750 = _748 * _746;
        float _751 = _748 * _747;
        float _752 = _749 * 1.6604900360107422f;
        float _753 = mad(-0.5876410007476807f, _750, _752);
        float _754 = mad(-0.07284989953041077f, _751, _753);
        float _755 = _749 * -0.124549999833107f;
        float _756 = mad(1.1328999996185303f, _750, _755);
        float _757 = mad(-0.008349419571459293f, _751, _756);
        float _758 = _749 * -0.018150800839066505f;
        float _759 = mad(-0.10057900100946426f, _750, _758);
        float _760 = mad(1.1187299489974976f, _751, _759);
        _762 = _754;
        _763 = _757;
        _764 = _760;
      } else {
        _762 = _652;
        _763 = _653;
        _764 = _654;
      }
    }
    float _765 = 1.0f - _642.w;
    float _766 = _762 * _765;
    float _767 = _763 * _765;
    float _768 = _764 * _765;
    float _769 = _766 + _642.x;
    float _770 = _767 + _642.y;
    float _771 = _768 + _642.z;
    [branch]
    if (_657) {
      float _773 = abs(_769);
      float _774 = abs(_770);
      float _775 = abs(_771);
      float _776 = log2(_773);
      float _777 = log2(_774);
      float _778 = log2(_775);
      float _779 = _776 * resolver_output_params.x;
      float _780 = _777 * resolver_output_params.x;
      float _781 = _778 * resolver_output_params.x;
      float _782 = exp2(_779);
      float _783 = exp2(_780);
      float _784 = exp2(_781);
      bool _785 = (_782 < 0.003100000089034438f);
      if (_785) {
        float _787 = _782 * 12.920000076293945f;
        _796 = _787;
      } else {
        float _789 = abs(_782);
        float _790 = log2(_789);
        float _791 = _790 * 0.4166666567325592f;
        float _792 = exp2(_791);
        float _793 = _792 * 1.0549999475479126f;
        float _794 = _793 + -0.054999999701976776f;
        _796 = _794;
      }
      bool _797 = (_783 < 0.003100000089034438f);
      if (_797) {
        float _799 = _783 * 12.920000076293945f;
        _808 = _799;
      } else {
        float _801 = abs(_783);
        float _802 = log2(_801);
        float _803 = _802 * 0.4166666567325592f;
        float _804 = exp2(_803);
        float _805 = _804 * 1.0549999475479126f;
        float _806 = _805 + -0.054999999701976776f;
        _808 = _806;
      }
      bool _809 = (_784 < 0.003100000089034438f);
      if (_809) {
        float _811 = _784 * 12.920000076293945f;
        _874 = _796;
        _875 = _808;
        _876 = _811;
      } else {
        float _813 = abs(_784);
        float _814 = log2(_813);
        float _815 = _814 * 0.4166666567325592f;
        float _816 = exp2(_815);
        float _817 = _816 * 1.0549999475479126f;
        float _818 = _817 + -0.054999999701976776f;
        _874 = _796;
        _875 = _808;
        _876 = _818;
      }
    } else {
      bool _820 = (_656 == 2);
      if (_820) {
        float _822 = _769 * 0.6274039149284363f;
        float _823 = mad(0.3292830288410187f, _770, _822);
        float _824 = mad(0.04331306740641594f, _771, _823);
        float _825 = _769 * 0.06909728795289993f;
        float _826 = mad(0.9195404052734375f, _770, _825);
        float _827 = mad(0.011362316086888313f, _771, _826);
        float _828 = _769 * 0.016391439363360405f;
        float _829 = mad(0.08801330626010895f, _770, _828);
        float _830 = mad(0.8955952525138855f, _771, _829);
        float _831 = _824 * resolver_output_params.y;
        float _832 = _827 * resolver_output_params.y;
        float _833 = _830 * resolver_output_params.y;
        float _834 = abs(_831);
        float _835 = abs(_832);
        float _836 = abs(_833);
        float _837 = log2(_834);
        float _838 = log2(_835);
        float _839 = log2(_836);
        float _840 = _837 * resolver_output_params.x;
        float _841 = _838 * resolver_output_params.x;
        float _842 = _839 * resolver_output_params.x;
        float _843 = exp2(_840);
        float _844 = exp2(_841);
        float _845 = exp2(_842);
        float _846 = _843 * 18.8515625f;
        float _847 = _846 + 0.8359375f;
        float _848 = _843 * 18.6875f;
        float _849 = _848 + 1.0f;
        float _850 = _847 / _849;
        float _851 = abs(_850);
        float _852 = log2(_851);
        float _853 = _852 * 78.84375f;
        float _854 = exp2(_853);
        float _855 = _844 * 18.8515625f;
        float _856 = _855 + 0.8359375f;
        float _857 = _844 * 18.6875f;
        float _858 = _857 + 1.0f;
        float _859 = _856 / _858;
        float _860 = abs(_859);
        float _861 = log2(_860);
        float _862 = _861 * 78.84375f;
        float _863 = exp2(_862);
        float _864 = _845 * 18.8515625f;
        float _865 = _864 + 0.8359375f;
        float _866 = _845 * 18.6875f;
        float _867 = _866 + 1.0f;
        float _868 = _865 / _867;
        float _869 = abs(_868);
        float _870 = log2(_869);
        float _871 = _870 * 78.84375f;
        float _872 = exp2(_871);
        _874 = _854;
        _875 = _863;
        _876 = _872;
      } else {
        _874 = _769;
        _875 = _770;
        _876 = _771;
      }
    }
    u0_space6[int2(_516, _29)] = float4(_874, _875, _876, 1.0f);
    bool _878 = (_165 == 0);
    if (!_878) {
      [branch]
      if (_657) {
        float _881 = abs(_642.x);
        float _882 = abs(_642.y);
        float _883 = abs(_642.z);
        float _884 = log2(_881);
        float _885 = log2(_882);
        float _886 = log2(_883);
        float _887 = _884 * resolver_output_params.x;
        float _888 = _885 * resolver_output_params.x;
        float _889 = _886 * resolver_output_params.x;
        float _890 = exp2(_887);
        float _891 = exp2(_888);
        float _892 = exp2(_889);
        bool _893 = (_890 < 0.003100000089034438f);
        if (_893) {
          float _895 = _890 * 12.920000076293945f;
          _904 = _895;
        } else {
          float _897 = abs(_890);
          float _898 = log2(_897);
          float _899 = _898 * 0.4166666567325592f;
          float _900 = exp2(_899);
          float _901 = _900 * 1.0549999475479126f;
          float _902 = _901 + -0.054999999701976776f;
          _904 = _902;
        }
        bool _905 = (_891 < 0.003100000089034438f);
        if (_905) {
          float _907 = _891 * 12.920000076293945f;
          _916 = _907;
        } else {
          float _909 = abs(_891);
          float _910 = log2(_909);
          float _911 = _910 * 0.4166666567325592f;
          float _912 = exp2(_911);
          float _913 = _912 * 1.0549999475479126f;
          float _914 = _913 + -0.054999999701976776f;
          _916 = _914;
        }
        bool _917 = (_892 < 0.003100000089034438f);
        if (_917) {
          float _919 = _892 * 12.920000076293945f;
          _982 = _904;
          _983 = _916;
          _984 = _919;
        } else {
          float _921 = abs(_892);
          float _922 = log2(_921);
          float _923 = _922 * 0.4166666567325592f;
          float _924 = exp2(_923);
          float _925 = _924 * 1.0549999475479126f;
          float _926 = _925 + -0.054999999701976776f;
          _982 = _904;
          _983 = _916;
          _984 = _926;
        }
      } else {
        bool _928 = (_656 == 2);
        if (_928) {
          float _930 = _642.x * 0.6274039149284363f;
          float _931 = mad(0.3292830288410187f, _642.y, _930);
          float _932 = mad(0.04331306740641594f, _642.z, _931);
          float _933 = _642.x * 0.06909728795289993f;
          float _934 = mad(0.9195404052734375f, _642.y, _933);
          float _935 = mad(0.011362316086888313f, _642.z, _934);
          float _936 = _642.x * 0.016391439363360405f;
          float _937 = mad(0.08801330626010895f, _642.y, _936);
          float _938 = mad(0.8955952525138855f, _642.z, _937);
          float _939 = _932 * resolver_output_params.y;
          float _940 = _935 * resolver_output_params.y;
          float _941 = _938 * resolver_output_params.y;
          float _942 = abs(_939);
          float _943 = abs(_940);
          float _944 = abs(_941);
          float _945 = log2(_942);
          float _946 = log2(_943);
          float _947 = log2(_944);
          float _948 = _945 * resolver_output_params.x;
          float _949 = _946 * resolver_output_params.x;
          float _950 = _947 * resolver_output_params.x;
          float _951 = exp2(_948);
          float _952 = exp2(_949);
          float _953 = exp2(_950);
          float _954 = _951 * 18.8515625f;
          float _955 = _954 + 0.8359375f;
          float _956 = _951 * 18.6875f;
          float _957 = _956 + 1.0f;
          float _958 = _955 / _957;
          float _959 = abs(_958);
          float _960 = log2(_959);
          float _961 = _960 * 78.84375f;
          float _962 = exp2(_961);
          float _963 = _952 * 18.8515625f;
          float _964 = _963 + 0.8359375f;
          float _965 = _952 * 18.6875f;
          float _966 = _965 + 1.0f;
          float _967 = _964 / _966;
          float _968 = abs(_967);
          float _969 = log2(_968);
          float _970 = _969 * 78.84375f;
          float _971 = exp2(_970);
          float _972 = _953 * 18.8515625f;
          float _973 = _972 + 0.8359375f;
          float _974 = _953 * 18.6875f;
          float _975 = _974 + 1.0f;
          float _976 = _973 / _975;
          float _977 = abs(_976);
          float _978 = log2(_977);
          float _979 = _978 * 78.84375f;
          float _980 = exp2(_979);
          _982 = _962;
          _983 = _971;
          _984 = _980;
        } else {
          _982 = _642.x;
          _983 = _642.y;
          _984 = _642.z;
        }
      }
      u1_space6[int2(_516, _29)] = float4(_982, _983, _984, _642.w);
    }
  } else {
    u0_space6[int2(_516, _29)] = float4(_652, _653, _654, 1.0f);
  }
  int _989 = _29 | 8;
  uint _990 = _989 << 16;
  uint _991 = _990 + -65536u;
  uint _992 = _991 >> 16;
  float4 _994 = t0_space6.Load(int3(_518, _992, 0));
  half _998 = half(_994.x);
  half _999 = half(_994.y);
  half _1000 = half(_994.z);
  uint _1001 = _990 >> 16;
  float4 _1002 = t0_space6.Load(int3(_528, _1001, 0));
  half _1006 = half(_1002.x);
  half _1007 = half(_1002.y);
  half _1008 = half(_1002.z);
  float4 _1009 = t0_space6.Load(int3(_518, _1001, 0));
  half _1013 = half(_1009.x);
  half _1014 = half(_1009.y);
  half _1015 = half(_1009.z);
  float4 _1016 = t0_space6.Load(int3(_544, _1001, 0));
  half _1020 = half(_1016.x);
  half _1021 = half(_1016.y);
  half _1022 = half(_1016.z);
  uint _1023 = _990 + 65536u;
  uint _1024 = _1023 >> 16;
  float4 _1025 = t0_space6.Load(int3(_518, _1024, 0));
  half _1029 = half(_1025.x);
  half _1030 = half(_1025.y);
  half _1031 = half(_1025.z);
  half _1032 = min(_1006, _1020);
  half _1033 = min(_998, _1032);
  half _1034 = min(_1033, _1029);
  half _1035 = min(_1007, _1021);
  half _1036 = min(_999, _1035);
  half _1037 = min(_1036, _1030);
  half _1038 = min(_1008, _1022);
  half _1039 = min(_1000, _1038);
  half _1040 = min(_1039, _1031);
  half _1041 = max(_1006, _1020);
  half _1042 = max(_998, _1041);
  half _1043 = max(_1042, _1029);
  half _1044 = max(_1007, _1021);
  half _1045 = max(_999, _1044);
  half _1046 = max(_1045, _1030);
  half _1047 = max(_1008, _1022);
  half _1048 = max(_1000, _1047);
  half _1049 = max(_1048, _1031);
  half _1050 = 0.25h / _1043;
  half _1051 = 0.25h / _1046;
  half _1052 = 0.25h / _1049;
  half _1053 = 1.0h - _1043;
  half _1054 = _1034 * 4.0h;
  half _1055 = _1054 + -4.0h;
  half _1056 = 1.0h / _1055;
  half _1057 = _1056 * _1053;
  half _1058 = 1.0h - _1046;
  half _1059 = _1037 * 4.0h;
  half _1060 = _1059 + -4.0h;
  half _1061 = 1.0h / _1060;
  half _1062 = _1061 * _1058;
  half _1063 = 1.0h - _1049;
  half _1064 = _1040 * 4.0h;
  half _1065 = _1064 + -4.0h;
  half _1066 = 1.0h / _1065;
  half _1067 = _1066 * _1063;
  half _1068 = _1034 * _1050;
  half _1069 = -0.0h - _1068;
  half _1070 = max(_1069, _1057);
  half _1071 = _1037 * _1051;
  half _1072 = -0.0h - _1071;
  half _1073 = max(_1072, _1062);
  half _1074 = _1040 * _1052;
  half _1075 = -0.0h - _1074;
  half _1076 = max(_1075, _1067);
  half _1077 = max(_1073, _1076);
  half _1078 = max(_1070, _1077);
  half _1079 = min(_1078, 0.0h);
  half _1080 = max(-0.1875h, _1079);
  half _1081 = _130 * _1080;
  half _1082 = _1081 * 4.0h;
  half _1083 = _1082 + 1.0h;
  float _1084 = float(_1083);
  uint _1085 = f32tof16(_1084);
  uint _1086 = 30605u - _1085;
  int _1087 = _1086 & 65535;
  float _1088 = f16tof32(_1087);
  half _1089 = half(_1088);
  half _1090 = _1083 * _1089;
  half _1091 = 2.0h - _1090;
  half _1092 = _1091 * _1089;
  half _1093 = _1006 + _998;
  half _1094 = _1093 + _1020;
  half _1095 = _1094 + _1029;
  half _1096 = _1081 * _1095;
  half _1097 = _1096 + _1013;
  half _1098 = _1092 * _1097;
  half _1099 = _1007 + _999;
  half _1100 = _1099 + _1021;
  half _1101 = _1100 + _1030;
  half _1102 = _1081 * _1101;
  half _1103 = _1102 + _1014;
  half _1104 = _1092 * _1103;
  half _1105 = _1008 + _1000;
  half _1106 = _1105 + _1022;
  half _1107 = _1106 + _1031;
  half _1108 = _1081 * _1107;
  half _1109 = _1108 + _1015;
  half _1110 = _1092 * _1109;
  const float3 resolver_color_2 = SelectResolverSharpening(
      float3(_1098, _1104, _1110), _994.rgb, _1002.rgb, _1009.rgb, _1016.rgb, _1025.rgb,
      resolver_output_params, resolver_normalization_point);
  half _1111 = min(half(resolver_color_2.x), _161);
  half _1112 = min(half(resolver_color_2.y), _161);
  half _1113 = min(half(resolver_color_2.z), _161);
  float4 _1115 = t1_space6.Load(int3(_516, _989, 0));
  float _1120 = max(_1115.y, _1115.z);
  float _1121 = max(_1115.x, _1120);
  float _1122 = _1121 + _1115.w;
  bool _1123 = !(_1122 > 0.0f);
  bool _1124 = _177 || _1123;
  float _1125 = float(_1111);
  float _1126 = float(_1112);
  float _1127 = float(_1113);
  if (!_1124) {
    int _1129 = int(resolver_output_params.w);
    bool _1130 = (_1129 == 1);
    [branch]
    if (_1130) {
      bool _1132 = (_1125 < 0.040449999272823334f);
      if (_1132) {
        float _1134 = _1125 * 0.07739938050508499f;
        _1143 = _1134;
      } else {
        float _1136 = _1125 * 0.9478672742843628f;
        float _1137 = _1136 + 0.05213269963860512f;
        float _1138 = abs(_1137);
        float _1139 = log2(_1138);
        float _1140 = _1139 * 2.4000000953674316f;
        float _1141 = exp2(_1140);
        _1143 = _1141;
      }
      bool _1144 = (_1126 < 0.040449999272823334f);
      if (_1144) {
        float _1146 = _1126 * 0.07739938050508499f;
        _1155 = _1146;
      } else {
        float _1148 = _1126 * 0.9478672742843628f;
        float _1149 = _1148 + 0.05213269963860512f;
        float _1150 = abs(_1149);
        float _1151 = log2(_1150);
        float _1152 = _1151 * 2.4000000953674316f;
        float _1153 = exp2(_1152);
        _1155 = _1153;
      }
      bool _1156 = (_1127 < 0.040449999272823334f);
      if (_1156) {
        float _1158 = _1127 * 0.07739938050508499f;
        _1167 = _1158;
      } else {
        float _1160 = _1127 * 0.9478672742843628f;
        float _1161 = _1160 + 0.05213269963860512f;
        float _1162 = abs(_1161);
        float _1163 = log2(_1162);
        float _1164 = _1163 * 2.4000000953674316f;
        float _1165 = exp2(_1164);
        _1167 = _1165;
      }
      float _1168 = 1.0f / resolver_output_params.x;
      float _1169 = abs(_1143);
      float _1170 = abs(_1155);
      float _1171 = abs(_1167);
      float _1172 = log2(_1169);
      float _1173 = log2(_1170);
      float _1174 = log2(_1171);
      float _1175 = _1172 * _1168;
      float _1176 = _1173 * _1168;
      float _1177 = _1174 * _1168;
      float _1178 = exp2(_1175);
      float _1179 = exp2(_1176);
      float _1180 = exp2(_1177);
      _1235 = _1178;
      _1236 = _1179;
      _1237 = _1180;
    } else {
      bool _1182 = (_1129 == 2);
      if (_1182) {
        float _1184 = abs(_1125);
        float _1185 = abs(_1126);
        float _1186 = abs(_1127);
        float _1187 = log2(_1184);
        float _1188 = log2(_1185);
        float _1189 = log2(_1186);
        float _1190 = _1187 * 0.012683313339948654f;
        float _1191 = _1188 * 0.012683313339948654f;
        float _1192 = _1189 * 0.012683313339948654f;
        float _1193 = exp2(_1190);
        float _1194 = exp2(_1191);
        float _1195 = exp2(_1192);
        float _1196 = _1193 + -0.8359375f;
        float _1197 = _1193 * 18.6875f;
        float _1198 = 18.8515625f - _1197;
        float _1199 = _1196 / _1198;
        float _1200 = _1194 + -0.8359375f;
        float _1201 = _1194 * 18.6875f;
        float _1202 = 18.8515625f - _1201;
        float _1203 = _1200 / _1202;
        float _1204 = _1195 + -0.8359375f;
        float _1205 = _1195 * 18.6875f;
        float _1206 = 18.8515625f - _1205;
        float _1207 = _1204 / _1206;
        float _1208 = 1.0f / resolver_output_params.x;
        float _1209 = abs(_1199);
        float _1210 = abs(_1203);
        float _1211 = abs(_1207);
        float _1212 = log2(_1209);
        float _1213 = log2(_1210);
        float _1214 = log2(_1211);
        float _1215 = _1212 * _1208;
        float _1216 = _1213 * _1208;
        float _1217 = _1214 * _1208;
        float _1218 = exp2(_1215);
        float _1219 = exp2(_1216);
        float _1220 = exp2(_1217);
        float _1221 = 1.0f / resolver_output_params.y;
        float _1222 = _1221 * _1218;
        float _1223 = _1221 * _1219;
        float _1224 = _1221 * _1220;
        float _1225 = _1222 * 1.6604900360107422f;
        float _1226 = mad(-0.5876410007476807f, _1223, _1225);
        float _1227 = mad(-0.07284989953041077f, _1224, _1226);
        float _1228 = _1222 * -0.124549999833107f;
        float _1229 = mad(1.1328999996185303f, _1223, _1228);
        float _1230 = mad(-0.008349419571459293f, _1224, _1229);
        float _1231 = _1222 * -0.018150800839066505f;
        float _1232 = mad(-0.10057900100946426f, _1223, _1231);
        float _1233 = mad(1.1187299489974976f, _1224, _1232);
        _1235 = _1227;
        _1236 = _1230;
        _1237 = _1233;
      } else {
        _1235 = _1125;
        _1236 = _1126;
        _1237 = _1127;
      }
    }
    float _1238 = 1.0f - _1115.w;
    float _1239 = _1235 * _1238;
    float _1240 = _1236 * _1238;
    float _1241 = _1237 * _1238;
    float _1242 = _1239 + _1115.x;
    float _1243 = _1240 + _1115.y;
    float _1244 = _1241 + _1115.z;
    [branch]
    if (_1130) {
      float _1246 = abs(_1242);
      float _1247 = abs(_1243);
      float _1248 = abs(_1244);
      float _1249 = log2(_1246);
      float _1250 = log2(_1247);
      float _1251 = log2(_1248);
      float _1252 = _1249 * resolver_output_params.x;
      float _1253 = _1250 * resolver_output_params.x;
      float _1254 = _1251 * resolver_output_params.x;
      float _1255 = exp2(_1252);
      float _1256 = exp2(_1253);
      float _1257 = exp2(_1254);
      bool _1258 = (_1255 < 0.003100000089034438f);
      if (_1258) {
        float _1260 = _1255 * 12.920000076293945f;
        _1269 = _1260;
      } else {
        float _1262 = abs(_1255);
        float _1263 = log2(_1262);
        float _1264 = _1263 * 0.4166666567325592f;
        float _1265 = exp2(_1264);
        float _1266 = _1265 * 1.0549999475479126f;
        float _1267 = _1266 + -0.054999999701976776f;
        _1269 = _1267;
      }
      bool _1270 = (_1256 < 0.003100000089034438f);
      if (_1270) {
        float _1272 = _1256 * 12.920000076293945f;
        _1281 = _1272;
      } else {
        float _1274 = abs(_1256);
        float _1275 = log2(_1274);
        float _1276 = _1275 * 0.4166666567325592f;
        float _1277 = exp2(_1276);
        float _1278 = _1277 * 1.0549999475479126f;
        float _1279 = _1278 + -0.054999999701976776f;
        _1281 = _1279;
      }
      bool _1282 = (_1257 < 0.003100000089034438f);
      if (_1282) {
        float _1284 = _1257 * 12.920000076293945f;
        _1347 = _1269;
        _1348 = _1281;
        _1349 = _1284;
      } else {
        float _1286 = abs(_1257);
        float _1287 = log2(_1286);
        float _1288 = _1287 * 0.4166666567325592f;
        float _1289 = exp2(_1288);
        float _1290 = _1289 * 1.0549999475479126f;
        float _1291 = _1290 + -0.054999999701976776f;
        _1347 = _1269;
        _1348 = _1281;
        _1349 = _1291;
      }
    } else {
      bool _1293 = (_1129 == 2);
      if (_1293) {
        float _1295 = _1242 * 0.6274039149284363f;
        float _1296 = mad(0.3292830288410187f, _1243, _1295);
        float _1297 = mad(0.04331306740641594f, _1244, _1296);
        float _1298 = _1242 * 0.06909728795289993f;
        float _1299 = mad(0.9195404052734375f, _1243, _1298);
        float _1300 = mad(0.011362316086888313f, _1244, _1299);
        float _1301 = _1242 * 0.016391439363360405f;
        float _1302 = mad(0.08801330626010895f, _1243, _1301);
        float _1303 = mad(0.8955952525138855f, _1244, _1302);
        float _1304 = _1297 * resolver_output_params.y;
        float _1305 = _1300 * resolver_output_params.y;
        float _1306 = _1303 * resolver_output_params.y;
        float _1307 = abs(_1304);
        float _1308 = abs(_1305);
        float _1309 = abs(_1306);
        float _1310 = log2(_1307);
        float _1311 = log2(_1308);
        float _1312 = log2(_1309);
        float _1313 = _1310 * resolver_output_params.x;
        float _1314 = _1311 * resolver_output_params.x;
        float _1315 = _1312 * resolver_output_params.x;
        float _1316 = exp2(_1313);
        float _1317 = exp2(_1314);
        float _1318 = exp2(_1315);
        float _1319 = _1316 * 18.8515625f;
        float _1320 = _1319 + 0.8359375f;
        float _1321 = _1316 * 18.6875f;
        float _1322 = _1321 + 1.0f;
        float _1323 = _1320 / _1322;
        float _1324 = abs(_1323);
        float _1325 = log2(_1324);
        float _1326 = _1325 * 78.84375f;
        float _1327 = exp2(_1326);
        float _1328 = _1317 * 18.8515625f;
        float _1329 = _1328 + 0.8359375f;
        float _1330 = _1317 * 18.6875f;
        float _1331 = _1330 + 1.0f;
        float _1332 = _1329 / _1331;
        float _1333 = abs(_1332);
        float _1334 = log2(_1333);
        float _1335 = _1334 * 78.84375f;
        float _1336 = exp2(_1335);
        float _1337 = _1318 * 18.8515625f;
        float _1338 = _1337 + 0.8359375f;
        float _1339 = _1318 * 18.6875f;
        float _1340 = _1339 + 1.0f;
        float _1341 = _1338 / _1340;
        float _1342 = abs(_1341);
        float _1343 = log2(_1342);
        float _1344 = _1343 * 78.84375f;
        float _1345 = exp2(_1344);
        _1347 = _1327;
        _1348 = _1336;
        _1349 = _1345;
      } else {
        _1347 = _1242;
        _1348 = _1243;
        _1349 = _1244;
      }
    }
    u0_space6[int2(_516, _989)] = float4(_1347, _1348, _1349, 1.0f);
    bool _1351 = (_165 == 0);
    if (!_1351) {
      [branch]
      if (_1130) {
        float _1354 = abs(_1115.x);
        float _1355 = abs(_1115.y);
        float _1356 = abs(_1115.z);
        float _1357 = log2(_1354);
        float _1358 = log2(_1355);
        float _1359 = log2(_1356);
        float _1360 = _1357 * resolver_output_params.x;
        float _1361 = _1358 * resolver_output_params.x;
        float _1362 = _1359 * resolver_output_params.x;
        float _1363 = exp2(_1360);
        float _1364 = exp2(_1361);
        float _1365 = exp2(_1362);
        bool _1366 = (_1363 < 0.003100000089034438f);
        if (_1366) {
          float _1368 = _1363 * 12.920000076293945f;
          _1377 = _1368;
        } else {
          float _1370 = abs(_1363);
          float _1371 = log2(_1370);
          float _1372 = _1371 * 0.4166666567325592f;
          float _1373 = exp2(_1372);
          float _1374 = _1373 * 1.0549999475479126f;
          float _1375 = _1374 + -0.054999999701976776f;
          _1377 = _1375;
        }
        bool _1378 = (_1364 < 0.003100000089034438f);
        if (_1378) {
          float _1380 = _1364 * 12.920000076293945f;
          _1389 = _1380;
        } else {
          float _1382 = abs(_1364);
          float _1383 = log2(_1382);
          float _1384 = _1383 * 0.4166666567325592f;
          float _1385 = exp2(_1384);
          float _1386 = _1385 * 1.0549999475479126f;
          float _1387 = _1386 + -0.054999999701976776f;
          _1389 = _1387;
        }
        bool _1390 = (_1365 < 0.003100000089034438f);
        if (_1390) {
          float _1392 = _1365 * 12.920000076293945f;
          _1455 = _1377;
          _1456 = _1389;
          _1457 = _1392;
        } else {
          float _1394 = abs(_1365);
          float _1395 = log2(_1394);
          float _1396 = _1395 * 0.4166666567325592f;
          float _1397 = exp2(_1396);
          float _1398 = _1397 * 1.0549999475479126f;
          float _1399 = _1398 + -0.054999999701976776f;
          _1455 = _1377;
          _1456 = _1389;
          _1457 = _1399;
        }
      } else {
        bool _1401 = (_1129 == 2);
        if (_1401) {
          float _1403 = _1115.x * 0.6274039149284363f;
          float _1404 = mad(0.3292830288410187f, _1115.y, _1403);
          float _1405 = mad(0.04331306740641594f, _1115.z, _1404);
          float _1406 = _1115.x * 0.06909728795289993f;
          float _1407 = mad(0.9195404052734375f, _1115.y, _1406);
          float _1408 = mad(0.011362316086888313f, _1115.z, _1407);
          float _1409 = _1115.x * 0.016391439363360405f;
          float _1410 = mad(0.08801330626010895f, _1115.y, _1409);
          float _1411 = mad(0.8955952525138855f, _1115.z, _1410);
          float _1412 = _1405 * resolver_output_params.y;
          float _1413 = _1408 * resolver_output_params.y;
          float _1414 = _1411 * resolver_output_params.y;
          float _1415 = abs(_1412);
          float _1416 = abs(_1413);
          float _1417 = abs(_1414);
          float _1418 = log2(_1415);
          float _1419 = log2(_1416);
          float _1420 = log2(_1417);
          float _1421 = _1418 * resolver_output_params.x;
          float _1422 = _1419 * resolver_output_params.x;
          float _1423 = _1420 * resolver_output_params.x;
          float _1424 = exp2(_1421);
          float _1425 = exp2(_1422);
          float _1426 = exp2(_1423);
          float _1427 = _1424 * 18.8515625f;
          float _1428 = _1427 + 0.8359375f;
          float _1429 = _1424 * 18.6875f;
          float _1430 = _1429 + 1.0f;
          float _1431 = _1428 / _1430;
          float _1432 = abs(_1431);
          float _1433 = log2(_1432);
          float _1434 = _1433 * 78.84375f;
          float _1435 = exp2(_1434);
          float _1436 = _1425 * 18.8515625f;
          float _1437 = _1436 + 0.8359375f;
          float _1438 = _1425 * 18.6875f;
          float _1439 = _1438 + 1.0f;
          float _1440 = _1437 / _1439;
          float _1441 = abs(_1440);
          float _1442 = log2(_1441);
          float _1443 = _1442 * 78.84375f;
          float _1444 = exp2(_1443);
          float _1445 = _1426 * 18.8515625f;
          float _1446 = _1445 + 0.8359375f;
          float _1447 = _1426 * 18.6875f;
          float _1448 = _1447 + 1.0f;
          float _1449 = _1446 / _1448;
          float _1450 = abs(_1449);
          float _1451 = log2(_1450);
          float _1452 = _1451 * 78.84375f;
          float _1453 = exp2(_1452);
          _1455 = _1435;
          _1456 = _1444;
          _1457 = _1453;
        } else {
          _1455 = _1115.x;
          _1456 = _1115.y;
          _1457 = _1115.z;
        }
      }
      u1_space6[int2(_516, _989)] = float4(_1455, _1456, _1457, _1115.w);
    }
  } else {
    u0_space6[int2(_516, _989)] = float4(_1125, _1126, _1127, 1.0f);
  }
  float4 _1463 = t0_space6.Load(int3(_32, _992, 0));
  half _1467 = half(_1463.x);
  half _1468 = half(_1463.y);
  half _1469 = half(_1463.z);
  float4 _1470 = t0_space6.Load(int3(_45, _1001, 0));
  half _1474 = half(_1470.x);
  half _1475 = half(_1470.y);
  half _1476 = half(_1470.z);
  float4 _1477 = t0_space6.Load(int3(_32, _1001, 0));
  half _1481 = half(_1477.x);
  half _1482 = half(_1477.y);
  half _1483 = half(_1477.z);
  float4 _1484 = t0_space6.Load(int3(_62, _1001, 0));
  half _1488 = half(_1484.x);
  half _1489 = half(_1484.y);
  half _1490 = half(_1484.z);
  float4 _1491 = t0_space6.Load(int3(_32, _1024, 0));
  half _1495 = half(_1491.x);
  half _1496 = half(_1491.y);
  half _1497 = half(_1491.z);
  half _1498 = min(_1474, _1488);
  half _1499 = min(_1467, _1498);
  half _1500 = min(_1499, _1495);
  half _1501 = min(_1475, _1489);
  half _1502 = min(_1468, _1501);
  half _1503 = min(_1502, _1496);
  half _1504 = min(_1476, _1490);
  half _1505 = min(_1469, _1504);
  half _1506 = min(_1505, _1497);
  half _1507 = max(_1474, _1488);
  half _1508 = max(_1467, _1507);
  half _1509 = max(_1508, _1495);
  half _1510 = max(_1475, _1489);
  half _1511 = max(_1468, _1510);
  half _1512 = max(_1511, _1496);
  half _1513 = max(_1476, _1490);
  half _1514 = max(_1469, _1513);
  half _1515 = max(_1514, _1497);
  half _1516 = 0.25h / _1509;
  half _1517 = 0.25h / _1512;
  half _1518 = 0.25h / _1515;
  half _1519 = 1.0h - _1509;
  half _1520 = _1500 * 4.0h;
  half _1521 = _1520 + -4.0h;
  half _1522 = 1.0h / _1521;
  half _1523 = _1522 * _1519;
  half _1524 = 1.0h - _1512;
  half _1525 = _1503 * 4.0h;
  half _1526 = _1525 + -4.0h;
  half _1527 = 1.0h / _1526;
  half _1528 = _1527 * _1524;
  half _1529 = 1.0h - _1515;
  half _1530 = _1506 * 4.0h;
  half _1531 = _1530 + -4.0h;
  half _1532 = 1.0h / _1531;
  half _1533 = _1532 * _1529;
  half _1534 = _1500 * _1516;
  half _1535 = -0.0h - _1534;
  half _1536 = max(_1535, _1523);
  half _1537 = _1503 * _1517;
  half _1538 = -0.0h - _1537;
  half _1539 = max(_1538, _1528);
  half _1540 = _1506 * _1518;
  half _1541 = -0.0h - _1540;
  half _1542 = max(_1541, _1533);
  half _1543 = max(_1539, _1542);
  half _1544 = max(_1536, _1543);
  half _1545 = min(_1544, 0.0h);
  half _1546 = max(-0.1875h, _1545);
  half _1547 = _130 * _1546;
  half _1548 = _1547 * 4.0h;
  half _1549 = _1548 + 1.0h;
  float _1550 = float(_1549);
  uint _1551 = f32tof16(_1550);
  uint _1552 = 30605u - _1551;
  int _1553 = _1552 & 65535;
  float _1554 = f16tof32(_1553);
  half _1555 = half(_1554);
  half _1556 = _1549 * _1555;
  half _1557 = 2.0h - _1556;
  half _1558 = _1557 * _1555;
  half _1559 = _1474 + _1467;
  half _1560 = _1559 + _1488;
  half _1561 = _1560 + _1495;
  half _1562 = _1547 * _1561;
  half _1563 = _1562 + _1481;
  half _1564 = _1558 * _1563;
  half _1565 = _1475 + _1468;
  half _1566 = _1565 + _1489;
  half _1567 = _1566 + _1496;
  half _1568 = _1547 * _1567;
  half _1569 = _1568 + _1482;
  half _1570 = _1558 * _1569;
  half _1571 = _1476 + _1469;
  half _1572 = _1571 + _1490;
  half _1573 = _1572 + _1497;
  half _1574 = _1547 * _1573;
  half _1575 = _1574 + _1483;
  half _1576 = _1558 * _1575;
  const float3 resolver_color_3 = SelectResolverSharpening(
      float3(_1564, _1570, _1576), _1463.rgb, _1470.rgb, _1477.rgb, _1484.rgb, _1491.rgb,
      resolver_output_params, resolver_normalization_point);
  half _1577 = min(half(resolver_color_3.x), _161);
  half _1578 = min(half(resolver_color_3.y), _161);
  half _1579 = min(half(resolver_color_3.z), _161);
  float4 _1581 = t1_space6.Load(int3(_28, _989, 0));
  float _1586 = max(_1581.y, _1581.z);
  float _1587 = max(_1581.x, _1586);
  float _1588 = _1587 + _1581.w;
  bool _1589 = !(_1588 > 0.0f);
  bool _1590 = _177 || _1589;
  float _1591 = float(_1577);
  float _1592 = float(_1578);
  float _1593 = float(_1579);
  if (!_1590) {
    int _1595 = int(resolver_output_params.w);
    bool _1596 = (_1595 == 1);
    [branch]
    if (_1596) {
      bool _1598 = (_1591 < 0.040449999272823334f);
      if (_1598) {
        float _1600 = _1591 * 0.07739938050508499f;
        _1609 = _1600;
      } else {
        float _1602 = _1591 * 0.9478672742843628f;
        float _1603 = _1602 + 0.05213269963860512f;
        float _1604 = abs(_1603);
        float _1605 = log2(_1604);
        float _1606 = _1605 * 2.4000000953674316f;
        float _1607 = exp2(_1606);
        _1609 = _1607;
      }
      bool _1610 = (_1592 < 0.040449999272823334f);
      if (_1610) {
        float _1612 = _1592 * 0.07739938050508499f;
        _1621 = _1612;
      } else {
        float _1614 = _1592 * 0.9478672742843628f;
        float _1615 = _1614 + 0.05213269963860512f;
        float _1616 = abs(_1615);
        float _1617 = log2(_1616);
        float _1618 = _1617 * 2.4000000953674316f;
        float _1619 = exp2(_1618);
        _1621 = _1619;
      }
      bool _1622 = (_1593 < 0.040449999272823334f);
      if (_1622) {
        float _1624 = _1593 * 0.07739938050508499f;
        _1633 = _1624;
      } else {
        float _1626 = _1593 * 0.9478672742843628f;
        float _1627 = _1626 + 0.05213269963860512f;
        float _1628 = abs(_1627);
        float _1629 = log2(_1628);
        float _1630 = _1629 * 2.4000000953674316f;
        float _1631 = exp2(_1630);
        _1633 = _1631;
      }
      float _1634 = 1.0f / resolver_output_params.x;
      float _1635 = abs(_1609);
      float _1636 = abs(_1621);
      float _1637 = abs(_1633);
      float _1638 = log2(_1635);
      float _1639 = log2(_1636);
      float _1640 = log2(_1637);
      float _1641 = _1638 * _1634;
      float _1642 = _1639 * _1634;
      float _1643 = _1640 * _1634;
      float _1644 = exp2(_1641);
      float _1645 = exp2(_1642);
      float _1646 = exp2(_1643);
      _1701 = _1644;
      _1702 = _1645;
      _1703 = _1646;
    } else {
      bool _1648 = (_1595 == 2);
      if (_1648) {
        float _1650 = abs(_1591);
        float _1651 = abs(_1592);
        float _1652 = abs(_1593);
        float _1653 = log2(_1650);
        float _1654 = log2(_1651);
        float _1655 = log2(_1652);
        float _1656 = _1653 * 0.012683313339948654f;
        float _1657 = _1654 * 0.012683313339948654f;
        float _1658 = _1655 * 0.012683313339948654f;
        float _1659 = exp2(_1656);
        float _1660 = exp2(_1657);
        float _1661 = exp2(_1658);
        float _1662 = _1659 + -0.8359375f;
        float _1663 = _1659 * 18.6875f;
        float _1664 = 18.8515625f - _1663;
        float _1665 = _1662 / _1664;
        float _1666 = _1660 + -0.8359375f;
        float _1667 = _1660 * 18.6875f;
        float _1668 = 18.8515625f - _1667;
        float _1669 = _1666 / _1668;
        float _1670 = _1661 + -0.8359375f;
        float _1671 = _1661 * 18.6875f;
        float _1672 = 18.8515625f - _1671;
        float _1673 = _1670 / _1672;
        float _1674 = 1.0f / resolver_output_params.x;
        float _1675 = abs(_1665);
        float _1676 = abs(_1669);
        float _1677 = abs(_1673);
        float _1678 = log2(_1675);
        float _1679 = log2(_1676);
        float _1680 = log2(_1677);
        float _1681 = _1678 * _1674;
        float _1682 = _1679 * _1674;
        float _1683 = _1680 * _1674;
        float _1684 = exp2(_1681);
        float _1685 = exp2(_1682);
        float _1686 = exp2(_1683);
        float _1687 = 1.0f / resolver_output_params.y;
        float _1688 = _1687 * _1684;
        float _1689 = _1687 * _1685;
        float _1690 = _1687 * _1686;
        float _1691 = _1688 * 1.6604900360107422f;
        float _1692 = mad(-0.5876410007476807f, _1689, _1691);
        float _1693 = mad(-0.07284989953041077f, _1690, _1692);
        float _1694 = _1688 * -0.124549999833107f;
        float _1695 = mad(1.1328999996185303f, _1689, _1694);
        float _1696 = mad(-0.008349419571459293f, _1690, _1695);
        float _1697 = _1688 * -0.018150800839066505f;
        float _1698 = mad(-0.10057900100946426f, _1689, _1697);
        float _1699 = mad(1.1187299489974976f, _1690, _1698);
        _1701 = _1693;
        _1702 = _1696;
        _1703 = _1699;
      } else {
        _1701 = _1591;
        _1702 = _1592;
        _1703 = _1593;
      }
    }
    float _1704 = 1.0f - _1581.w;
    float _1705 = _1701 * _1704;
    float _1706 = _1702 * _1704;
    float _1707 = _1703 * _1704;
    float _1708 = _1705 + _1581.x;
    float _1709 = _1706 + _1581.y;
    float _1710 = _1707 + _1581.z;
    [branch]
    if (_1596) {
      float _1712 = abs(_1708);
      float _1713 = abs(_1709);
      float _1714 = abs(_1710);
      float _1715 = log2(_1712);
      float _1716 = log2(_1713);
      float _1717 = log2(_1714);
      float _1718 = _1715 * resolver_output_params.x;
      float _1719 = _1716 * resolver_output_params.x;
      float _1720 = _1717 * resolver_output_params.x;
      float _1721 = exp2(_1718);
      float _1722 = exp2(_1719);
      float _1723 = exp2(_1720);
      bool _1724 = (_1721 < 0.003100000089034438f);
      if (_1724) {
        float _1726 = _1721 * 12.920000076293945f;
        _1735 = _1726;
      } else {
        float _1728 = abs(_1721);
        float _1729 = log2(_1728);
        float _1730 = _1729 * 0.4166666567325592f;
        float _1731 = exp2(_1730);
        float _1732 = _1731 * 1.0549999475479126f;
        float _1733 = _1732 + -0.054999999701976776f;
        _1735 = _1733;
      }
      bool _1736 = (_1722 < 0.003100000089034438f);
      if (_1736) {
        float _1738 = _1722 * 12.920000076293945f;
        _1747 = _1738;
      } else {
        float _1740 = abs(_1722);
        float _1741 = log2(_1740);
        float _1742 = _1741 * 0.4166666567325592f;
        float _1743 = exp2(_1742);
        float _1744 = _1743 * 1.0549999475479126f;
        float _1745 = _1744 + -0.054999999701976776f;
        _1747 = _1745;
      }
      bool _1748 = (_1723 < 0.003100000089034438f);
      if (_1748) {
        float _1750 = _1723 * 12.920000076293945f;
        _1813 = _1735;
        _1814 = _1747;
        _1815 = _1750;
      } else {
        float _1752 = abs(_1723);
        float _1753 = log2(_1752);
        float _1754 = _1753 * 0.4166666567325592f;
        float _1755 = exp2(_1754);
        float _1756 = _1755 * 1.0549999475479126f;
        float _1757 = _1756 + -0.054999999701976776f;
        _1813 = _1735;
        _1814 = _1747;
        _1815 = _1757;
      }
    } else {
      bool _1759 = (_1595 == 2);
      if (_1759) {
        float _1761 = _1708 * 0.6274039149284363f;
        float _1762 = mad(0.3292830288410187f, _1709, _1761);
        float _1763 = mad(0.04331306740641594f, _1710, _1762);
        float _1764 = _1708 * 0.06909728795289993f;
        float _1765 = mad(0.9195404052734375f, _1709, _1764);
        float _1766 = mad(0.011362316086888313f, _1710, _1765);
        float _1767 = _1708 * 0.016391439363360405f;
        float _1768 = mad(0.08801330626010895f, _1709, _1767);
        float _1769 = mad(0.8955952525138855f, _1710, _1768);
        float _1770 = _1763 * resolver_output_params.y;
        float _1771 = _1766 * resolver_output_params.y;
        float _1772 = _1769 * resolver_output_params.y;
        float _1773 = abs(_1770);
        float _1774 = abs(_1771);
        float _1775 = abs(_1772);
        float _1776 = log2(_1773);
        float _1777 = log2(_1774);
        float _1778 = log2(_1775);
        float _1779 = _1776 * resolver_output_params.x;
        float _1780 = _1777 * resolver_output_params.x;
        float _1781 = _1778 * resolver_output_params.x;
        float _1782 = exp2(_1779);
        float _1783 = exp2(_1780);
        float _1784 = exp2(_1781);
        float _1785 = _1782 * 18.8515625f;
        float _1786 = _1785 + 0.8359375f;
        float _1787 = _1782 * 18.6875f;
        float _1788 = _1787 + 1.0f;
        float _1789 = _1786 / _1788;
        float _1790 = abs(_1789);
        float _1791 = log2(_1790);
        float _1792 = _1791 * 78.84375f;
        float _1793 = exp2(_1792);
        float _1794 = _1783 * 18.8515625f;
        float _1795 = _1794 + 0.8359375f;
        float _1796 = _1783 * 18.6875f;
        float _1797 = _1796 + 1.0f;
        float _1798 = _1795 / _1797;
        float _1799 = abs(_1798);
        float _1800 = log2(_1799);
        float _1801 = _1800 * 78.84375f;
        float _1802 = exp2(_1801);
        float _1803 = _1784 * 18.8515625f;
        float _1804 = _1803 + 0.8359375f;
        float _1805 = _1784 * 18.6875f;
        float _1806 = _1805 + 1.0f;
        float _1807 = _1804 / _1806;
        float _1808 = abs(_1807);
        float _1809 = log2(_1808);
        float _1810 = _1809 * 78.84375f;
        float _1811 = exp2(_1810);
        _1813 = _1793;
        _1814 = _1802;
        _1815 = _1811;
      } else {
        _1813 = _1708;
        _1814 = _1709;
        _1815 = _1710;
      }
    }
    u0_space6[int2(_28, _989)] = float4(_1813, _1814, _1815, 1.0f);
    bool _1817 = (_165 == 0);
    if (!_1817) {
      [branch]
      if (_1596) {
        float _1820 = abs(_1581.x);
        float _1821 = abs(_1581.y);
        float _1822 = abs(_1581.z);
        float _1823 = log2(_1820);
        float _1824 = log2(_1821);
        float _1825 = log2(_1822);
        float _1826 = _1823 * resolver_output_params.x;
        float _1827 = _1824 * resolver_output_params.x;
        float _1828 = _1825 * resolver_output_params.x;
        float _1829 = exp2(_1826);
        float _1830 = exp2(_1827);
        float _1831 = exp2(_1828);
        bool _1832 = (_1829 < 0.003100000089034438f);
        if (_1832) {
          float _1834 = _1829 * 12.920000076293945f;
          _1843 = _1834;
        } else {
          float _1836 = abs(_1829);
          float _1837 = log2(_1836);
          float _1838 = _1837 * 0.4166666567325592f;
          float _1839 = exp2(_1838);
          float _1840 = _1839 * 1.0549999475479126f;
          float _1841 = _1840 + -0.054999999701976776f;
          _1843 = _1841;
        }
        bool _1844 = (_1830 < 0.003100000089034438f);
        if (_1844) {
          float _1846 = _1830 * 12.920000076293945f;
          _1855 = _1846;
        } else {
          float _1848 = abs(_1830);
          float _1849 = log2(_1848);
          float _1850 = _1849 * 0.4166666567325592f;
          float _1851 = exp2(_1850);
          float _1852 = _1851 * 1.0549999475479126f;
          float _1853 = _1852 + -0.054999999701976776f;
          _1855 = _1853;
        }
        bool _1856 = (_1831 < 0.003100000089034438f);
        if (_1856) {
          float _1858 = _1831 * 12.920000076293945f;
          _1921 = _1843;
          _1922 = _1855;
          _1923 = _1858;
        } else {
          float _1860 = abs(_1831);
          float _1861 = log2(_1860);
          float _1862 = _1861 * 0.4166666567325592f;
          float _1863 = exp2(_1862);
          float _1864 = _1863 * 1.0549999475479126f;
          float _1865 = _1864 + -0.054999999701976776f;
          _1921 = _1843;
          _1922 = _1855;
          _1923 = _1865;
        }
      } else {
        bool _1867 = (_1595 == 2);
        if (_1867) {
          float _1869 = _1581.x * 0.6274039149284363f;
          float _1870 = mad(0.3292830288410187f, _1581.y, _1869);
          float _1871 = mad(0.04331306740641594f, _1581.z, _1870);
          float _1872 = _1581.x * 0.06909728795289993f;
          float _1873 = mad(0.9195404052734375f, _1581.y, _1872);
          float _1874 = mad(0.011362316086888313f, _1581.z, _1873);
          float _1875 = _1581.x * 0.016391439363360405f;
          float _1876 = mad(0.08801330626010895f, _1581.y, _1875);
          float _1877 = mad(0.8955952525138855f, _1581.z, _1876);
          float _1878 = _1871 * resolver_output_params.y;
          float _1879 = _1874 * resolver_output_params.y;
          float _1880 = _1877 * resolver_output_params.y;
          float _1881 = abs(_1878);
          float _1882 = abs(_1879);
          float _1883 = abs(_1880);
          float _1884 = log2(_1881);
          float _1885 = log2(_1882);
          float _1886 = log2(_1883);
          float _1887 = _1884 * resolver_output_params.x;
          float _1888 = _1885 * resolver_output_params.x;
          float _1889 = _1886 * resolver_output_params.x;
          float _1890 = exp2(_1887);
          float _1891 = exp2(_1888);
          float _1892 = exp2(_1889);
          float _1893 = _1890 * 18.8515625f;
          float _1894 = _1893 + 0.8359375f;
          float _1895 = _1890 * 18.6875f;
          float _1896 = _1895 + 1.0f;
          float _1897 = _1894 / _1896;
          float _1898 = abs(_1897);
          float _1899 = log2(_1898);
          float _1900 = _1899 * 78.84375f;
          float _1901 = exp2(_1900);
          float _1902 = _1891 * 18.8515625f;
          float _1903 = _1902 + 0.8359375f;
          float _1904 = _1891 * 18.6875f;
          float _1905 = _1904 + 1.0f;
          float _1906 = _1903 / _1905;
          float _1907 = abs(_1906);
          float _1908 = log2(_1907);
          float _1909 = _1908 * 78.84375f;
          float _1910 = exp2(_1909);
          float _1911 = _1892 * 18.8515625f;
          float _1912 = _1911 + 0.8359375f;
          float _1913 = _1892 * 18.6875f;
          float _1914 = _1913 + 1.0f;
          float _1915 = _1912 / _1914;
          float _1916 = abs(_1915);
          float _1917 = log2(_1916);
          float _1918 = _1917 * 78.84375f;
          float _1919 = exp2(_1918);
          _1921 = _1901;
          _1922 = _1910;
          _1923 = _1919;
        } else {
          _1921 = _1581.x;
          _1922 = _1581.y;
          _1923 = _1581.z;
        }
      }
      u1_space6[int2(_28, _989)] = float4(_1921, _1922, _1923, _1581.w);
    }
  } else {
    u0_space6[int2(_28, _989)] = float4(_1591, _1592, _1593, 1.0f);
  }
}

#endif  // SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0X6089C217_HLSLI_
