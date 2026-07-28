#ifndef SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0XDA5784EF_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0XDA5784EF_HLSLI_

// AA/upscale resolver over the encoded frame: decode -> temporal resolve -> encode.
// Decompiled from the game's DXIL. Vanilla+ replaces the game's output-space HDR cap
// with the RenoDX PQ cap in GetResolverOutputParams and can replace resolver CAS with
// Lilium RCAS using the same taps. The RenoDX cap follows Peak Brightness while
// bounding sharpening overshoot.
//
// Shared by HZDR 0xDA5784EF and HFW 0x170D0D0F: both games ship this program with the same
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
  // Dispatch-uniform output cap, hoisted once for the four resolver branches below.
  const float scene_cap = resolver_output_params.z;
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
  uint _30 = _29 + -1u;
  float4 _32 = t0_space6.Load(int3(_28, _30, 0));
  uint _36 = _28 + -1u;
  float4 _37 = t0_space6.Load(int3(_36, _29, 0));
  float4 _41 = t0_space6.Load(int3(_28, _29, 0));
  int _45 = _28 + 1;
  float4 _46 = t0_space6.Load(int3(_45, _29, 0));
  int _50 = _29 + 1;
  float4 _51 = t0_space6.Load(int3(_28, _50, 0));
  float _55 = min(_37.x, _46.x);
  float _56 = min(_32.x, _55);
  float _57 = min(_56, _51.x);
  float _58 = min(_37.y, _46.y);
  float _59 = min(_32.y, _58);
  float _60 = min(_59, _51.y);
  float _61 = min(_37.z, _46.z);
  float _62 = min(_32.z, _61);
  float _63 = min(_62, _51.z);
  float _64 = max(_37.x, _46.x);
  float _65 = max(_32.x, _64);
  float _66 = max(_65, _51.x);
  float _67 = max(_37.y, _46.y);
  float _68 = max(_32.y, _67);
  float _69 = max(_68, _51.y);
  float _70 = max(_37.z, _46.z);
  float _71 = max(_32.z, _70);
  float _72 = max(_71, _51.z);
  float _73 = 0.25f / _66;
  float _74 = 0.25f / _69;
  float _75 = 0.25f / _72;
  float _76 = 1.0f - _66;
  float _77 = _57 * 4.0f;
  float _78 = _77 + -4.0f;
  float _79 = 1.0f / _78;
  float _80 = _79 * _76;
  float _81 = 1.0f - _69;
  float _82 = _60 * 4.0f;
  float _83 = _82 + -4.0f;
  float _84 = 1.0f / _83;
  float _85 = _84 * _81;
  float _86 = 1.0f - _72;
  float _87 = _63 * 4.0f;
  float _88 = _87 + -4.0f;
  float _89 = 1.0f / _88;
  float _90 = _89 * _86;
  float _91 = _57 * _73;
  float _92 = -0.0f - _91;
  float _93 = max(_92, _80);
  float _94 = _60 * _74;
  float _95 = -0.0f - _94;
  float _96 = max(_95, _85);
  float _97 = _63 * _75;
  float _98 = -0.0f - _97;
  float _99 = max(_98, _90);
  float _100 = max(_96, _99);
  float _101 = max(_93, _100);
  float _102 = min(_101, 0.0f);
  float _103 = max(-0.1875f, _102);
  float _104 = _103 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _105 = _104 * 4.0f;
  float _106 = _105 + 1.0f;
  int _107 = asint(_106);
  uint _108 = 2129764351u - _107;
  float _109 = asfloat(_108);
  float _110 = _109 * _106;
  float _111 = 2.0f - _110;
  float _112 = _111 * _109;
  float _113 = _37.x + _32.x;
  float _114 = _113 + _46.x;
  float _115 = _114 + _51.x;
  float _116 = _104 * _115;
  float _117 = _116 + _41.x;
  float _118 = _112 * _117;
  float _119 = _37.y + _32.y;
  float _120 = _119 + _46.y;
  float _121 = _120 + _51.y;
  float _122 = _104 * _121;
  float _123 = _122 + _41.y;
  float _124 = _112 * _123;
  float _125 = _37.z + _32.z;
  float _126 = _125 + _46.z;
  float _127 = _126 + _51.z;
  float _128 = _104 * _127;
  float _129 = _128 + _41.z;
  float _130 = _112 * _129;
  const float3 resolver_color_0 = SelectResolverSharpening(
      float3(_118, _124, _130), _32.rgb, _37.rgb, _41.rgb, _46.rgb, _51.rgb,
      resolver_output_params);
  float _131 = min(resolver_color_0.x, scene_cap);
  float _132 = min(resolver_color_0.y, scene_cap);
  float _133 = min(resolver_color_0.z, scene_cap);
  int _134 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.x);
  int _135 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.y);
  float4 _137 = t1_space6.Load(int3(_28, _29, 0));
  float _142 = max(_137.y, _137.z);
  float _143 = max(_137.x, _142);
  float _144 = _143 + _137.w;
  bool _145 = !(_144 > 0.0f);
  bool _146 = (_135 != 0);
  bool _147 = _146 || _145;
  float _163;
  float _175;
  float _187;
  float _255;
  float _256;
  float _257;
  float _289;
  float _301;
  float _367;
  float _368;
  float _369;
  float _397;
  float _409;
  float _475;
  float _476;
  float _477;
  float _611;
  float _623;
  float _635;
  float _703;
  float _704;
  float _705;
  float _737;
  float _749;
  float _815;
  float _816;
  float _817;
  float _845;
  float _857;
  float _923;
  float _924;
  float _925;
  float _1059;
  float _1071;
  float _1083;
  float _1151;
  float _1152;
  float _1153;
  float _1185;
  float _1197;
  float _1263;
  float _1264;
  float _1265;
  float _1293;
  float _1305;
  float _1371;
  float _1372;
  float _1373;
  float _1504;
  float _1516;
  float _1528;
  float _1596;
  float _1597;
  float _1598;
  float _1630;
  float _1642;
  float _1708;
  float _1709;
  float _1710;
  float _1738;
  float _1750;
  float _1816;
  float _1817;
  float _1818;
  if (!_147) {
    int _149 = int(resolver_output_params.w);
    bool _150 = (_149 == 1);
    [branch]
    if (_150) {
      bool _152 = (_131 < 0.040449999272823334f);
      if (_152) {
        float _154 = _131 * 0.07739938050508499f;
        _163 = _154;
      } else {
        float _156 = _131 * 0.9478672742843628f;
        float _157 = _156 + 0.05213269963860512f;
        float _158 = abs(_157);
        float _159 = log2(_158);
        float _160 = _159 * 2.4000000953674316f;
        float _161 = exp2(_160);
        _163 = _161;
      }
      bool _164 = (_132 < 0.040449999272823334f);
      if (_164) {
        float _166 = _132 * 0.07739938050508499f;
        _175 = _166;
      } else {
        float _168 = _132 * 0.9478672742843628f;
        float _169 = _168 + 0.05213269963860512f;
        float _170 = abs(_169);
        float _171 = log2(_170);
        float _172 = _171 * 2.4000000953674316f;
        float _173 = exp2(_172);
        _175 = _173;
      }
      bool _176 = (_133 < 0.040449999272823334f);
      if (_176) {
        float _178 = _133 * 0.07739938050508499f;
        _187 = _178;
      } else {
        float _180 = _133 * 0.9478672742843628f;
        float _181 = _180 + 0.05213269963860512f;
        float _182 = abs(_181);
        float _183 = log2(_182);
        float _184 = _183 * 2.4000000953674316f;
        float _185 = exp2(_184);
        _187 = _185;
      }
      float _188 = 1.0f / resolver_output_params.x;
      float _189 = abs(_163);
      float _190 = abs(_175);
      float _191 = abs(_187);
      float _192 = log2(_189);
      float _193 = log2(_190);
      float _194 = log2(_191);
      float _195 = _192 * _188;
      float _196 = _193 * _188;
      float _197 = _194 * _188;
      float _198 = exp2(_195);
      float _199 = exp2(_196);
      float _200 = exp2(_197);
      _255 = _198;
      _256 = _199;
      _257 = _200;
    } else {
      bool _202 = (_149 == 2);
      if (_202) {
        float _204 = abs(_131);
        float _205 = abs(_132);
        float _206 = abs(_133);
        float _207 = log2(_204);
        float _208 = log2(_205);
        float _209 = log2(_206);
        float _210 = _207 * 0.012683313339948654f;
        float _211 = _208 * 0.012683313339948654f;
        float _212 = _209 * 0.012683313339948654f;
        float _213 = exp2(_210);
        float _214 = exp2(_211);
        float _215 = exp2(_212);
        float _216 = _213 + -0.8359375f;
        float _217 = _213 * 18.6875f;
        float _218 = 18.8515625f - _217;
        float _219 = _216 / _218;
        float _220 = _214 + -0.8359375f;
        float _221 = _214 * 18.6875f;
        float _222 = 18.8515625f - _221;
        float _223 = _220 / _222;
        float _224 = _215 + -0.8359375f;
        float _225 = _215 * 18.6875f;
        float _226 = 18.8515625f - _225;
        float _227 = _224 / _226;
        float _228 = 1.0f / resolver_output_params.x;
        float _229 = abs(_219);
        float _230 = abs(_223);
        float _231 = abs(_227);
        float _232 = log2(_229);
        float _233 = log2(_230);
        float _234 = log2(_231);
        float _235 = _232 * _228;
        float _236 = _233 * _228;
        float _237 = _234 * _228;
        float _238 = exp2(_235);
        float _239 = exp2(_236);
        float _240 = exp2(_237);
        float _241 = 1.0f / resolver_output_params.y;
        float _242 = _241 * _238;
        float _243 = _241 * _239;
        float _244 = _241 * _240;
        float _245 = _242 * 1.6604900360107422f;
        float _246 = mad(-0.5876410007476807f, _243, _245);
        float _247 = mad(-0.07284989953041077f, _244, _246);
        float _248 = _242 * -0.124549999833107f;
        float _249 = mad(1.1328999996185303f, _243, _248);
        float _250 = mad(-0.008349419571459293f, _244, _249);
        float _251 = _242 * -0.018150800839066505f;
        float _252 = mad(-0.10057900100946426f, _243, _251);
        float _253 = mad(1.1187299489974976f, _244, _252);
        _255 = _247;
        _256 = _250;
        _257 = _253;
      } else {
        _255 = _131;
        _256 = _132;
        _257 = _133;
      }
    }
    float _258 = 1.0f - _137.w;
    float _259 = _255 * _258;
    float _260 = _256 * _258;
    float _261 = _257 * _258;
    float _262 = _259 + _137.x;
    float _263 = _260 + _137.y;
    float _264 = _261 + _137.z;
    [branch]
    if (_150) {
      float _266 = abs(_262);
      float _267 = abs(_263);
      float _268 = abs(_264);
      float _269 = log2(_266);
      float _270 = log2(_267);
      float _271 = log2(_268);
      float _272 = _269 * resolver_output_params.x;
      float _273 = _270 * resolver_output_params.x;
      float _274 = _271 * resolver_output_params.x;
      float _275 = exp2(_272);
      float _276 = exp2(_273);
      float _277 = exp2(_274);
      bool _278 = (_275 < 0.003100000089034438f);
      if (_278) {
        float _280 = _275 * 12.920000076293945f;
        _289 = _280;
      } else {
        float _282 = abs(_275);
        float _283 = log2(_282);
        float _284 = _283 * 0.4166666567325592f;
        float _285 = exp2(_284);
        float _286 = _285 * 1.0549999475479126f;
        float _287 = _286 + -0.054999999701976776f;
        _289 = _287;
      }
      bool _290 = (_276 < 0.003100000089034438f);
      if (_290) {
        float _292 = _276 * 12.920000076293945f;
        _301 = _292;
      } else {
        float _294 = abs(_276);
        float _295 = log2(_294);
        float _296 = _295 * 0.4166666567325592f;
        float _297 = exp2(_296);
        float _298 = _297 * 1.0549999475479126f;
        float _299 = _298 + -0.054999999701976776f;
        _301 = _299;
      }
      bool _302 = (_277 < 0.003100000089034438f);
      if (_302) {
        float _304 = _277 * 12.920000076293945f;
        _367 = _289;
        _368 = _301;
        _369 = _304;
      } else {
        float _306 = abs(_277);
        float _307 = log2(_306);
        float _308 = _307 * 0.4166666567325592f;
        float _309 = exp2(_308);
        float _310 = _309 * 1.0549999475479126f;
        float _311 = _310 + -0.054999999701976776f;
        _367 = _289;
        _368 = _301;
        _369 = _311;
      }
    } else {
      bool _313 = (_149 == 2);
      if (_313) {
        float _315 = _262 * 0.6274039149284363f;
        float _316 = mad(0.3292830288410187f, _263, _315);
        float _317 = mad(0.04331306740641594f, _264, _316);
        float _318 = _262 * 0.06909728795289993f;
        float _319 = mad(0.9195404052734375f, _263, _318);
        float _320 = mad(0.011362316086888313f, _264, _319);
        float _321 = _262 * 0.016391439363360405f;
        float _322 = mad(0.08801330626010895f, _263, _321);
        float _323 = mad(0.8955952525138855f, _264, _322);
        float _324 = _317 * resolver_output_params.y;
        float _325 = _320 * resolver_output_params.y;
        float _326 = _323 * resolver_output_params.y;
        float _327 = abs(_324);
        float _328 = abs(_325);
        float _329 = abs(_326);
        float _330 = log2(_327);
        float _331 = log2(_328);
        float _332 = log2(_329);
        float _333 = _330 * resolver_output_params.x;
        float _334 = _331 * resolver_output_params.x;
        float _335 = _332 * resolver_output_params.x;
        float _336 = exp2(_333);
        float _337 = exp2(_334);
        float _338 = exp2(_335);
        float _339 = _336 * 18.8515625f;
        float _340 = _339 + 0.8359375f;
        float _341 = _336 * 18.6875f;
        float _342 = _341 + 1.0f;
        float _343 = _340 / _342;
        float _344 = abs(_343);
        float _345 = log2(_344);
        float _346 = _345 * 78.84375f;
        float _347 = exp2(_346);
        float _348 = _337 * 18.8515625f;
        float _349 = _348 + 0.8359375f;
        float _350 = _337 * 18.6875f;
        float _351 = _350 + 1.0f;
        float _352 = _349 / _351;
        float _353 = abs(_352);
        float _354 = log2(_353);
        float _355 = _354 * 78.84375f;
        float _356 = exp2(_355);
        float _357 = _338 * 18.8515625f;
        float _358 = _357 + 0.8359375f;
        float _359 = _338 * 18.6875f;
        float _360 = _359 + 1.0f;
        float _361 = _358 / _360;
        float _362 = abs(_361);
        float _363 = log2(_362);
        float _364 = _363 * 78.84375f;
        float _365 = exp2(_364);
        _367 = _347;
        _368 = _356;
        _369 = _365;
      } else {
        _367 = _262;
        _368 = _263;
        _369 = _264;
      }
    }
    u0_space6[int2(_28, _29)] = float4(_367, _368, _369, 1.0f);
    bool _371 = (_134 == 0);
    if (!_371) {
      [branch]
      if (_150) {
        float _374 = abs(_137.x);
        float _375 = abs(_137.y);
        float _376 = abs(_137.z);
        float _377 = log2(_374);
        float _378 = log2(_375);
        float _379 = log2(_376);
        float _380 = _377 * resolver_output_params.x;
        float _381 = _378 * resolver_output_params.x;
        float _382 = _379 * resolver_output_params.x;
        float _383 = exp2(_380);
        float _384 = exp2(_381);
        float _385 = exp2(_382);
        bool _386 = (_383 < 0.003100000089034438f);
        if (_386) {
          float _388 = _383 * 12.920000076293945f;
          _397 = _388;
        } else {
          float _390 = abs(_383);
          float _391 = log2(_390);
          float _392 = _391 * 0.4166666567325592f;
          float _393 = exp2(_392);
          float _394 = _393 * 1.0549999475479126f;
          float _395 = _394 + -0.054999999701976776f;
          _397 = _395;
        }
        bool _398 = (_384 < 0.003100000089034438f);
        if (_398) {
          float _400 = _384 * 12.920000076293945f;
          _409 = _400;
        } else {
          float _402 = abs(_384);
          float _403 = log2(_402);
          float _404 = _403 * 0.4166666567325592f;
          float _405 = exp2(_404);
          float _406 = _405 * 1.0549999475479126f;
          float _407 = _406 + -0.054999999701976776f;
          _409 = _407;
        }
        bool _410 = (_385 < 0.003100000089034438f);
        if (_410) {
          float _412 = _385 * 12.920000076293945f;
          _475 = _397;
          _476 = _409;
          _477 = _412;
        } else {
          float _414 = abs(_385);
          float _415 = log2(_414);
          float _416 = _415 * 0.4166666567325592f;
          float _417 = exp2(_416);
          float _418 = _417 * 1.0549999475479126f;
          float _419 = _418 + -0.054999999701976776f;
          _475 = _397;
          _476 = _409;
          _477 = _419;
        }
      } else {
        bool _421 = (_149 == 2);
        if (_421) {
          float _423 = _137.x * 0.6274039149284363f;
          float _424 = mad(0.3292830288410187f, _137.y, _423);
          float _425 = mad(0.04331306740641594f, _137.z, _424);
          float _426 = _137.x * 0.06909728795289993f;
          float _427 = mad(0.9195404052734375f, _137.y, _426);
          float _428 = mad(0.011362316086888313f, _137.z, _427);
          float _429 = _137.x * 0.016391439363360405f;
          float _430 = mad(0.08801330626010895f, _137.y, _429);
          float _431 = mad(0.8955952525138855f, _137.z, _430);
          float _432 = _425 * resolver_output_params.y;
          float _433 = _428 * resolver_output_params.y;
          float _434 = _431 * resolver_output_params.y;
          float _435 = abs(_432);
          float _436 = abs(_433);
          float _437 = abs(_434);
          float _438 = log2(_435);
          float _439 = log2(_436);
          float _440 = log2(_437);
          float _441 = _438 * resolver_output_params.x;
          float _442 = _439 * resolver_output_params.x;
          float _443 = _440 * resolver_output_params.x;
          float _444 = exp2(_441);
          float _445 = exp2(_442);
          float _446 = exp2(_443);
          float _447 = _444 * 18.8515625f;
          float _448 = _447 + 0.8359375f;
          float _449 = _444 * 18.6875f;
          float _450 = _449 + 1.0f;
          float _451 = _448 / _450;
          float _452 = abs(_451);
          float _453 = log2(_452);
          float _454 = _453 * 78.84375f;
          float _455 = exp2(_454);
          float _456 = _445 * 18.8515625f;
          float _457 = _456 + 0.8359375f;
          float _458 = _445 * 18.6875f;
          float _459 = _458 + 1.0f;
          float _460 = _457 / _459;
          float _461 = abs(_460);
          float _462 = log2(_461);
          float _463 = _462 * 78.84375f;
          float _464 = exp2(_463);
          float _465 = _446 * 18.8515625f;
          float _466 = _465 + 0.8359375f;
          float _467 = _446 * 18.6875f;
          float _468 = _467 + 1.0f;
          float _469 = _466 / _468;
          float _470 = abs(_469);
          float _471 = log2(_470);
          float _472 = _471 * 78.84375f;
          float _473 = exp2(_472);
          _475 = _455;
          _476 = _464;
          _477 = _473;
        } else {
          _475 = _137.x;
          _476 = _137.y;
          _477 = _137.z;
        }
      }
      u1_space6[int2(_28, _29)] = float4(_475, _476, _477, _137.w);
    }
  } else {
    u0_space6[int2(_28, _29)] = float4(_131, _132, _133, 1.0f);
  }
  int _482 = _28 | 8;
  float4 _484 = t0_space6.Load(int3(_482, _30, 0));
  uint _488 = _482 + -1u;
  float4 _489 = t0_space6.Load(int3(_488, _29, 0));
  float4 _493 = t0_space6.Load(int3(_482, _29, 0));
  uint _497 = _482 + 1u;
  float4 _498 = t0_space6.Load(int3(_497, _29, 0));
  float4 _502 = t0_space6.Load(int3(_482, _50, 0));
  float _506 = min(_489.x, _498.x);
  float _507 = min(_484.x, _506);
  float _508 = min(_507, _502.x);
  float _509 = min(_489.y, _498.y);
  float _510 = min(_484.y, _509);
  float _511 = min(_510, _502.y);
  float _512 = min(_489.z, _498.z);
  float _513 = min(_484.z, _512);
  float _514 = min(_513, _502.z);
  float _515 = max(_489.x, _498.x);
  float _516 = max(_484.x, _515);
  float _517 = max(_516, _502.x);
  float _518 = max(_489.y, _498.y);
  float _519 = max(_484.y, _518);
  float _520 = max(_519, _502.y);
  float _521 = max(_489.z, _498.z);
  float _522 = max(_484.z, _521);
  float _523 = max(_522, _502.z);
  float _524 = 0.25f / _517;
  float _525 = 0.25f / _520;
  float _526 = 0.25f / _523;
  float _527 = 1.0f - _517;
  float _528 = _508 * 4.0f;
  float _529 = _528 + -4.0f;
  float _530 = 1.0f / _529;
  float _531 = _530 * _527;
  float _532 = 1.0f - _520;
  float _533 = _511 * 4.0f;
  float _534 = _533 + -4.0f;
  float _535 = 1.0f / _534;
  float _536 = _535 * _532;
  float _537 = 1.0f - _523;
  float _538 = _514 * 4.0f;
  float _539 = _538 + -4.0f;
  float _540 = 1.0f / _539;
  float _541 = _540 * _537;
  float _542 = _508 * _524;
  float _543 = -0.0f - _542;
  float _544 = max(_543, _531);
  float _545 = _511 * _525;
  float _546 = -0.0f - _545;
  float _547 = max(_546, _536);
  float _548 = _514 * _526;
  float _549 = -0.0f - _548;
  float _550 = max(_549, _541);
  float _551 = max(_547, _550);
  float _552 = max(_544, _551);
  float _553 = min(_552, 0.0f);
  float _554 = max(-0.1875f, _553);
  float _555 = _554 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _556 = _555 * 4.0f;
  float _557 = _556 + 1.0f;
  int _558 = asint(_557);
  uint _559 = 2129764351u - _558;
  float _560 = asfloat(_559);
  float _561 = _560 * _557;
  float _562 = 2.0f - _561;
  float _563 = _562 * _560;
  float _564 = _489.x + _484.x;
  float _565 = _564 + _498.x;
  float _566 = _565 + _502.x;
  float _567 = _555 * _566;
  float _568 = _567 + _493.x;
  float _569 = _563 * _568;
  float _570 = _489.y + _484.y;
  float _571 = _570 + _498.y;
  float _572 = _571 + _502.y;
  float _573 = _555 * _572;
  float _574 = _573 + _493.y;
  float _575 = _563 * _574;
  float _576 = _489.z + _484.z;
  float _577 = _576 + _498.z;
  float _578 = _577 + _502.z;
  float _579 = _555 * _578;
  float _580 = _579 + _493.z;
  float _581 = _563 * _580;
  const float3 resolver_color_1 = SelectResolverSharpening(
      float3(_569, _575, _581), _484.rgb, _489.rgb, _493.rgb, _498.rgb, _502.rgb,
      resolver_output_params);
  float _582 = min(resolver_color_1.x, scene_cap);
  float _583 = min(resolver_color_1.y, scene_cap);
  float _584 = min(resolver_color_1.z, scene_cap);
  float4 _586 = t1_space6.Load(int3(_482, _29, 0));
  float _591 = max(_586.y, _586.z);
  float _592 = max(_586.x, _591);
  float _593 = _592 + _586.w;
  bool _594 = !(_593 > 0.0f);
  bool _595 = _146 || _594;
  if (!_595) {
    int _597 = int(resolver_output_params.w);
    bool _598 = (_597 == 1);
    [branch]
    if (_598) {
      bool _600 = (_582 < 0.040449999272823334f);
      if (_600) {
        float _602 = _582 * 0.07739938050508499f;
        _611 = _602;
      } else {
        float _604 = _582 * 0.9478672742843628f;
        float _605 = _604 + 0.05213269963860512f;
        float _606 = abs(_605);
        float _607 = log2(_606);
        float _608 = _607 * 2.4000000953674316f;
        float _609 = exp2(_608);
        _611 = _609;
      }
      bool _612 = (_583 < 0.040449999272823334f);
      if (_612) {
        float _614 = _583 * 0.07739938050508499f;
        _623 = _614;
      } else {
        float _616 = _583 * 0.9478672742843628f;
        float _617 = _616 + 0.05213269963860512f;
        float _618 = abs(_617);
        float _619 = log2(_618);
        float _620 = _619 * 2.4000000953674316f;
        float _621 = exp2(_620);
        _623 = _621;
      }
      bool _624 = (_584 < 0.040449999272823334f);
      if (_624) {
        float _626 = _584 * 0.07739938050508499f;
        _635 = _626;
      } else {
        float _628 = _584 * 0.9478672742843628f;
        float _629 = _628 + 0.05213269963860512f;
        float _630 = abs(_629);
        float _631 = log2(_630);
        float _632 = _631 * 2.4000000953674316f;
        float _633 = exp2(_632);
        _635 = _633;
      }
      float _636 = 1.0f / resolver_output_params.x;
      float _637 = abs(_611);
      float _638 = abs(_623);
      float _639 = abs(_635);
      float _640 = log2(_637);
      float _641 = log2(_638);
      float _642 = log2(_639);
      float _643 = _640 * _636;
      float _644 = _641 * _636;
      float _645 = _642 * _636;
      float _646 = exp2(_643);
      float _647 = exp2(_644);
      float _648 = exp2(_645);
      _703 = _646;
      _704 = _647;
      _705 = _648;
    } else {
      bool _650 = (_597 == 2);
      if (_650) {
        float _652 = abs(_582);
        float _653 = abs(_583);
        float _654 = abs(_584);
        float _655 = log2(_652);
        float _656 = log2(_653);
        float _657 = log2(_654);
        float _658 = _655 * 0.012683313339948654f;
        float _659 = _656 * 0.012683313339948654f;
        float _660 = _657 * 0.012683313339948654f;
        float _661 = exp2(_658);
        float _662 = exp2(_659);
        float _663 = exp2(_660);
        float _664 = _661 + -0.8359375f;
        float _665 = _661 * 18.6875f;
        float _666 = 18.8515625f - _665;
        float _667 = _664 / _666;
        float _668 = _662 + -0.8359375f;
        float _669 = _662 * 18.6875f;
        float _670 = 18.8515625f - _669;
        float _671 = _668 / _670;
        float _672 = _663 + -0.8359375f;
        float _673 = _663 * 18.6875f;
        float _674 = 18.8515625f - _673;
        float _675 = _672 / _674;
        float _676 = 1.0f / resolver_output_params.x;
        float _677 = abs(_667);
        float _678 = abs(_671);
        float _679 = abs(_675);
        float _680 = log2(_677);
        float _681 = log2(_678);
        float _682 = log2(_679);
        float _683 = _680 * _676;
        float _684 = _681 * _676;
        float _685 = _682 * _676;
        float _686 = exp2(_683);
        float _687 = exp2(_684);
        float _688 = exp2(_685);
        float _689 = 1.0f / resolver_output_params.y;
        float _690 = _689 * _686;
        float _691 = _689 * _687;
        float _692 = _689 * _688;
        float _693 = _690 * 1.6604900360107422f;
        float _694 = mad(-0.5876410007476807f, _691, _693);
        float _695 = mad(-0.07284989953041077f, _692, _694);
        float _696 = _690 * -0.124549999833107f;
        float _697 = mad(1.1328999996185303f, _691, _696);
        float _698 = mad(-0.008349419571459293f, _692, _697);
        float _699 = _690 * -0.018150800839066505f;
        float _700 = mad(-0.10057900100946426f, _691, _699);
        float _701 = mad(1.1187299489974976f, _692, _700);
        _703 = _695;
        _704 = _698;
        _705 = _701;
      } else {
        _703 = _582;
        _704 = _583;
        _705 = _584;
      }
    }
    float _706 = 1.0f - _586.w;
    float _707 = _703 * _706;
    float _708 = _704 * _706;
    float _709 = _705 * _706;
    float _710 = _707 + _586.x;
    float _711 = _708 + _586.y;
    float _712 = _709 + _586.z;
    [branch]
    if (_598) {
      float _714 = abs(_710);
      float _715 = abs(_711);
      float _716 = abs(_712);
      float _717 = log2(_714);
      float _718 = log2(_715);
      float _719 = log2(_716);
      float _720 = _717 * resolver_output_params.x;
      float _721 = _718 * resolver_output_params.x;
      float _722 = _719 * resolver_output_params.x;
      float _723 = exp2(_720);
      float _724 = exp2(_721);
      float _725 = exp2(_722);
      bool _726 = (_723 < 0.003100000089034438f);
      if (_726) {
        float _728 = _723 * 12.920000076293945f;
        _737 = _728;
      } else {
        float _730 = abs(_723);
        float _731 = log2(_730);
        float _732 = _731 * 0.4166666567325592f;
        float _733 = exp2(_732);
        float _734 = _733 * 1.0549999475479126f;
        float _735 = _734 + -0.054999999701976776f;
        _737 = _735;
      }
      bool _738 = (_724 < 0.003100000089034438f);
      if (_738) {
        float _740 = _724 * 12.920000076293945f;
        _749 = _740;
      } else {
        float _742 = abs(_724);
        float _743 = log2(_742);
        float _744 = _743 * 0.4166666567325592f;
        float _745 = exp2(_744);
        float _746 = _745 * 1.0549999475479126f;
        float _747 = _746 + -0.054999999701976776f;
        _749 = _747;
      }
      bool _750 = (_725 < 0.003100000089034438f);
      if (_750) {
        float _752 = _725 * 12.920000076293945f;
        _815 = _737;
        _816 = _749;
        _817 = _752;
      } else {
        float _754 = abs(_725);
        float _755 = log2(_754);
        float _756 = _755 * 0.4166666567325592f;
        float _757 = exp2(_756);
        float _758 = _757 * 1.0549999475479126f;
        float _759 = _758 + -0.054999999701976776f;
        _815 = _737;
        _816 = _749;
        _817 = _759;
      }
    } else {
      bool _761 = (_597 == 2);
      if (_761) {
        float _763 = _710 * 0.6274039149284363f;
        float _764 = mad(0.3292830288410187f, _711, _763);
        float _765 = mad(0.04331306740641594f, _712, _764);
        float _766 = _710 * 0.06909728795289993f;
        float _767 = mad(0.9195404052734375f, _711, _766);
        float _768 = mad(0.011362316086888313f, _712, _767);
        float _769 = _710 * 0.016391439363360405f;
        float _770 = mad(0.08801330626010895f, _711, _769);
        float _771 = mad(0.8955952525138855f, _712, _770);
        float _772 = _765 * resolver_output_params.y;
        float _773 = _768 * resolver_output_params.y;
        float _774 = _771 * resolver_output_params.y;
        float _775 = abs(_772);
        float _776 = abs(_773);
        float _777 = abs(_774);
        float _778 = log2(_775);
        float _779 = log2(_776);
        float _780 = log2(_777);
        float _781 = _778 * resolver_output_params.x;
        float _782 = _779 * resolver_output_params.x;
        float _783 = _780 * resolver_output_params.x;
        float _784 = exp2(_781);
        float _785 = exp2(_782);
        float _786 = exp2(_783);
        float _787 = _784 * 18.8515625f;
        float _788 = _787 + 0.8359375f;
        float _789 = _784 * 18.6875f;
        float _790 = _789 + 1.0f;
        float _791 = _788 / _790;
        float _792 = abs(_791);
        float _793 = log2(_792);
        float _794 = _793 * 78.84375f;
        float _795 = exp2(_794);
        float _796 = _785 * 18.8515625f;
        float _797 = _796 + 0.8359375f;
        float _798 = _785 * 18.6875f;
        float _799 = _798 + 1.0f;
        float _800 = _797 / _799;
        float _801 = abs(_800);
        float _802 = log2(_801);
        float _803 = _802 * 78.84375f;
        float _804 = exp2(_803);
        float _805 = _786 * 18.8515625f;
        float _806 = _805 + 0.8359375f;
        float _807 = _786 * 18.6875f;
        float _808 = _807 + 1.0f;
        float _809 = _806 / _808;
        float _810 = abs(_809);
        float _811 = log2(_810);
        float _812 = _811 * 78.84375f;
        float _813 = exp2(_812);
        _815 = _795;
        _816 = _804;
        _817 = _813;
      } else {
        _815 = _710;
        _816 = _711;
        _817 = _712;
      }
    }
    u0_space6[int2(_482, _29)] = float4(_815, _816, _817, 1.0f);
    bool _819 = (_134 == 0);
    if (!_819) {
      [branch]
      if (_598) {
        float _822 = abs(_586.x);
        float _823 = abs(_586.y);
        float _824 = abs(_586.z);
        float _825 = log2(_822);
        float _826 = log2(_823);
        float _827 = log2(_824);
        float _828 = _825 * resolver_output_params.x;
        float _829 = _826 * resolver_output_params.x;
        float _830 = _827 * resolver_output_params.x;
        float _831 = exp2(_828);
        float _832 = exp2(_829);
        float _833 = exp2(_830);
        bool _834 = (_831 < 0.003100000089034438f);
        if (_834) {
          float _836 = _831 * 12.920000076293945f;
          _845 = _836;
        } else {
          float _838 = abs(_831);
          float _839 = log2(_838);
          float _840 = _839 * 0.4166666567325592f;
          float _841 = exp2(_840);
          float _842 = _841 * 1.0549999475479126f;
          float _843 = _842 + -0.054999999701976776f;
          _845 = _843;
        }
        bool _846 = (_832 < 0.003100000089034438f);
        if (_846) {
          float _848 = _832 * 12.920000076293945f;
          _857 = _848;
        } else {
          float _850 = abs(_832);
          float _851 = log2(_850);
          float _852 = _851 * 0.4166666567325592f;
          float _853 = exp2(_852);
          float _854 = _853 * 1.0549999475479126f;
          float _855 = _854 + -0.054999999701976776f;
          _857 = _855;
        }
        bool _858 = (_833 < 0.003100000089034438f);
        if (_858) {
          float _860 = _833 * 12.920000076293945f;
          _923 = _845;
          _924 = _857;
          _925 = _860;
        } else {
          float _862 = abs(_833);
          float _863 = log2(_862);
          float _864 = _863 * 0.4166666567325592f;
          float _865 = exp2(_864);
          float _866 = _865 * 1.0549999475479126f;
          float _867 = _866 + -0.054999999701976776f;
          _923 = _845;
          _924 = _857;
          _925 = _867;
        }
      } else {
        bool _869 = (_597 == 2);
        if (_869) {
          float _871 = _586.x * 0.6274039149284363f;
          float _872 = mad(0.3292830288410187f, _586.y, _871);
          float _873 = mad(0.04331306740641594f, _586.z, _872);
          float _874 = _586.x * 0.06909728795289993f;
          float _875 = mad(0.9195404052734375f, _586.y, _874);
          float _876 = mad(0.011362316086888313f, _586.z, _875);
          float _877 = _586.x * 0.016391439363360405f;
          float _878 = mad(0.08801330626010895f, _586.y, _877);
          float _879 = mad(0.8955952525138855f, _586.z, _878);
          float _880 = _873 * resolver_output_params.y;
          float _881 = _876 * resolver_output_params.y;
          float _882 = _879 * resolver_output_params.y;
          float _883 = abs(_880);
          float _884 = abs(_881);
          float _885 = abs(_882);
          float _886 = log2(_883);
          float _887 = log2(_884);
          float _888 = log2(_885);
          float _889 = _886 * resolver_output_params.x;
          float _890 = _887 * resolver_output_params.x;
          float _891 = _888 * resolver_output_params.x;
          float _892 = exp2(_889);
          float _893 = exp2(_890);
          float _894 = exp2(_891);
          float _895 = _892 * 18.8515625f;
          float _896 = _895 + 0.8359375f;
          float _897 = _892 * 18.6875f;
          float _898 = _897 + 1.0f;
          float _899 = _896 / _898;
          float _900 = abs(_899);
          float _901 = log2(_900);
          float _902 = _901 * 78.84375f;
          float _903 = exp2(_902);
          float _904 = _893 * 18.8515625f;
          float _905 = _904 + 0.8359375f;
          float _906 = _893 * 18.6875f;
          float _907 = _906 + 1.0f;
          float _908 = _905 / _907;
          float _909 = abs(_908);
          float _910 = log2(_909);
          float _911 = _910 * 78.84375f;
          float _912 = exp2(_911);
          float _913 = _894 * 18.8515625f;
          float _914 = _913 + 0.8359375f;
          float _915 = _894 * 18.6875f;
          float _916 = _915 + 1.0f;
          float _917 = _914 / _916;
          float _918 = abs(_917);
          float _919 = log2(_918);
          float _920 = _919 * 78.84375f;
          float _921 = exp2(_920);
          _923 = _903;
          _924 = _912;
          _925 = _921;
        } else {
          _923 = _586.x;
          _924 = _586.y;
          _925 = _586.z;
        }
      }
      u1_space6[int2(_482, _29)] = float4(_923, _924, _925, _586.w);
    }
  } else {
    u0_space6[int2(_482, _29)] = float4(_582, _583, _584, 1.0f);
  }
  int _930 = _29 | 8;
  uint _931 = _930 + -1u;
  float4 _933 = t0_space6.Load(int3(_482, _931, 0));
  float4 _937 = t0_space6.Load(int3(_488, _930, 0));
  float4 _941 = t0_space6.Load(int3(_482, _930, 0));
  float4 _945 = t0_space6.Load(int3(_497, _930, 0));
  uint _949 = _930 + 1u;
  float4 _950 = t0_space6.Load(int3(_482, _949, 0));
  float _954 = min(_937.x, _945.x);
  float _955 = min(_933.x, _954);
  float _956 = min(_955, _950.x);
  float _957 = min(_937.y, _945.y);
  float _958 = min(_933.y, _957);
  float _959 = min(_958, _950.y);
  float _960 = min(_937.z, _945.z);
  float _961 = min(_933.z, _960);
  float _962 = min(_961, _950.z);
  float _963 = max(_937.x, _945.x);
  float _964 = max(_933.x, _963);
  float _965 = max(_964, _950.x);
  float _966 = max(_937.y, _945.y);
  float _967 = max(_933.y, _966);
  float _968 = max(_967, _950.y);
  float _969 = max(_937.z, _945.z);
  float _970 = max(_933.z, _969);
  float _971 = max(_970, _950.z);
  float _972 = 0.25f / _965;
  float _973 = 0.25f / _968;
  float _974 = 0.25f / _971;
  float _975 = 1.0f - _965;
  float _976 = _956 * 4.0f;
  float _977 = _976 + -4.0f;
  float _978 = 1.0f / _977;
  float _979 = _978 * _975;
  float _980 = 1.0f - _968;
  float _981 = _959 * 4.0f;
  float _982 = _981 + -4.0f;
  float _983 = 1.0f / _982;
  float _984 = _983 * _980;
  float _985 = 1.0f - _971;
  float _986 = _962 * 4.0f;
  float _987 = _986 + -4.0f;
  float _988 = 1.0f / _987;
  float _989 = _988 * _985;
  float _990 = _956 * _972;
  float _991 = -0.0f - _990;
  float _992 = max(_991, _979);
  float _993 = _959 * _973;
  float _994 = -0.0f - _993;
  float _995 = max(_994, _984);
  float _996 = _962 * _974;
  float _997 = -0.0f - _996;
  float _998 = max(_997, _989);
  float _999 = max(_995, _998);
  float _1000 = max(_992, _999);
  float _1001 = min(_1000, 0.0f);
  float _1002 = max(-0.1875f, _1001);
  float _1003 = _1002 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _1004 = _1003 * 4.0f;
  float _1005 = _1004 + 1.0f;
  int _1006 = asint(_1005);
  uint _1007 = 2129764351u - _1006;
  float _1008 = asfloat(_1007);
  float _1009 = _1008 * _1005;
  float _1010 = 2.0f - _1009;
  float _1011 = _1010 * _1008;
  float _1012 = _937.x + _933.x;
  float _1013 = _1012 + _945.x;
  float _1014 = _1013 + _950.x;
  float _1015 = _1003 * _1014;
  float _1016 = _1015 + _941.x;
  float _1017 = _1011 * _1016;
  float _1018 = _937.y + _933.y;
  float _1019 = _1018 + _945.y;
  float _1020 = _1019 + _950.y;
  float _1021 = _1003 * _1020;
  float _1022 = _1021 + _941.y;
  float _1023 = _1011 * _1022;
  float _1024 = _937.z + _933.z;
  float _1025 = _1024 + _945.z;
  float _1026 = _1025 + _950.z;
  float _1027 = _1003 * _1026;
  float _1028 = _1027 + _941.z;
  float _1029 = _1011 * _1028;
  const float3 resolver_color_2 = SelectResolverSharpening(
      float3(_1017, _1023, _1029), _933.rgb, _937.rgb, _941.rgb, _945.rgb, _950.rgb,
      resolver_output_params);
  float _1030 = min(resolver_color_2.x, scene_cap);
  float _1031 = min(resolver_color_2.y, scene_cap);
  float _1032 = min(resolver_color_2.z, scene_cap);
  float4 _1034 = t1_space6.Load(int3(_482, _930, 0));
  float _1039 = max(_1034.y, _1034.z);
  float _1040 = max(_1034.x, _1039);
  float _1041 = _1040 + _1034.w;
  bool _1042 = !(_1041 > 0.0f);
  bool _1043 = _146 || _1042;
  if (!_1043) {
    int _1045 = int(resolver_output_params.w);
    bool _1046 = (_1045 == 1);
    [branch]
    if (_1046) {
      bool _1048 = (_1030 < 0.040449999272823334f);
      if (_1048) {
        float _1050 = _1030 * 0.07739938050508499f;
        _1059 = _1050;
      } else {
        float _1052 = _1030 * 0.9478672742843628f;
        float _1053 = _1052 + 0.05213269963860512f;
        float _1054 = abs(_1053);
        float _1055 = log2(_1054);
        float _1056 = _1055 * 2.4000000953674316f;
        float _1057 = exp2(_1056);
        _1059 = _1057;
      }
      bool _1060 = (_1031 < 0.040449999272823334f);
      if (_1060) {
        float _1062 = _1031 * 0.07739938050508499f;
        _1071 = _1062;
      } else {
        float _1064 = _1031 * 0.9478672742843628f;
        float _1065 = _1064 + 0.05213269963860512f;
        float _1066 = abs(_1065);
        float _1067 = log2(_1066);
        float _1068 = _1067 * 2.4000000953674316f;
        float _1069 = exp2(_1068);
        _1071 = _1069;
      }
      bool _1072 = (_1032 < 0.040449999272823334f);
      if (_1072) {
        float _1074 = _1032 * 0.07739938050508499f;
        _1083 = _1074;
      } else {
        float _1076 = _1032 * 0.9478672742843628f;
        float _1077 = _1076 + 0.05213269963860512f;
        float _1078 = abs(_1077);
        float _1079 = log2(_1078);
        float _1080 = _1079 * 2.4000000953674316f;
        float _1081 = exp2(_1080);
        _1083 = _1081;
      }
      float _1084 = 1.0f / resolver_output_params.x;
      float _1085 = abs(_1059);
      float _1086 = abs(_1071);
      float _1087 = abs(_1083);
      float _1088 = log2(_1085);
      float _1089 = log2(_1086);
      float _1090 = log2(_1087);
      float _1091 = _1088 * _1084;
      float _1092 = _1089 * _1084;
      float _1093 = _1090 * _1084;
      float _1094 = exp2(_1091);
      float _1095 = exp2(_1092);
      float _1096 = exp2(_1093);
      _1151 = _1094;
      _1152 = _1095;
      _1153 = _1096;
    } else {
      bool _1098 = (_1045 == 2);
      if (_1098) {
        float _1100 = abs(_1030);
        float _1101 = abs(_1031);
        float _1102 = abs(_1032);
        float _1103 = log2(_1100);
        float _1104 = log2(_1101);
        float _1105 = log2(_1102);
        float _1106 = _1103 * 0.012683313339948654f;
        float _1107 = _1104 * 0.012683313339948654f;
        float _1108 = _1105 * 0.012683313339948654f;
        float _1109 = exp2(_1106);
        float _1110 = exp2(_1107);
        float _1111 = exp2(_1108);
        float _1112 = _1109 + -0.8359375f;
        float _1113 = _1109 * 18.6875f;
        float _1114 = 18.8515625f - _1113;
        float _1115 = _1112 / _1114;
        float _1116 = _1110 + -0.8359375f;
        float _1117 = _1110 * 18.6875f;
        float _1118 = 18.8515625f - _1117;
        float _1119 = _1116 / _1118;
        float _1120 = _1111 + -0.8359375f;
        float _1121 = _1111 * 18.6875f;
        float _1122 = 18.8515625f - _1121;
        float _1123 = _1120 / _1122;
        float _1124 = 1.0f / resolver_output_params.x;
        float _1125 = abs(_1115);
        float _1126 = abs(_1119);
        float _1127 = abs(_1123);
        float _1128 = log2(_1125);
        float _1129 = log2(_1126);
        float _1130 = log2(_1127);
        float _1131 = _1128 * _1124;
        float _1132 = _1129 * _1124;
        float _1133 = _1130 * _1124;
        float _1134 = exp2(_1131);
        float _1135 = exp2(_1132);
        float _1136 = exp2(_1133);
        float _1137 = 1.0f / resolver_output_params.y;
        float _1138 = _1137 * _1134;
        float _1139 = _1137 * _1135;
        float _1140 = _1137 * _1136;
        float _1141 = _1138 * 1.6604900360107422f;
        float _1142 = mad(-0.5876410007476807f, _1139, _1141);
        float _1143 = mad(-0.07284989953041077f, _1140, _1142);
        float _1144 = _1138 * -0.124549999833107f;
        float _1145 = mad(1.1328999996185303f, _1139, _1144);
        float _1146 = mad(-0.008349419571459293f, _1140, _1145);
        float _1147 = _1138 * -0.018150800839066505f;
        float _1148 = mad(-0.10057900100946426f, _1139, _1147);
        float _1149 = mad(1.1187299489974976f, _1140, _1148);
        _1151 = _1143;
        _1152 = _1146;
        _1153 = _1149;
      } else {
        _1151 = _1030;
        _1152 = _1031;
        _1153 = _1032;
      }
    }
    float _1154 = 1.0f - _1034.w;
    float _1155 = _1151 * _1154;
    float _1156 = _1152 * _1154;
    float _1157 = _1153 * _1154;
    float _1158 = _1155 + _1034.x;
    float _1159 = _1156 + _1034.y;
    float _1160 = _1157 + _1034.z;
    [branch]
    if (_1046) {
      float _1162 = abs(_1158);
      float _1163 = abs(_1159);
      float _1164 = abs(_1160);
      float _1165 = log2(_1162);
      float _1166 = log2(_1163);
      float _1167 = log2(_1164);
      float _1168 = _1165 * resolver_output_params.x;
      float _1169 = _1166 * resolver_output_params.x;
      float _1170 = _1167 * resolver_output_params.x;
      float _1171 = exp2(_1168);
      float _1172 = exp2(_1169);
      float _1173 = exp2(_1170);
      bool _1174 = (_1171 < 0.003100000089034438f);
      if (_1174) {
        float _1176 = _1171 * 12.920000076293945f;
        _1185 = _1176;
      } else {
        float _1178 = abs(_1171);
        float _1179 = log2(_1178);
        float _1180 = _1179 * 0.4166666567325592f;
        float _1181 = exp2(_1180);
        float _1182 = _1181 * 1.0549999475479126f;
        float _1183 = _1182 + -0.054999999701976776f;
        _1185 = _1183;
      }
      bool _1186 = (_1172 < 0.003100000089034438f);
      if (_1186) {
        float _1188 = _1172 * 12.920000076293945f;
        _1197 = _1188;
      } else {
        float _1190 = abs(_1172);
        float _1191 = log2(_1190);
        float _1192 = _1191 * 0.4166666567325592f;
        float _1193 = exp2(_1192);
        float _1194 = _1193 * 1.0549999475479126f;
        float _1195 = _1194 + -0.054999999701976776f;
        _1197 = _1195;
      }
      bool _1198 = (_1173 < 0.003100000089034438f);
      if (_1198) {
        float _1200 = _1173 * 12.920000076293945f;
        _1263 = _1185;
        _1264 = _1197;
        _1265 = _1200;
      } else {
        float _1202 = abs(_1173);
        float _1203 = log2(_1202);
        float _1204 = _1203 * 0.4166666567325592f;
        float _1205 = exp2(_1204);
        float _1206 = _1205 * 1.0549999475479126f;
        float _1207 = _1206 + -0.054999999701976776f;
        _1263 = _1185;
        _1264 = _1197;
        _1265 = _1207;
      }
    } else {
      bool _1209 = (_1045 == 2);
      if (_1209) {
        float _1211 = _1158 * 0.6274039149284363f;
        float _1212 = mad(0.3292830288410187f, _1159, _1211);
        float _1213 = mad(0.04331306740641594f, _1160, _1212);
        float _1214 = _1158 * 0.06909728795289993f;
        float _1215 = mad(0.9195404052734375f, _1159, _1214);
        float _1216 = mad(0.011362316086888313f, _1160, _1215);
        float _1217 = _1158 * 0.016391439363360405f;
        float _1218 = mad(0.08801330626010895f, _1159, _1217);
        float _1219 = mad(0.8955952525138855f, _1160, _1218);
        float _1220 = _1213 * resolver_output_params.y;
        float _1221 = _1216 * resolver_output_params.y;
        float _1222 = _1219 * resolver_output_params.y;
        float _1223 = abs(_1220);
        float _1224 = abs(_1221);
        float _1225 = abs(_1222);
        float _1226 = log2(_1223);
        float _1227 = log2(_1224);
        float _1228 = log2(_1225);
        float _1229 = _1226 * resolver_output_params.x;
        float _1230 = _1227 * resolver_output_params.x;
        float _1231 = _1228 * resolver_output_params.x;
        float _1232 = exp2(_1229);
        float _1233 = exp2(_1230);
        float _1234 = exp2(_1231);
        float _1235 = _1232 * 18.8515625f;
        float _1236 = _1235 + 0.8359375f;
        float _1237 = _1232 * 18.6875f;
        float _1238 = _1237 + 1.0f;
        float _1239 = _1236 / _1238;
        float _1240 = abs(_1239);
        float _1241 = log2(_1240);
        float _1242 = _1241 * 78.84375f;
        float _1243 = exp2(_1242);
        float _1244 = _1233 * 18.8515625f;
        float _1245 = _1244 + 0.8359375f;
        float _1246 = _1233 * 18.6875f;
        float _1247 = _1246 + 1.0f;
        float _1248 = _1245 / _1247;
        float _1249 = abs(_1248);
        float _1250 = log2(_1249);
        float _1251 = _1250 * 78.84375f;
        float _1252 = exp2(_1251);
        float _1253 = _1234 * 18.8515625f;
        float _1254 = _1253 + 0.8359375f;
        float _1255 = _1234 * 18.6875f;
        float _1256 = _1255 + 1.0f;
        float _1257 = _1254 / _1256;
        float _1258 = abs(_1257);
        float _1259 = log2(_1258);
        float _1260 = _1259 * 78.84375f;
        float _1261 = exp2(_1260);
        _1263 = _1243;
        _1264 = _1252;
        _1265 = _1261;
      } else {
        _1263 = _1158;
        _1264 = _1159;
        _1265 = _1160;
      }
    }
    u0_space6[int2(_482, _930)] = float4(_1263, _1264, _1265, 1.0f);
    bool _1267 = (_134 == 0);
    if (!_1267) {
      [branch]
      if (_1046) {
        float _1270 = abs(_1034.x);
        float _1271 = abs(_1034.y);
        float _1272 = abs(_1034.z);
        float _1273 = log2(_1270);
        float _1274 = log2(_1271);
        float _1275 = log2(_1272);
        float _1276 = _1273 * resolver_output_params.x;
        float _1277 = _1274 * resolver_output_params.x;
        float _1278 = _1275 * resolver_output_params.x;
        float _1279 = exp2(_1276);
        float _1280 = exp2(_1277);
        float _1281 = exp2(_1278);
        bool _1282 = (_1279 < 0.003100000089034438f);
        if (_1282) {
          float _1284 = _1279 * 12.920000076293945f;
          _1293 = _1284;
        } else {
          float _1286 = abs(_1279);
          float _1287 = log2(_1286);
          float _1288 = _1287 * 0.4166666567325592f;
          float _1289 = exp2(_1288);
          float _1290 = _1289 * 1.0549999475479126f;
          float _1291 = _1290 + -0.054999999701976776f;
          _1293 = _1291;
        }
        bool _1294 = (_1280 < 0.003100000089034438f);
        if (_1294) {
          float _1296 = _1280 * 12.920000076293945f;
          _1305 = _1296;
        } else {
          float _1298 = abs(_1280);
          float _1299 = log2(_1298);
          float _1300 = _1299 * 0.4166666567325592f;
          float _1301 = exp2(_1300);
          float _1302 = _1301 * 1.0549999475479126f;
          float _1303 = _1302 + -0.054999999701976776f;
          _1305 = _1303;
        }
        bool _1306 = (_1281 < 0.003100000089034438f);
        if (_1306) {
          float _1308 = _1281 * 12.920000076293945f;
          _1371 = _1293;
          _1372 = _1305;
          _1373 = _1308;
        } else {
          float _1310 = abs(_1281);
          float _1311 = log2(_1310);
          float _1312 = _1311 * 0.4166666567325592f;
          float _1313 = exp2(_1312);
          float _1314 = _1313 * 1.0549999475479126f;
          float _1315 = _1314 + -0.054999999701976776f;
          _1371 = _1293;
          _1372 = _1305;
          _1373 = _1315;
        }
      } else {
        bool _1317 = (_1045 == 2);
        if (_1317) {
          float _1319 = _1034.x * 0.6274039149284363f;
          float _1320 = mad(0.3292830288410187f, _1034.y, _1319);
          float _1321 = mad(0.04331306740641594f, _1034.z, _1320);
          float _1322 = _1034.x * 0.06909728795289993f;
          float _1323 = mad(0.9195404052734375f, _1034.y, _1322);
          float _1324 = mad(0.011362316086888313f, _1034.z, _1323);
          float _1325 = _1034.x * 0.016391439363360405f;
          float _1326 = mad(0.08801330626010895f, _1034.y, _1325);
          float _1327 = mad(0.8955952525138855f, _1034.z, _1326);
          float _1328 = _1321 * resolver_output_params.y;
          float _1329 = _1324 * resolver_output_params.y;
          float _1330 = _1327 * resolver_output_params.y;
          float _1331 = abs(_1328);
          float _1332 = abs(_1329);
          float _1333 = abs(_1330);
          float _1334 = log2(_1331);
          float _1335 = log2(_1332);
          float _1336 = log2(_1333);
          float _1337 = _1334 * resolver_output_params.x;
          float _1338 = _1335 * resolver_output_params.x;
          float _1339 = _1336 * resolver_output_params.x;
          float _1340 = exp2(_1337);
          float _1341 = exp2(_1338);
          float _1342 = exp2(_1339);
          float _1343 = _1340 * 18.8515625f;
          float _1344 = _1343 + 0.8359375f;
          float _1345 = _1340 * 18.6875f;
          float _1346 = _1345 + 1.0f;
          float _1347 = _1344 / _1346;
          float _1348 = abs(_1347);
          float _1349 = log2(_1348);
          float _1350 = _1349 * 78.84375f;
          float _1351 = exp2(_1350);
          float _1352 = _1341 * 18.8515625f;
          float _1353 = _1352 + 0.8359375f;
          float _1354 = _1341 * 18.6875f;
          float _1355 = _1354 + 1.0f;
          float _1356 = _1353 / _1355;
          float _1357 = abs(_1356);
          float _1358 = log2(_1357);
          float _1359 = _1358 * 78.84375f;
          float _1360 = exp2(_1359);
          float _1361 = _1342 * 18.8515625f;
          float _1362 = _1361 + 0.8359375f;
          float _1363 = _1342 * 18.6875f;
          float _1364 = _1363 + 1.0f;
          float _1365 = _1362 / _1364;
          float _1366 = abs(_1365);
          float _1367 = log2(_1366);
          float _1368 = _1367 * 78.84375f;
          float _1369 = exp2(_1368);
          _1371 = _1351;
          _1372 = _1360;
          _1373 = _1369;
        } else {
          _1371 = _1034.x;
          _1372 = _1034.y;
          _1373 = _1034.z;
        }
      }
      u1_space6[int2(_482, _930)] = float4(_1371, _1372, _1373, _1034.w);
    }
  } else {
    u0_space6[int2(_482, _930)] = float4(_1030, _1031, _1032, 1.0f);
  }
  float4 _1379 = t0_space6.Load(int3(_28, _931, 0));
  float4 _1383 = t0_space6.Load(int3(_36, _930, 0));
  float4 _1387 = t0_space6.Load(int3(_28, _930, 0));
  float4 _1391 = t0_space6.Load(int3(_45, _930, 0));
  float4 _1395 = t0_space6.Load(int3(_28, _949, 0));
  float _1399 = min(_1383.x, _1391.x);
  float _1400 = min(_1379.x, _1399);
  float _1401 = min(_1400, _1395.x);
  float _1402 = min(_1383.y, _1391.y);
  float _1403 = min(_1379.y, _1402);
  float _1404 = min(_1403, _1395.y);
  float _1405 = min(_1383.z, _1391.z);
  float _1406 = min(_1379.z, _1405);
  float _1407 = min(_1406, _1395.z);
  float _1408 = max(_1383.x, _1391.x);
  float _1409 = max(_1379.x, _1408);
  float _1410 = max(_1409, _1395.x);
  float _1411 = max(_1383.y, _1391.y);
  float _1412 = max(_1379.y, _1411);
  float _1413 = max(_1412, _1395.y);
  float _1414 = max(_1383.z, _1391.z);
  float _1415 = max(_1379.z, _1414);
  float _1416 = max(_1415, _1395.z);
  float _1417 = 0.25f / _1410;
  float _1418 = 0.25f / _1413;
  float _1419 = 0.25f / _1416;
  float _1420 = 1.0f - _1410;
  float _1421 = _1401 * 4.0f;
  float _1422 = _1421 + -4.0f;
  float _1423 = 1.0f / _1422;
  float _1424 = _1423 * _1420;
  float _1425 = 1.0f - _1413;
  float _1426 = _1404 * 4.0f;
  float _1427 = _1426 + -4.0f;
  float _1428 = 1.0f / _1427;
  float _1429 = _1428 * _1425;
  float _1430 = 1.0f - _1416;
  float _1431 = _1407 * 4.0f;
  float _1432 = _1431 + -4.0f;
  float _1433 = 1.0f / _1432;
  float _1434 = _1433 * _1430;
  float _1435 = _1401 * _1417;
  float _1436 = -0.0f - _1435;
  float _1437 = max(_1436, _1424);
  float _1438 = _1404 * _1418;
  float _1439 = -0.0f - _1438;
  float _1440 = max(_1439, _1429);
  float _1441 = _1407 * _1419;
  float _1442 = -0.0f - _1441;
  float _1443 = max(_1442, _1434);
  float _1444 = max(_1440, _1443);
  float _1445 = max(_1437, _1444);
  float _1446 = min(_1445, 0.0f);
  float _1447 = max(-0.1875f, _1446);
  float _1448 = _1447 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.x;
  float _1449 = _1448 * 4.0f;
  float _1450 = _1449 + 1.0f;
  int _1451 = asint(_1450);
  uint _1452 = 2129764351u - _1451;
  float _1453 = asfloat(_1452);
  float _1454 = _1453 * _1450;
  float _1455 = 2.0f - _1454;
  float _1456 = _1455 * _1453;
  float _1457 = _1383.x + _1379.x;
  float _1458 = _1457 + _1391.x;
  float _1459 = _1458 + _1395.x;
  float _1460 = _1448 * _1459;
  float _1461 = _1460 + _1387.x;
  float _1462 = _1456 * _1461;
  float _1463 = _1383.y + _1379.y;
  float _1464 = _1463 + _1391.y;
  float _1465 = _1464 + _1395.y;
  float _1466 = _1448 * _1465;
  float _1467 = _1466 + _1387.y;
  float _1468 = _1456 * _1467;
  float _1469 = _1383.z + _1379.z;
  float _1470 = _1469 + _1391.z;
  float _1471 = _1470 + _1395.z;
  float _1472 = _1448 * _1471;
  float _1473 = _1472 + _1387.z;
  float _1474 = _1456 * _1473;
  const float3 resolver_color_3 = SelectResolverSharpening(
      float3(_1462, _1468, _1474), _1379.rgb, _1383.rgb, _1387.rgb, _1391.rgb, _1395.rgb,
      resolver_output_params);
  float _1475 = min(resolver_color_3.x, scene_cap);
  float _1476 = min(resolver_color_3.y, scene_cap);
  float _1477 = min(resolver_color_3.z, scene_cap);
  float4 _1479 = t1_space6.Load(int3(_28, _930, 0));
  float _1484 = max(_1479.y, _1479.z);
  float _1485 = max(_1479.x, _1484);
  float _1486 = _1485 + _1479.w;
  bool _1487 = !(_1486 > 0.0f);
  bool _1488 = _146 || _1487;
  if (!_1488) {
    int _1490 = int(resolver_output_params.w);
    bool _1491 = (_1490 == 1);
    [branch]
    if (_1491) {
      bool _1493 = (_1475 < 0.040449999272823334f);
      if (_1493) {
        float _1495 = _1475 * 0.07739938050508499f;
        _1504 = _1495;
      } else {
        float _1497 = _1475 * 0.9478672742843628f;
        float _1498 = _1497 + 0.05213269963860512f;
        float _1499 = abs(_1498);
        float _1500 = log2(_1499);
        float _1501 = _1500 * 2.4000000953674316f;
        float _1502 = exp2(_1501);
        _1504 = _1502;
      }
      bool _1505 = (_1476 < 0.040449999272823334f);
      if (_1505) {
        float _1507 = _1476 * 0.07739938050508499f;
        _1516 = _1507;
      } else {
        float _1509 = _1476 * 0.9478672742843628f;
        float _1510 = _1509 + 0.05213269963860512f;
        float _1511 = abs(_1510);
        float _1512 = log2(_1511);
        float _1513 = _1512 * 2.4000000953674316f;
        float _1514 = exp2(_1513);
        _1516 = _1514;
      }
      bool _1517 = (_1477 < 0.040449999272823334f);
      if (_1517) {
        float _1519 = _1477 * 0.07739938050508499f;
        _1528 = _1519;
      } else {
        float _1521 = _1477 * 0.9478672742843628f;
        float _1522 = _1521 + 0.05213269963860512f;
        float _1523 = abs(_1522);
        float _1524 = log2(_1523);
        float _1525 = _1524 * 2.4000000953674316f;
        float _1526 = exp2(_1525);
        _1528 = _1526;
      }
      float _1529 = 1.0f / resolver_output_params.x;
      float _1530 = abs(_1504);
      float _1531 = abs(_1516);
      float _1532 = abs(_1528);
      float _1533 = log2(_1530);
      float _1534 = log2(_1531);
      float _1535 = log2(_1532);
      float _1536 = _1533 * _1529;
      float _1537 = _1534 * _1529;
      float _1538 = _1535 * _1529;
      float _1539 = exp2(_1536);
      float _1540 = exp2(_1537);
      float _1541 = exp2(_1538);
      _1596 = _1539;
      _1597 = _1540;
      _1598 = _1541;
    } else {
      bool _1543 = (_1490 == 2);
      if (_1543) {
        float _1545 = abs(_1475);
        float _1546 = abs(_1476);
        float _1547 = abs(_1477);
        float _1548 = log2(_1545);
        float _1549 = log2(_1546);
        float _1550 = log2(_1547);
        float _1551 = _1548 * 0.012683313339948654f;
        float _1552 = _1549 * 0.012683313339948654f;
        float _1553 = _1550 * 0.012683313339948654f;
        float _1554 = exp2(_1551);
        float _1555 = exp2(_1552);
        float _1556 = exp2(_1553);
        float _1557 = _1554 + -0.8359375f;
        float _1558 = _1554 * 18.6875f;
        float _1559 = 18.8515625f - _1558;
        float _1560 = _1557 / _1559;
        float _1561 = _1555 + -0.8359375f;
        float _1562 = _1555 * 18.6875f;
        float _1563 = 18.8515625f - _1562;
        float _1564 = _1561 / _1563;
        float _1565 = _1556 + -0.8359375f;
        float _1566 = _1556 * 18.6875f;
        float _1567 = 18.8515625f - _1566;
        float _1568 = _1565 / _1567;
        float _1569 = 1.0f / resolver_output_params.x;
        float _1570 = abs(_1560);
        float _1571 = abs(_1564);
        float _1572 = abs(_1568);
        float _1573 = log2(_1570);
        float _1574 = log2(_1571);
        float _1575 = log2(_1572);
        float _1576 = _1573 * _1569;
        float _1577 = _1574 * _1569;
        float _1578 = _1575 * _1569;
        float _1579 = exp2(_1576);
        float _1580 = exp2(_1577);
        float _1581 = exp2(_1578);
        float _1582 = 1.0f / resolver_output_params.y;
        float _1583 = _1582 * _1579;
        float _1584 = _1582 * _1580;
        float _1585 = _1582 * _1581;
        float _1586 = _1583 * 1.6604900360107422f;
        float _1587 = mad(-0.5876410007476807f, _1584, _1586);
        float _1588 = mad(-0.07284989953041077f, _1585, _1587);
        float _1589 = _1583 * -0.124549999833107f;
        float _1590 = mad(1.1328999996185303f, _1584, _1589);
        float _1591 = mad(-0.008349419571459293f, _1585, _1590);
        float _1592 = _1583 * -0.018150800839066505f;
        float _1593 = mad(-0.10057900100946426f, _1584, _1592);
        float _1594 = mad(1.1187299489974976f, _1585, _1593);
        _1596 = _1588;
        _1597 = _1591;
        _1598 = _1594;
      } else {
        _1596 = _1475;
        _1597 = _1476;
        _1598 = _1477;
      }
    }
    float _1599 = 1.0f - _1479.w;
    float _1600 = _1596 * _1599;
    float _1601 = _1597 * _1599;
    float _1602 = _1598 * _1599;
    float _1603 = _1600 + _1479.x;
    float _1604 = _1601 + _1479.y;
    float _1605 = _1602 + _1479.z;
    [branch]
    if (_1491) {
      float _1607 = abs(_1603);
      float _1608 = abs(_1604);
      float _1609 = abs(_1605);
      float _1610 = log2(_1607);
      float _1611 = log2(_1608);
      float _1612 = log2(_1609);
      float _1613 = _1610 * resolver_output_params.x;
      float _1614 = _1611 * resolver_output_params.x;
      float _1615 = _1612 * resolver_output_params.x;
      float _1616 = exp2(_1613);
      float _1617 = exp2(_1614);
      float _1618 = exp2(_1615);
      bool _1619 = (_1616 < 0.003100000089034438f);
      if (_1619) {
        float _1621 = _1616 * 12.920000076293945f;
        _1630 = _1621;
      } else {
        float _1623 = abs(_1616);
        float _1624 = log2(_1623);
        float _1625 = _1624 * 0.4166666567325592f;
        float _1626 = exp2(_1625);
        float _1627 = _1626 * 1.0549999475479126f;
        float _1628 = _1627 + -0.054999999701976776f;
        _1630 = _1628;
      }
      bool _1631 = (_1617 < 0.003100000089034438f);
      if (_1631) {
        float _1633 = _1617 * 12.920000076293945f;
        _1642 = _1633;
      } else {
        float _1635 = abs(_1617);
        float _1636 = log2(_1635);
        float _1637 = _1636 * 0.4166666567325592f;
        float _1638 = exp2(_1637);
        float _1639 = _1638 * 1.0549999475479126f;
        float _1640 = _1639 + -0.054999999701976776f;
        _1642 = _1640;
      }
      bool _1643 = (_1618 < 0.003100000089034438f);
      if (_1643) {
        float _1645 = _1618 * 12.920000076293945f;
        _1708 = _1630;
        _1709 = _1642;
        _1710 = _1645;
      } else {
        float _1647 = abs(_1618);
        float _1648 = log2(_1647);
        float _1649 = _1648 * 0.4166666567325592f;
        float _1650 = exp2(_1649);
        float _1651 = _1650 * 1.0549999475479126f;
        float _1652 = _1651 + -0.054999999701976776f;
        _1708 = _1630;
        _1709 = _1642;
        _1710 = _1652;
      }
    } else {
      bool _1654 = (_1490 == 2);
      if (_1654) {
        float _1656 = _1603 * 0.6274039149284363f;
        float _1657 = mad(0.3292830288410187f, _1604, _1656);
        float _1658 = mad(0.04331306740641594f, _1605, _1657);
        float _1659 = _1603 * 0.06909728795289993f;
        float _1660 = mad(0.9195404052734375f, _1604, _1659);
        float _1661 = mad(0.011362316086888313f, _1605, _1660);
        float _1662 = _1603 * 0.016391439363360405f;
        float _1663 = mad(0.08801330626010895f, _1604, _1662);
        float _1664 = mad(0.8955952525138855f, _1605, _1663);
        float _1665 = _1658 * resolver_output_params.y;
        float _1666 = _1661 * resolver_output_params.y;
        float _1667 = _1664 * resolver_output_params.y;
        float _1668 = abs(_1665);
        float _1669 = abs(_1666);
        float _1670 = abs(_1667);
        float _1671 = log2(_1668);
        float _1672 = log2(_1669);
        float _1673 = log2(_1670);
        float _1674 = _1671 * resolver_output_params.x;
        float _1675 = _1672 * resolver_output_params.x;
        float _1676 = _1673 * resolver_output_params.x;
        float _1677 = exp2(_1674);
        float _1678 = exp2(_1675);
        float _1679 = exp2(_1676);
        float _1680 = _1677 * 18.8515625f;
        float _1681 = _1680 + 0.8359375f;
        float _1682 = _1677 * 18.6875f;
        float _1683 = _1682 + 1.0f;
        float _1684 = _1681 / _1683;
        float _1685 = abs(_1684);
        float _1686 = log2(_1685);
        float _1687 = _1686 * 78.84375f;
        float _1688 = exp2(_1687);
        float _1689 = _1678 * 18.8515625f;
        float _1690 = _1689 + 0.8359375f;
        float _1691 = _1678 * 18.6875f;
        float _1692 = _1691 + 1.0f;
        float _1693 = _1690 / _1692;
        float _1694 = abs(_1693);
        float _1695 = log2(_1694);
        float _1696 = _1695 * 78.84375f;
        float _1697 = exp2(_1696);
        float _1698 = _1679 * 18.8515625f;
        float _1699 = _1698 + 0.8359375f;
        float _1700 = _1679 * 18.6875f;
        float _1701 = _1700 + 1.0f;
        float _1702 = _1699 / _1701;
        float _1703 = abs(_1702);
        float _1704 = log2(_1703);
        float _1705 = _1704 * 78.84375f;
        float _1706 = exp2(_1705);
        _1708 = _1688;
        _1709 = _1697;
        _1710 = _1706;
      } else {
        _1708 = _1603;
        _1709 = _1604;
        _1710 = _1605;
      }
    }
    u0_space6[int2(_28, _930)] = float4(_1708, _1709, _1710, 1.0f);
    bool _1712 = (_134 == 0);
    if (!_1712) {
      [branch]
      if (_1491) {
        float _1715 = abs(_1479.x);
        float _1716 = abs(_1479.y);
        float _1717 = abs(_1479.z);
        float _1718 = log2(_1715);
        float _1719 = log2(_1716);
        float _1720 = log2(_1717);
        float _1721 = _1718 * resolver_output_params.x;
        float _1722 = _1719 * resolver_output_params.x;
        float _1723 = _1720 * resolver_output_params.x;
        float _1724 = exp2(_1721);
        float _1725 = exp2(_1722);
        float _1726 = exp2(_1723);
        bool _1727 = (_1724 < 0.003100000089034438f);
        if (_1727) {
          float _1729 = _1724 * 12.920000076293945f;
          _1738 = _1729;
        } else {
          float _1731 = abs(_1724);
          float _1732 = log2(_1731);
          float _1733 = _1732 * 0.4166666567325592f;
          float _1734 = exp2(_1733);
          float _1735 = _1734 * 1.0549999475479126f;
          float _1736 = _1735 + -0.054999999701976776f;
          _1738 = _1736;
        }
        bool _1739 = (_1725 < 0.003100000089034438f);
        if (_1739) {
          float _1741 = _1725 * 12.920000076293945f;
          _1750 = _1741;
        } else {
          float _1743 = abs(_1725);
          float _1744 = log2(_1743);
          float _1745 = _1744 * 0.4166666567325592f;
          float _1746 = exp2(_1745);
          float _1747 = _1746 * 1.0549999475479126f;
          float _1748 = _1747 + -0.054999999701976776f;
          _1750 = _1748;
        }
        bool _1751 = (_1726 < 0.003100000089034438f);
        if (_1751) {
          float _1753 = _1726 * 12.920000076293945f;
          _1816 = _1738;
          _1817 = _1750;
          _1818 = _1753;
        } else {
          float _1755 = abs(_1726);
          float _1756 = log2(_1755);
          float _1757 = _1756 * 0.4166666567325592f;
          float _1758 = exp2(_1757);
          float _1759 = _1758 * 1.0549999475479126f;
          float _1760 = _1759 + -0.054999999701976776f;
          _1816 = _1738;
          _1817 = _1750;
          _1818 = _1760;
        }
      } else {
        bool _1762 = (_1490 == 2);
        if (_1762) {
          float _1764 = _1479.x * 0.6274039149284363f;
          float _1765 = mad(0.3292830288410187f, _1479.y, _1764);
          float _1766 = mad(0.04331306740641594f, _1479.z, _1765);
          float _1767 = _1479.x * 0.06909728795289993f;
          float _1768 = mad(0.9195404052734375f, _1479.y, _1767);
          float _1769 = mad(0.011362316086888313f, _1479.z, _1768);
          float _1770 = _1479.x * 0.016391439363360405f;
          float _1771 = mad(0.08801330626010895f, _1479.y, _1770);
          float _1772 = mad(0.8955952525138855f, _1479.z, _1771);
          float _1773 = _1766 * resolver_output_params.y;
          float _1774 = _1769 * resolver_output_params.y;
          float _1775 = _1772 * resolver_output_params.y;
          float _1776 = abs(_1773);
          float _1777 = abs(_1774);
          float _1778 = abs(_1775);
          float _1779 = log2(_1776);
          float _1780 = log2(_1777);
          float _1781 = log2(_1778);
          float _1782 = _1779 * resolver_output_params.x;
          float _1783 = _1780 * resolver_output_params.x;
          float _1784 = _1781 * resolver_output_params.x;
          float _1785 = exp2(_1782);
          float _1786 = exp2(_1783);
          float _1787 = exp2(_1784);
          float _1788 = _1785 * 18.8515625f;
          float _1789 = _1788 + 0.8359375f;
          float _1790 = _1785 * 18.6875f;
          float _1791 = _1790 + 1.0f;
          float _1792 = _1789 / _1791;
          float _1793 = abs(_1792);
          float _1794 = log2(_1793);
          float _1795 = _1794 * 78.84375f;
          float _1796 = exp2(_1795);
          float _1797 = _1786 * 18.8515625f;
          float _1798 = _1797 + 0.8359375f;
          float _1799 = _1786 * 18.6875f;
          float _1800 = _1799 + 1.0f;
          float _1801 = _1798 / _1800;
          float _1802 = abs(_1801);
          float _1803 = log2(_1802);
          float _1804 = _1803 * 78.84375f;
          float _1805 = exp2(_1804);
          float _1806 = _1787 * 18.8515625f;
          float _1807 = _1806 + 0.8359375f;
          float _1808 = _1787 * 18.6875f;
          float _1809 = _1808 + 1.0f;
          float _1810 = _1807 / _1809;
          float _1811 = abs(_1810);
          float _1812 = log2(_1811);
          float _1813 = _1812 * 78.84375f;
          float _1814 = exp2(_1813);
          _1816 = _1796;
          _1817 = _1805;
          _1818 = _1814;
        } else {
          _1816 = _1479.x;
          _1817 = _1479.y;
          _1818 = _1479.z;
        }
      }
      u1_space6[int2(_28, _930)] = float4(_1816, _1817, _1818, _1479.w);
    }
  } else {
    u0_space6[int2(_28, _930)] = float4(_1475, _1476, _1477, 1.0f);
  }
}

#endif  // SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0XDA5784EF_HLSLI_
