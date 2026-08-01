#ifndef SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0XA0F3AF86_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0XA0F3AF86_HLSLI_

// AA/upscale resolver over the encoded frame: decode -> temporal resolve -> encode.
// Decompiled from the game's DXIL. The RenoDX edits are GetResolverOutputParams and the
// optional RCAS in SelectResolverSharpening; both are documented where they are defined.
//
// Shared by HZDR 0xA0F3AF86 and HFW 0x6127499F: both games ship this program with the same
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
  int _34 = asint(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_000.y);
  min16int _35 = min16int(_32);
  min16int _36 = min16int(_33);
  uint _37 = _36 + -1u;
  float _38 = float((int)(_35));
  float _39 = float((int)(_37));
  float _40 = _38 + 0.5f;
  float _41 = _39 + 0.5f;
  float _42 = _40 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float _43 = _41 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _46 = t0_space6.SampleLevel(s0_space5, float2(_42, _43), 0.0f);
  half _50 = half(_46.x);
  half _51 = half(_46.y);
  half _52 = half(_46.z);
  uint _53 = _35 + -1u;
  float _54 = float((int)(_53));
  float _55 = float((int)(_36));
  float _56 = _54 + 0.5f;
  float _57 = _55 + 0.5f;
  float _58 = _56 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float _59 = _57 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _60 = t0_space6.SampleLevel(s0_space5, float2(_58, _59), 0.0f);
  half _64 = half(_60.x);
  half _65 = half(_60.y);
  half _66 = half(_60.z);
  float4 _67 = t0_space6.SampleLevel(s0_space5, float2(_42, _59), 0.0f);
  half _71 = half(_67.x);
  half _72 = half(_67.y);
  half _73 = half(_67.z);
  int _74 = _35 + 1;
  float _75 = float((int)(_74));
  float _76 = _75 + 0.5f;
  float _77 = _76 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _78 = t0_space6.SampleLevel(s0_space5, float2(_77, _59), 0.0f);
  half _82 = half(_78.x);
  half _83 = half(_78.y);
  half _84 = half(_78.z);
  int _85 = _36 + 1;
  float _86 = float((int)(_85));
  float _87 = _86 + 0.5f;
  float _88 = _87 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _89 = t0_space6.SampleLevel(s0_space5, float2(_42, _88), 0.0f);
  half _93 = half(_89.x);
  half _94 = half(_89.y);
  half _95 = half(_89.z);
  half _96 = min(_64, _82);
  half _97 = min(_50, _96);
  half _98 = min(_97, _93);
  half _99 = min(_65, _83);
  half _100 = min(_51, _99);
  half _101 = min(_100, _94);
  half _102 = min(_66, _84);
  half _103 = min(_52, _102);
  half _104 = min(_103, _95);
  half _105 = max(_64, _82);
  half _106 = max(_50, _105);
  half _107 = max(_106, _93);
  half _108 = max(_65, _83);
  half _109 = max(_51, _108);
  half _110 = max(_109, _94);
  half _111 = max(_66, _84);
  half _112 = max(_52, _111);
  half _113 = max(_112, _95);
  half _114 = 0.25h / _107;
  half _115 = 0.25h / _110;
  half _116 = 0.25h / _113;
  half _117 = 1.0h - _107;
  half _118 = _98 * 4.0h;
  half _119 = _118 + -4.0h;
  half _120 = 1.0h / _119;
  half _121 = _120 * _117;
  half _122 = 1.0h - _110;
  half _123 = _101 * 4.0h;
  half _124 = _123 + -4.0h;
  half _125 = 1.0h / _124;
  half _126 = _125 * _122;
  half _127 = 1.0h - _113;
  half _128 = _104 * 4.0h;
  half _129 = _128 + -4.0h;
  half _130 = 1.0h / _129;
  half _131 = _130 * _127;
  half _132 = _98 * _114;
  half _133 = -0.0h - _132;
  half _134 = max(_133, _121);
  half _135 = _101 * _115;
  half _136 = -0.0h - _135;
  half _137 = max(_136, _126);
  half _138 = _104 * _116;
  half _139 = -0.0h - _138;
  half _140 = max(_139, _131);
  half _141 = max(_137, _140);
  half _142 = max(_134, _141);
  half _143 = min(_142, 0.0h);
  half _144 = max(-0.1875h, _143);
  int _145 = _34 & 65535;
  float _146 = f16tof32(_145);
  half _147 = half(_146);
  half _148 = _147 * _144;
  half _149 = _148 * 4.0h;
  half _150 = _149 + 1.0h;
  float _151 = float(_150);
  uint _152 = f32tof16(_151);
  uint _153 = 30605u - _152;
  int _154 = _153 & 65535;
  float _155 = f16tof32(_154);
  half _156 = half(_155);
  half _157 = _150 * _156;
  half _158 = 2.0h - _157;
  half _159 = _158 * _156;
  half _160 = _64 + _50;
  half _161 = _160 + _82;
  half _162 = _161 + _93;
  half _163 = _148 * _162;
  half _164 = _163 + _71;
  half _165 = _159 * _164;
  half _166 = _65 + _51;
  half _167 = _166 + _83;
  half _168 = _167 + _94;
  half _169 = _148 * _168;
  half _170 = _169 + _72;
  half _171 = _159 * _170;
  half _172 = _66 + _52;
  half _173 = _172 + _84;
  half _174 = _173 + _95;
  half _175 = _148 * _174;
  half _176 = _175 + _73;
  half _177 = _159 * _176;
  const float3 resolver_color_0 = SelectResolverSharpening(
      float3(_165, _171, _177), _46.rgb, _60.rgb, _67.rgb, _78.rgb, _89.rgb,
      resolver_output_params, resolver_normalization_point);
  half _178 = half(resolver_output_params.z);
  half _179 = min(half(resolver_color_0.x), _178);
  half _180 = min(half(resolver_color_0.y), _178);
  half _181 = min(half(resolver_color_0.z), _178);
  int _182 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.x);
  int _183 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_064.y);
  float4 _185 = t1_space6.Load(int3(_32, _33, 0));
  float _190 = max(_185.y, _185.z);
  float _191 = max(_185.x, _190);
  float _192 = _191 + _185.w;
  bool _193 = !(_192 > 0.0f);
  bool _194 = (_183 != 0);
  bool _195 = _194 || _193;
  float _196 = float(_179);
  float _197 = float(_180);
  float _198 = float(_181);
  float _214;
  float _226;
  float _238;
  float _306;
  float _307;
  float _308;
  float _340;
  float _352;
  float _418;
  float _419;
  float _420;
  float _448;
  float _460;
  float _526;
  float _527;
  float _528;
  float _694;
  float _706;
  float _718;
  float _786;
  float _787;
  float _788;
  float _820;
  float _832;
  float _898;
  float _899;
  float _900;
  float _928;
  float _940;
  float _1006;
  float _1007;
  float _1008;
  float _1174;
  float _1186;
  float _1198;
  float _1266;
  float _1267;
  float _1268;
  float _1300;
  float _1312;
  float _1378;
  float _1379;
  float _1380;
  float _1408;
  float _1420;
  float _1486;
  float _1487;
  float _1488;
  float _1641;
  float _1653;
  float _1665;
  float _1733;
  float _1734;
  float _1735;
  float _1767;
  float _1779;
  float _1845;
  float _1846;
  float _1847;
  float _1875;
  float _1887;
  float _1953;
  float _1954;
  float _1955;
  if (!_195) {
    int _200 = int(resolver_output_params.w);
    bool _201 = (_200 == 1);
    [branch]
    if (_201) {
      bool _203 = (_196 < 0.040449999272823334f);
      if (_203) {
        float _205 = _196 * 0.07739938050508499f;
        _214 = _205;
      } else {
        float _207 = _196 * 0.9478672742843628f;
        float _208 = _207 + 0.05213269963860512f;
        float _209 = abs(_208);
        float _210 = log2(_209);
        float _211 = _210 * 2.4000000953674316f;
        float _212 = exp2(_211);
        _214 = _212;
      }
      bool _215 = (_197 < 0.040449999272823334f);
      if (_215) {
        float _217 = _197 * 0.07739938050508499f;
        _226 = _217;
      } else {
        float _219 = _197 * 0.9478672742843628f;
        float _220 = _219 + 0.05213269963860512f;
        float _221 = abs(_220);
        float _222 = log2(_221);
        float _223 = _222 * 2.4000000953674316f;
        float _224 = exp2(_223);
        _226 = _224;
      }
      bool _227 = (_198 < 0.040449999272823334f);
      if (_227) {
        float _229 = _198 * 0.07739938050508499f;
        _238 = _229;
      } else {
        float _231 = _198 * 0.9478672742843628f;
        float _232 = _231 + 0.05213269963860512f;
        float _233 = abs(_232);
        float _234 = log2(_233);
        float _235 = _234 * 2.4000000953674316f;
        float _236 = exp2(_235);
        _238 = _236;
      }
      float _239 = 1.0f / resolver_output_params.x;
      float _240 = abs(_214);
      float _241 = abs(_226);
      float _242 = abs(_238);
      float _243 = log2(_240);
      float _244 = log2(_241);
      float _245 = log2(_242);
      float _246 = _243 * _239;
      float _247 = _244 * _239;
      float _248 = _245 * _239;
      float _249 = exp2(_246);
      float _250 = exp2(_247);
      float _251 = exp2(_248);
      _306 = _249;
      _307 = _250;
      _308 = _251;
    } else {
      bool _253 = (_200 == 2);
      if (_253) {
        float _255 = abs(_196);
        float _256 = abs(_197);
        float _257 = abs(_198);
        float _258 = log2(_255);
        float _259 = log2(_256);
        float _260 = log2(_257);
        float _261 = _258 * 0.012683313339948654f;
        float _262 = _259 * 0.012683313339948654f;
        float _263 = _260 * 0.012683313339948654f;
        float _264 = exp2(_261);
        float _265 = exp2(_262);
        float _266 = exp2(_263);
        float _267 = _264 + -0.8359375f;
        float _268 = _264 * 18.6875f;
        float _269 = 18.8515625f - _268;
        float _270 = _267 / _269;
        float _271 = _265 + -0.8359375f;
        float _272 = _265 * 18.6875f;
        float _273 = 18.8515625f - _272;
        float _274 = _271 / _273;
        float _275 = _266 + -0.8359375f;
        float _276 = _266 * 18.6875f;
        float _277 = 18.8515625f - _276;
        float _278 = _275 / _277;
        float _279 = 1.0f / resolver_output_params.x;
        float _280 = abs(_270);
        float _281 = abs(_274);
        float _282 = abs(_278);
        float _283 = log2(_280);
        float _284 = log2(_281);
        float _285 = log2(_282);
        float _286 = _283 * _279;
        float _287 = _284 * _279;
        float _288 = _285 * _279;
        float _289 = exp2(_286);
        float _290 = exp2(_287);
        float _291 = exp2(_288);
        float _292 = 1.0f / resolver_output_params.y;
        float _293 = _292 * _289;
        float _294 = _292 * _290;
        float _295 = _292 * _291;
        float _296 = _293 * 1.6604900360107422f;
        float _297 = mad(-0.5876410007476807f, _294, _296);
        float _298 = mad(-0.07284989953041077f, _295, _297);
        float _299 = _293 * -0.124549999833107f;
        float _300 = mad(1.1328999996185303f, _294, _299);
        float _301 = mad(-0.008349419571459293f, _295, _300);
        float _302 = _293 * -0.018150800839066505f;
        float _303 = mad(-0.10057900100946426f, _294, _302);
        float _304 = mad(1.1187299489974976f, _295, _303);
        _306 = _298;
        _307 = _301;
        _308 = _304;
      } else {
        _306 = _196;
        _307 = _197;
        _308 = _198;
      }
    }
    float _309 = 1.0f - _185.w;
    float _310 = _306 * _309;
    float _311 = _307 * _309;
    float _312 = _308 * _309;
    float _313 = _310 + _185.x;
    float _314 = _311 + _185.y;
    float _315 = _312 + _185.z;
    [branch]
    if (_201) {
      float _317 = abs(_313);
      float _318 = abs(_314);
      float _319 = abs(_315);
      float _320 = log2(_317);
      float _321 = log2(_318);
      float _322 = log2(_319);
      float _323 = _320 * resolver_output_params.x;
      float _324 = _321 * resolver_output_params.x;
      float _325 = _322 * resolver_output_params.x;
      float _326 = exp2(_323);
      float _327 = exp2(_324);
      float _328 = exp2(_325);
      bool _329 = (_326 < 0.003100000089034438f);
      if (_329) {
        float _331 = _326 * 12.920000076293945f;
        _340 = _331;
      } else {
        float _333 = abs(_326);
        float _334 = log2(_333);
        float _335 = _334 * 0.4166666567325592f;
        float _336 = exp2(_335);
        float _337 = _336 * 1.0549999475479126f;
        float _338 = _337 + -0.054999999701976776f;
        _340 = _338;
      }
      bool _341 = (_327 < 0.003100000089034438f);
      if (_341) {
        float _343 = _327 * 12.920000076293945f;
        _352 = _343;
      } else {
        float _345 = abs(_327);
        float _346 = log2(_345);
        float _347 = _346 * 0.4166666567325592f;
        float _348 = exp2(_347);
        float _349 = _348 * 1.0549999475479126f;
        float _350 = _349 + -0.054999999701976776f;
        _352 = _350;
      }
      bool _353 = (_328 < 0.003100000089034438f);
      if (_353) {
        float _355 = _328 * 12.920000076293945f;
        _418 = _340;
        _419 = _352;
        _420 = _355;
      } else {
        float _357 = abs(_328);
        float _358 = log2(_357);
        float _359 = _358 * 0.4166666567325592f;
        float _360 = exp2(_359);
        float _361 = _360 * 1.0549999475479126f;
        float _362 = _361 + -0.054999999701976776f;
        _418 = _340;
        _419 = _352;
        _420 = _362;
      }
    } else {
      bool _364 = (_200 == 2);
      if (_364) {
        float _366 = _313 * 0.6274039149284363f;
        float _367 = mad(0.3292830288410187f, _314, _366);
        float _368 = mad(0.04331306740641594f, _315, _367);
        float _369 = _313 * 0.06909728795289993f;
        float _370 = mad(0.9195404052734375f, _314, _369);
        float _371 = mad(0.011362316086888313f, _315, _370);
        float _372 = _313 * 0.016391439363360405f;
        float _373 = mad(0.08801330626010895f, _314, _372);
        float _374 = mad(0.8955952525138855f, _315, _373);
        float _375 = _368 * resolver_output_params.y;
        float _376 = _371 * resolver_output_params.y;
        float _377 = _374 * resolver_output_params.y;
        float _378 = abs(_375);
        float _379 = abs(_376);
        float _380 = abs(_377);
        float _381 = log2(_378);
        float _382 = log2(_379);
        float _383 = log2(_380);
        float _384 = _381 * resolver_output_params.x;
        float _385 = _382 * resolver_output_params.x;
        float _386 = _383 * resolver_output_params.x;
        float _387 = exp2(_384);
        float _388 = exp2(_385);
        float _389 = exp2(_386);
        float _390 = _387 * 18.8515625f;
        float _391 = _390 + 0.8359375f;
        float _392 = _387 * 18.6875f;
        float _393 = _392 + 1.0f;
        float _394 = _391 / _393;
        float _395 = abs(_394);
        float _396 = log2(_395);
        float _397 = _396 * 78.84375f;
        float _398 = exp2(_397);
        float _399 = _388 * 18.8515625f;
        float _400 = _399 + 0.8359375f;
        float _401 = _388 * 18.6875f;
        float _402 = _401 + 1.0f;
        float _403 = _400 / _402;
        float _404 = abs(_403);
        float _405 = log2(_404);
        float _406 = _405 * 78.84375f;
        float _407 = exp2(_406);
        float _408 = _389 * 18.8515625f;
        float _409 = _408 + 0.8359375f;
        float _410 = _389 * 18.6875f;
        float _411 = _410 + 1.0f;
        float _412 = _409 / _411;
        float _413 = abs(_412);
        float _414 = log2(_413);
        float _415 = _414 * 78.84375f;
        float _416 = exp2(_415);
        _418 = _398;
        _419 = _407;
        _420 = _416;
      } else {
        _418 = _313;
        _419 = _314;
        _420 = _315;
      }
    }
    u0_space6[int2(_32, _33)] = float4(_418, _419, _420, 1.0f);
    bool _422 = (_182 == 0);
    if (!_422) {
      [branch]
      if (_201) {
        float _425 = abs(_185.x);
        float _426 = abs(_185.y);
        float _427 = abs(_185.z);
        float _428 = log2(_425);
        float _429 = log2(_426);
        float _430 = log2(_427);
        float _431 = _428 * resolver_output_params.x;
        float _432 = _429 * resolver_output_params.x;
        float _433 = _430 * resolver_output_params.x;
        float _434 = exp2(_431);
        float _435 = exp2(_432);
        float _436 = exp2(_433);
        bool _437 = (_434 < 0.003100000089034438f);
        if (_437) {
          float _439 = _434 * 12.920000076293945f;
          _448 = _439;
        } else {
          float _441 = abs(_434);
          float _442 = log2(_441);
          float _443 = _442 * 0.4166666567325592f;
          float _444 = exp2(_443);
          float _445 = _444 * 1.0549999475479126f;
          float _446 = _445 + -0.054999999701976776f;
          _448 = _446;
        }
        bool _449 = (_435 < 0.003100000089034438f);
        if (_449) {
          float _451 = _435 * 12.920000076293945f;
          _460 = _451;
        } else {
          float _453 = abs(_435);
          float _454 = log2(_453);
          float _455 = _454 * 0.4166666567325592f;
          float _456 = exp2(_455);
          float _457 = _456 * 1.0549999475479126f;
          float _458 = _457 + -0.054999999701976776f;
          _460 = _458;
        }
        bool _461 = (_436 < 0.003100000089034438f);
        if (_461) {
          float _463 = _436 * 12.920000076293945f;
          _526 = _448;
          _527 = _460;
          _528 = _463;
        } else {
          float _465 = abs(_436);
          float _466 = log2(_465);
          float _467 = _466 * 0.4166666567325592f;
          float _468 = exp2(_467);
          float _469 = _468 * 1.0549999475479126f;
          float _470 = _469 + -0.054999999701976776f;
          _526 = _448;
          _527 = _460;
          _528 = _470;
        }
      } else {
        bool _472 = (_200 == 2);
        if (_472) {
          float _474 = _185.x * 0.6274039149284363f;
          float _475 = mad(0.3292830288410187f, _185.y, _474);
          float _476 = mad(0.04331306740641594f, _185.z, _475);
          float _477 = _185.x * 0.06909728795289993f;
          float _478 = mad(0.9195404052734375f, _185.y, _477);
          float _479 = mad(0.011362316086888313f, _185.z, _478);
          float _480 = _185.x * 0.016391439363360405f;
          float _481 = mad(0.08801330626010895f, _185.y, _480);
          float _482 = mad(0.8955952525138855f, _185.z, _481);
          float _483 = _476 * resolver_output_params.y;
          float _484 = _479 * resolver_output_params.y;
          float _485 = _482 * resolver_output_params.y;
          float _486 = abs(_483);
          float _487 = abs(_484);
          float _488 = abs(_485);
          float _489 = log2(_486);
          float _490 = log2(_487);
          float _491 = log2(_488);
          float _492 = _489 * resolver_output_params.x;
          float _493 = _490 * resolver_output_params.x;
          float _494 = _491 * resolver_output_params.x;
          float _495 = exp2(_492);
          float _496 = exp2(_493);
          float _497 = exp2(_494);
          float _498 = _495 * 18.8515625f;
          float _499 = _498 + 0.8359375f;
          float _500 = _495 * 18.6875f;
          float _501 = _500 + 1.0f;
          float _502 = _499 / _501;
          float _503 = abs(_502);
          float _504 = log2(_503);
          float _505 = _504 * 78.84375f;
          float _506 = exp2(_505);
          float _507 = _496 * 18.8515625f;
          float _508 = _507 + 0.8359375f;
          float _509 = _496 * 18.6875f;
          float _510 = _509 + 1.0f;
          float _511 = _508 / _510;
          float _512 = abs(_511);
          float _513 = log2(_512);
          float _514 = _513 * 78.84375f;
          float _515 = exp2(_514);
          float _516 = _497 * 18.8515625f;
          float _517 = _516 + 0.8359375f;
          float _518 = _497 * 18.6875f;
          float _519 = _518 + 1.0f;
          float _520 = _517 / _519;
          float _521 = abs(_520);
          float _522 = log2(_521);
          float _523 = _522 * 78.84375f;
          float _524 = exp2(_523);
          _526 = _506;
          _527 = _515;
          _528 = _524;
        } else {
          _526 = _185.x;
          _527 = _185.y;
          _528 = _185.z;
        }
      }
      u1_space6[int2(_32, _33)] = float4(_526, _527, _528, _185.w);
    }
  } else {
    u0_space6[int2(_32, _33)] = float4(_196, _197, _198, 1.0f);
  }
  int _533 = _32 | 8;
  min16int _534 = min16int(_533);
  float _535 = float((int)(_534));
  float _536 = _535 + 0.5f;
  float _537 = _536 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _540 = t0_space6.SampleLevel(s0_space5, float2(_537, _43), 0.0f);
  half _544 = half(_540.x);
  half _545 = half(_540.y);
  half _546 = half(_540.z);
  uint _547 = _534 + -1u;
  float _548 = float((int)(_547));
  float _549 = _548 + 0.5f;
  float _550 = _549 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _551 = t0_space6.SampleLevel(s0_space5, float2(_550, _59), 0.0f);
  half _555 = half(_551.x);
  half _556 = half(_551.y);
  half _557 = half(_551.z);
  float4 _558 = t0_space6.SampleLevel(s0_space5, float2(_537, _59), 0.0f);
  half _562 = half(_558.x);
  half _563 = half(_558.y);
  half _564 = half(_558.z);
  uint _565 = _534 + 1u;
  float _566 = float((int)(_565));
  float _567 = _566 + 0.5f;
  float _568 = _567 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.x;
  float4 _569 = t0_space6.SampleLevel(s0_space5, float2(_568, _59), 0.0f);
  half _573 = half(_569.x);
  half _574 = half(_569.y);
  half _575 = half(_569.z);
  float4 _576 = t0_space6.SampleLevel(s0_space5, float2(_537, _88), 0.0f);
  half _580 = half(_576.x);
  half _581 = half(_576.y);
  half _582 = half(_576.z);
  half _583 = min(_555, _573);
  half _584 = min(_544, _583);
  half _585 = min(_584, _580);
  half _586 = min(_556, _574);
  half _587 = min(_545, _586);
  half _588 = min(_587, _581);
  half _589 = min(_557, _575);
  half _590 = min(_546, _589);
  half _591 = min(_590, _582);
  half _592 = max(_555, _573);
  half _593 = max(_544, _592);
  half _594 = max(_593, _580);
  half _595 = max(_556, _574);
  half _596 = max(_545, _595);
  half _597 = max(_596, _581);
  half _598 = max(_557, _575);
  half _599 = max(_546, _598);
  half _600 = max(_599, _582);
  half _601 = 0.25h / _594;
  half _602 = 0.25h / _597;
  half _603 = 0.25h / _600;
  half _604 = 1.0h - _594;
  half _605 = _585 * 4.0h;
  half _606 = _605 + -4.0h;
  half _607 = 1.0h / _606;
  half _608 = _607 * _604;
  half _609 = 1.0h - _597;
  half _610 = _588 * 4.0h;
  half _611 = _610 + -4.0h;
  half _612 = 1.0h / _611;
  half _613 = _612 * _609;
  half _614 = 1.0h - _600;
  half _615 = _591 * 4.0h;
  half _616 = _615 + -4.0h;
  half _617 = 1.0h / _616;
  half _618 = _617 * _614;
  half _619 = _585 * _601;
  half _620 = -0.0h - _619;
  half _621 = max(_620, _608);
  half _622 = _588 * _602;
  half _623 = -0.0h - _622;
  half _624 = max(_623, _613);
  half _625 = _591 * _603;
  half _626 = -0.0h - _625;
  half _627 = max(_626, _618);
  half _628 = max(_624, _627);
  half _629 = max(_621, _628);
  half _630 = min(_629, 0.0h);
  half _631 = max(-0.1875h, _630);
  half _632 = _147 * _631;
  half _633 = _632 * 4.0h;
  half _634 = _633 + 1.0h;
  float _635 = float(_634);
  uint _636 = f32tof16(_635);
  uint _637 = 30605u - _636;
  int _638 = _637 & 65535;
  float _639 = f16tof32(_638);
  half _640 = half(_639);
  half _641 = _634 * _640;
  half _642 = 2.0h - _641;
  half _643 = _642 * _640;
  half _644 = _555 + _544;
  half _645 = _644 + _573;
  half _646 = _645 + _580;
  half _647 = _632 * _646;
  half _648 = _647 + _562;
  half _649 = _643 * _648;
  half _650 = _556 + _545;
  half _651 = _650 + _574;
  half _652 = _651 + _581;
  half _653 = _632 * _652;
  half _654 = _653 + _563;
  half _655 = _643 * _654;
  half _656 = _557 + _546;
  half _657 = _656 + _575;
  half _658 = _657 + _582;
  half _659 = _632 * _658;
  half _660 = _659 + _564;
  half _661 = _643 * _660;
  const float3 resolver_color_1 = SelectResolverSharpening(
      float3(_649, _655, _661), _540.rgb, _551.rgb, _558.rgb, _569.rgb, _576.rgb,
      resolver_output_params, resolver_normalization_point);
  half _662 = min(half(resolver_color_1.x), _178);
  half _663 = min(half(resolver_color_1.y), _178);
  half _664 = min(half(resolver_color_1.z), _178);
  float4 _666 = t1_space6.Load(int3(_533, _33, 0));
  float _671 = max(_666.y, _666.z);
  float _672 = max(_666.x, _671);
  float _673 = _672 + _666.w;
  bool _674 = !(_673 > 0.0f);
  bool _675 = _194 || _674;
  float _676 = float(_662);
  float _677 = float(_663);
  float _678 = float(_664);
  if (!_675) {
    int _680 = int(resolver_output_params.w);
    bool _681 = (_680 == 1);
    [branch]
    if (_681) {
      bool _683 = (_676 < 0.040449999272823334f);
      if (_683) {
        float _685 = _676 * 0.07739938050508499f;
        _694 = _685;
      } else {
        float _687 = _676 * 0.9478672742843628f;
        float _688 = _687 + 0.05213269963860512f;
        float _689 = abs(_688);
        float _690 = log2(_689);
        float _691 = _690 * 2.4000000953674316f;
        float _692 = exp2(_691);
        _694 = _692;
      }
      bool _695 = (_677 < 0.040449999272823334f);
      if (_695) {
        float _697 = _677 * 0.07739938050508499f;
        _706 = _697;
      } else {
        float _699 = _677 * 0.9478672742843628f;
        float _700 = _699 + 0.05213269963860512f;
        float _701 = abs(_700);
        float _702 = log2(_701);
        float _703 = _702 * 2.4000000953674316f;
        float _704 = exp2(_703);
        _706 = _704;
      }
      bool _707 = (_678 < 0.040449999272823334f);
      if (_707) {
        float _709 = _678 * 0.07739938050508499f;
        _718 = _709;
      } else {
        float _711 = _678 * 0.9478672742843628f;
        float _712 = _711 + 0.05213269963860512f;
        float _713 = abs(_712);
        float _714 = log2(_713);
        float _715 = _714 * 2.4000000953674316f;
        float _716 = exp2(_715);
        _718 = _716;
      }
      float _719 = 1.0f / resolver_output_params.x;
      float _720 = abs(_694);
      float _721 = abs(_706);
      float _722 = abs(_718);
      float _723 = log2(_720);
      float _724 = log2(_721);
      float _725 = log2(_722);
      float _726 = _723 * _719;
      float _727 = _724 * _719;
      float _728 = _725 * _719;
      float _729 = exp2(_726);
      float _730 = exp2(_727);
      float _731 = exp2(_728);
      _786 = _729;
      _787 = _730;
      _788 = _731;
    } else {
      bool _733 = (_680 == 2);
      if (_733) {
        float _735 = abs(_676);
        float _736 = abs(_677);
        float _737 = abs(_678);
        float _738 = log2(_735);
        float _739 = log2(_736);
        float _740 = log2(_737);
        float _741 = _738 * 0.012683313339948654f;
        float _742 = _739 * 0.012683313339948654f;
        float _743 = _740 * 0.012683313339948654f;
        float _744 = exp2(_741);
        float _745 = exp2(_742);
        float _746 = exp2(_743);
        float _747 = _744 + -0.8359375f;
        float _748 = _744 * 18.6875f;
        float _749 = 18.8515625f - _748;
        float _750 = _747 / _749;
        float _751 = _745 + -0.8359375f;
        float _752 = _745 * 18.6875f;
        float _753 = 18.8515625f - _752;
        float _754 = _751 / _753;
        float _755 = _746 + -0.8359375f;
        float _756 = _746 * 18.6875f;
        float _757 = 18.8515625f - _756;
        float _758 = _755 / _757;
        float _759 = 1.0f / resolver_output_params.x;
        float _760 = abs(_750);
        float _761 = abs(_754);
        float _762 = abs(_758);
        float _763 = log2(_760);
        float _764 = log2(_761);
        float _765 = log2(_762);
        float _766 = _763 * _759;
        float _767 = _764 * _759;
        float _768 = _765 * _759;
        float _769 = exp2(_766);
        float _770 = exp2(_767);
        float _771 = exp2(_768);
        float _772 = 1.0f / resolver_output_params.y;
        float _773 = _772 * _769;
        float _774 = _772 * _770;
        float _775 = _772 * _771;
        float _776 = _773 * 1.6604900360107422f;
        float _777 = mad(-0.5876410007476807f, _774, _776);
        float _778 = mad(-0.07284989953041077f, _775, _777);
        float _779 = _773 * -0.124549999833107f;
        float _780 = mad(1.1328999996185303f, _774, _779);
        float _781 = mad(-0.008349419571459293f, _775, _780);
        float _782 = _773 * -0.018150800839066505f;
        float _783 = mad(-0.10057900100946426f, _774, _782);
        float _784 = mad(1.1187299489974976f, _775, _783);
        _786 = _778;
        _787 = _781;
        _788 = _784;
      } else {
        _786 = _676;
        _787 = _677;
        _788 = _678;
      }
    }
    float _789 = 1.0f - _666.w;
    float _790 = _786 * _789;
    float _791 = _787 * _789;
    float _792 = _788 * _789;
    float _793 = _790 + _666.x;
    float _794 = _791 + _666.y;
    float _795 = _792 + _666.z;
    [branch]
    if (_681) {
      float _797 = abs(_793);
      float _798 = abs(_794);
      float _799 = abs(_795);
      float _800 = log2(_797);
      float _801 = log2(_798);
      float _802 = log2(_799);
      float _803 = _800 * resolver_output_params.x;
      float _804 = _801 * resolver_output_params.x;
      float _805 = _802 * resolver_output_params.x;
      float _806 = exp2(_803);
      float _807 = exp2(_804);
      float _808 = exp2(_805);
      bool _809 = (_806 < 0.003100000089034438f);
      if (_809) {
        float _811 = _806 * 12.920000076293945f;
        _820 = _811;
      } else {
        float _813 = abs(_806);
        float _814 = log2(_813);
        float _815 = _814 * 0.4166666567325592f;
        float _816 = exp2(_815);
        float _817 = _816 * 1.0549999475479126f;
        float _818 = _817 + -0.054999999701976776f;
        _820 = _818;
      }
      bool _821 = (_807 < 0.003100000089034438f);
      if (_821) {
        float _823 = _807 * 12.920000076293945f;
        _832 = _823;
      } else {
        float _825 = abs(_807);
        float _826 = log2(_825);
        float _827 = _826 * 0.4166666567325592f;
        float _828 = exp2(_827);
        float _829 = _828 * 1.0549999475479126f;
        float _830 = _829 + -0.054999999701976776f;
        _832 = _830;
      }
      bool _833 = (_808 < 0.003100000089034438f);
      if (_833) {
        float _835 = _808 * 12.920000076293945f;
        _898 = _820;
        _899 = _832;
        _900 = _835;
      } else {
        float _837 = abs(_808);
        float _838 = log2(_837);
        float _839 = _838 * 0.4166666567325592f;
        float _840 = exp2(_839);
        float _841 = _840 * 1.0549999475479126f;
        float _842 = _841 + -0.054999999701976776f;
        _898 = _820;
        _899 = _832;
        _900 = _842;
      }
    } else {
      bool _844 = (_680 == 2);
      if (_844) {
        float _846 = _793 * 0.6274039149284363f;
        float _847 = mad(0.3292830288410187f, _794, _846);
        float _848 = mad(0.04331306740641594f, _795, _847);
        float _849 = _793 * 0.06909728795289993f;
        float _850 = mad(0.9195404052734375f, _794, _849);
        float _851 = mad(0.011362316086888313f, _795, _850);
        float _852 = _793 * 0.016391439363360405f;
        float _853 = mad(0.08801330626010895f, _794, _852);
        float _854 = mad(0.8955952525138855f, _795, _853);
        float _855 = _848 * resolver_output_params.y;
        float _856 = _851 * resolver_output_params.y;
        float _857 = _854 * resolver_output_params.y;
        float _858 = abs(_855);
        float _859 = abs(_856);
        float _860 = abs(_857);
        float _861 = log2(_858);
        float _862 = log2(_859);
        float _863 = log2(_860);
        float _864 = _861 * resolver_output_params.x;
        float _865 = _862 * resolver_output_params.x;
        float _866 = _863 * resolver_output_params.x;
        float _867 = exp2(_864);
        float _868 = exp2(_865);
        float _869 = exp2(_866);
        float _870 = _867 * 18.8515625f;
        float _871 = _870 + 0.8359375f;
        float _872 = _867 * 18.6875f;
        float _873 = _872 + 1.0f;
        float _874 = _871 / _873;
        float _875 = abs(_874);
        float _876 = log2(_875);
        float _877 = _876 * 78.84375f;
        float _878 = exp2(_877);
        float _879 = _868 * 18.8515625f;
        float _880 = _879 + 0.8359375f;
        float _881 = _868 * 18.6875f;
        float _882 = _881 + 1.0f;
        float _883 = _880 / _882;
        float _884 = abs(_883);
        float _885 = log2(_884);
        float _886 = _885 * 78.84375f;
        float _887 = exp2(_886);
        float _888 = _869 * 18.8515625f;
        float _889 = _888 + 0.8359375f;
        float _890 = _869 * 18.6875f;
        float _891 = _890 + 1.0f;
        float _892 = _889 / _891;
        float _893 = abs(_892);
        float _894 = log2(_893);
        float _895 = _894 * 78.84375f;
        float _896 = exp2(_895);
        _898 = _878;
        _899 = _887;
        _900 = _896;
      } else {
        _898 = _793;
        _899 = _794;
        _900 = _795;
      }
    }
    u0_space6[int2(_533, _33)] = float4(_898, _899, _900, 1.0f);
    bool _902 = (_182 == 0);
    if (!_902) {
      [branch]
      if (_681) {
        float _905 = abs(_666.x);
        float _906 = abs(_666.y);
        float _907 = abs(_666.z);
        float _908 = log2(_905);
        float _909 = log2(_906);
        float _910 = log2(_907);
        float _911 = _908 * resolver_output_params.x;
        float _912 = _909 * resolver_output_params.x;
        float _913 = _910 * resolver_output_params.x;
        float _914 = exp2(_911);
        float _915 = exp2(_912);
        float _916 = exp2(_913);
        bool _917 = (_914 < 0.003100000089034438f);
        if (_917) {
          float _919 = _914 * 12.920000076293945f;
          _928 = _919;
        } else {
          float _921 = abs(_914);
          float _922 = log2(_921);
          float _923 = _922 * 0.4166666567325592f;
          float _924 = exp2(_923);
          float _925 = _924 * 1.0549999475479126f;
          float _926 = _925 + -0.054999999701976776f;
          _928 = _926;
        }
        bool _929 = (_915 < 0.003100000089034438f);
        if (_929) {
          float _931 = _915 * 12.920000076293945f;
          _940 = _931;
        } else {
          float _933 = abs(_915);
          float _934 = log2(_933);
          float _935 = _934 * 0.4166666567325592f;
          float _936 = exp2(_935);
          float _937 = _936 * 1.0549999475479126f;
          float _938 = _937 + -0.054999999701976776f;
          _940 = _938;
        }
        bool _941 = (_916 < 0.003100000089034438f);
        if (_941) {
          float _943 = _916 * 12.920000076293945f;
          _1006 = _928;
          _1007 = _940;
          _1008 = _943;
        } else {
          float _945 = abs(_916);
          float _946 = log2(_945);
          float _947 = _946 * 0.4166666567325592f;
          float _948 = exp2(_947);
          float _949 = _948 * 1.0549999475479126f;
          float _950 = _949 + -0.054999999701976776f;
          _1006 = _928;
          _1007 = _940;
          _1008 = _950;
        }
      } else {
        bool _952 = (_680 == 2);
        if (_952) {
          float _954 = _666.x * 0.6274039149284363f;
          float _955 = mad(0.3292830288410187f, _666.y, _954);
          float _956 = mad(0.04331306740641594f, _666.z, _955);
          float _957 = _666.x * 0.06909728795289993f;
          float _958 = mad(0.9195404052734375f, _666.y, _957);
          float _959 = mad(0.011362316086888313f, _666.z, _958);
          float _960 = _666.x * 0.016391439363360405f;
          float _961 = mad(0.08801330626010895f, _666.y, _960);
          float _962 = mad(0.8955952525138855f, _666.z, _961);
          float _963 = _956 * resolver_output_params.y;
          float _964 = _959 * resolver_output_params.y;
          float _965 = _962 * resolver_output_params.y;
          float _966 = abs(_963);
          float _967 = abs(_964);
          float _968 = abs(_965);
          float _969 = log2(_966);
          float _970 = log2(_967);
          float _971 = log2(_968);
          float _972 = _969 * resolver_output_params.x;
          float _973 = _970 * resolver_output_params.x;
          float _974 = _971 * resolver_output_params.x;
          float _975 = exp2(_972);
          float _976 = exp2(_973);
          float _977 = exp2(_974);
          float _978 = _975 * 18.8515625f;
          float _979 = _978 + 0.8359375f;
          float _980 = _975 * 18.6875f;
          float _981 = _980 + 1.0f;
          float _982 = _979 / _981;
          float _983 = abs(_982);
          float _984 = log2(_983);
          float _985 = _984 * 78.84375f;
          float _986 = exp2(_985);
          float _987 = _976 * 18.8515625f;
          float _988 = _987 + 0.8359375f;
          float _989 = _976 * 18.6875f;
          float _990 = _989 + 1.0f;
          float _991 = _988 / _990;
          float _992 = abs(_991);
          float _993 = log2(_992);
          float _994 = _993 * 78.84375f;
          float _995 = exp2(_994);
          float _996 = _977 * 18.8515625f;
          float _997 = _996 + 0.8359375f;
          float _998 = _977 * 18.6875f;
          float _999 = _998 + 1.0f;
          float _1000 = _997 / _999;
          float _1001 = abs(_1000);
          float _1002 = log2(_1001);
          float _1003 = _1002 * 78.84375f;
          float _1004 = exp2(_1003);
          _1006 = _986;
          _1007 = _995;
          _1008 = _1004;
        } else {
          _1006 = _666.x;
          _1007 = _666.y;
          _1008 = _666.z;
        }
      }
      u1_space6[int2(_533, _33)] = float4(_1006, _1007, _1008, _666.w);
    }
  } else {
    u0_space6[int2(_533, _33)] = float4(_676, _677, _678, 1.0f);
  }
  int _1013 = _33 | 8;
  min16int _1014 = min16int(_1013);
  uint _1015 = _1014 + -1u;
  float _1016 = float((int)(_1015));
  float _1017 = _1016 + 0.5f;
  float _1018 = _1017 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _1021 = t0_space6.SampleLevel(s0_space5, float2(_537, _1018), 0.0f);
  half _1025 = half(_1021.x);
  half _1026 = half(_1021.y);
  half _1027 = half(_1021.z);
  float _1028 = float((int)(_1014));
  float _1029 = _1028 + 0.5f;
  float _1030 = _1029 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _1031 = t0_space6.SampleLevel(s0_space5, float2(_550, _1030), 0.0f);
  half _1035 = half(_1031.x);
  half _1036 = half(_1031.y);
  half _1037 = half(_1031.z);
  float4 _1038 = t0_space6.SampleLevel(s0_space5, float2(_537, _1030), 0.0f);
  half _1042 = half(_1038.x);
  half _1043 = half(_1038.y);
  half _1044 = half(_1038.z);
  float4 _1045 = t0_space6.SampleLevel(s0_space5, float2(_568, _1030), 0.0f);
  half _1049 = half(_1045.x);
  half _1050 = half(_1045.y);
  half _1051 = half(_1045.z);
  uint _1052 = _1014 + 1u;
  float _1053 = float((int)(_1052));
  float _1054 = _1053 + 0.5f;
  float _1055 = _1054 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.AAResolverUpscaleParams_Constant_016.y;
  float4 _1056 = t0_space6.SampleLevel(s0_space5, float2(_537, _1055), 0.0f);
  half _1060 = half(_1056.x);
  half _1061 = half(_1056.y);
  half _1062 = half(_1056.z);
  half _1063 = min(_1035, _1049);
  half _1064 = min(_1025, _1063);
  half _1065 = min(_1064, _1060);
  half _1066 = min(_1036, _1050);
  half _1067 = min(_1026, _1066);
  half _1068 = min(_1067, _1061);
  half _1069 = min(_1037, _1051);
  half _1070 = min(_1027, _1069);
  half _1071 = min(_1070, _1062);
  half _1072 = max(_1035, _1049);
  half _1073 = max(_1025, _1072);
  half _1074 = max(_1073, _1060);
  half _1075 = max(_1036, _1050);
  half _1076 = max(_1026, _1075);
  half _1077 = max(_1076, _1061);
  half _1078 = max(_1037, _1051);
  half _1079 = max(_1027, _1078);
  half _1080 = max(_1079, _1062);
  half _1081 = 0.25h / _1074;
  half _1082 = 0.25h / _1077;
  half _1083 = 0.25h / _1080;
  half _1084 = 1.0h - _1074;
  half _1085 = _1065 * 4.0h;
  half _1086 = _1085 + -4.0h;
  half _1087 = 1.0h / _1086;
  half _1088 = _1087 * _1084;
  half _1089 = 1.0h - _1077;
  half _1090 = _1068 * 4.0h;
  half _1091 = _1090 + -4.0h;
  half _1092 = 1.0h / _1091;
  half _1093 = _1092 * _1089;
  half _1094 = 1.0h - _1080;
  half _1095 = _1071 * 4.0h;
  half _1096 = _1095 + -4.0h;
  half _1097 = 1.0h / _1096;
  half _1098 = _1097 * _1094;
  half _1099 = _1065 * _1081;
  half _1100 = -0.0h - _1099;
  half _1101 = max(_1100, _1088);
  half _1102 = _1068 * _1082;
  half _1103 = -0.0h - _1102;
  half _1104 = max(_1103, _1093);
  half _1105 = _1071 * _1083;
  half _1106 = -0.0h - _1105;
  half _1107 = max(_1106, _1098);
  half _1108 = max(_1104, _1107);
  half _1109 = max(_1101, _1108);
  half _1110 = min(_1109, 0.0h);
  half _1111 = max(-0.1875h, _1110);
  half _1112 = _147 * _1111;
  half _1113 = _1112 * 4.0h;
  half _1114 = _1113 + 1.0h;
  float _1115 = float(_1114);
  uint _1116 = f32tof16(_1115);
  uint _1117 = 30605u - _1116;
  int _1118 = _1117 & 65535;
  float _1119 = f16tof32(_1118);
  half _1120 = half(_1119);
  half _1121 = _1114 * _1120;
  half _1122 = 2.0h - _1121;
  half _1123 = _1122 * _1120;
  half _1124 = _1035 + _1025;
  half _1125 = _1124 + _1049;
  half _1126 = _1125 + _1060;
  half _1127 = _1112 * _1126;
  half _1128 = _1127 + _1042;
  half _1129 = _1123 * _1128;
  half _1130 = _1036 + _1026;
  half _1131 = _1130 + _1050;
  half _1132 = _1131 + _1061;
  half _1133 = _1112 * _1132;
  half _1134 = _1133 + _1043;
  half _1135 = _1123 * _1134;
  half _1136 = _1037 + _1027;
  half _1137 = _1136 + _1051;
  half _1138 = _1137 + _1062;
  half _1139 = _1112 * _1138;
  half _1140 = _1139 + _1044;
  half _1141 = _1123 * _1140;
  const float3 resolver_color_2 = SelectResolverSharpening(
      float3(_1129, _1135, _1141), _1021.rgb, _1031.rgb, _1038.rgb, _1045.rgb, _1056.rgb,
      resolver_output_params, resolver_normalization_point);
  half _1142 = min(half(resolver_color_2.x), _178);
  half _1143 = min(half(resolver_color_2.y), _178);
  half _1144 = min(half(resolver_color_2.z), _178);
  float4 _1146 = t1_space6.Load(int3(_533, _1013, 0));
  float _1151 = max(_1146.y, _1146.z);
  float _1152 = max(_1146.x, _1151);
  float _1153 = _1152 + _1146.w;
  bool _1154 = !(_1153 > 0.0f);
  bool _1155 = _194 || _1154;
  float _1156 = float(_1142);
  float _1157 = float(_1143);
  float _1158 = float(_1144);
  if (!_1155) {
    int _1160 = int(resolver_output_params.w);
    bool _1161 = (_1160 == 1);
    [branch]
    if (_1161) {
      bool _1163 = (_1156 < 0.040449999272823334f);
      if (_1163) {
        float _1165 = _1156 * 0.07739938050508499f;
        _1174 = _1165;
      } else {
        float _1167 = _1156 * 0.9478672742843628f;
        float _1168 = _1167 + 0.05213269963860512f;
        float _1169 = abs(_1168);
        float _1170 = log2(_1169);
        float _1171 = _1170 * 2.4000000953674316f;
        float _1172 = exp2(_1171);
        _1174 = _1172;
      }
      bool _1175 = (_1157 < 0.040449999272823334f);
      if (_1175) {
        float _1177 = _1157 * 0.07739938050508499f;
        _1186 = _1177;
      } else {
        float _1179 = _1157 * 0.9478672742843628f;
        float _1180 = _1179 + 0.05213269963860512f;
        float _1181 = abs(_1180);
        float _1182 = log2(_1181);
        float _1183 = _1182 * 2.4000000953674316f;
        float _1184 = exp2(_1183);
        _1186 = _1184;
      }
      bool _1187 = (_1158 < 0.040449999272823334f);
      if (_1187) {
        float _1189 = _1158 * 0.07739938050508499f;
        _1198 = _1189;
      } else {
        float _1191 = _1158 * 0.9478672742843628f;
        float _1192 = _1191 + 0.05213269963860512f;
        float _1193 = abs(_1192);
        float _1194 = log2(_1193);
        float _1195 = _1194 * 2.4000000953674316f;
        float _1196 = exp2(_1195);
        _1198 = _1196;
      }
      float _1199 = 1.0f / resolver_output_params.x;
      float _1200 = abs(_1174);
      float _1201 = abs(_1186);
      float _1202 = abs(_1198);
      float _1203 = log2(_1200);
      float _1204 = log2(_1201);
      float _1205 = log2(_1202);
      float _1206 = _1203 * _1199;
      float _1207 = _1204 * _1199;
      float _1208 = _1205 * _1199;
      float _1209 = exp2(_1206);
      float _1210 = exp2(_1207);
      float _1211 = exp2(_1208);
      _1266 = _1209;
      _1267 = _1210;
      _1268 = _1211;
    } else {
      bool _1213 = (_1160 == 2);
      if (_1213) {
        float _1215 = abs(_1156);
        float _1216 = abs(_1157);
        float _1217 = abs(_1158);
        float _1218 = log2(_1215);
        float _1219 = log2(_1216);
        float _1220 = log2(_1217);
        float _1221 = _1218 * 0.012683313339948654f;
        float _1222 = _1219 * 0.012683313339948654f;
        float _1223 = _1220 * 0.012683313339948654f;
        float _1224 = exp2(_1221);
        float _1225 = exp2(_1222);
        float _1226 = exp2(_1223);
        float _1227 = _1224 + -0.8359375f;
        float _1228 = _1224 * 18.6875f;
        float _1229 = 18.8515625f - _1228;
        float _1230 = _1227 / _1229;
        float _1231 = _1225 + -0.8359375f;
        float _1232 = _1225 * 18.6875f;
        float _1233 = 18.8515625f - _1232;
        float _1234 = _1231 / _1233;
        float _1235 = _1226 + -0.8359375f;
        float _1236 = _1226 * 18.6875f;
        float _1237 = 18.8515625f - _1236;
        float _1238 = _1235 / _1237;
        float _1239 = 1.0f / resolver_output_params.x;
        float _1240 = abs(_1230);
        float _1241 = abs(_1234);
        float _1242 = abs(_1238);
        float _1243 = log2(_1240);
        float _1244 = log2(_1241);
        float _1245 = log2(_1242);
        float _1246 = _1243 * _1239;
        float _1247 = _1244 * _1239;
        float _1248 = _1245 * _1239;
        float _1249 = exp2(_1246);
        float _1250 = exp2(_1247);
        float _1251 = exp2(_1248);
        float _1252 = 1.0f / resolver_output_params.y;
        float _1253 = _1252 * _1249;
        float _1254 = _1252 * _1250;
        float _1255 = _1252 * _1251;
        float _1256 = _1253 * 1.6604900360107422f;
        float _1257 = mad(-0.5876410007476807f, _1254, _1256);
        float _1258 = mad(-0.07284989953041077f, _1255, _1257);
        float _1259 = _1253 * -0.124549999833107f;
        float _1260 = mad(1.1328999996185303f, _1254, _1259);
        float _1261 = mad(-0.008349419571459293f, _1255, _1260);
        float _1262 = _1253 * -0.018150800839066505f;
        float _1263 = mad(-0.10057900100946426f, _1254, _1262);
        float _1264 = mad(1.1187299489974976f, _1255, _1263);
        _1266 = _1258;
        _1267 = _1261;
        _1268 = _1264;
      } else {
        _1266 = _1156;
        _1267 = _1157;
        _1268 = _1158;
      }
    }
    float _1269 = 1.0f - _1146.w;
    float _1270 = _1266 * _1269;
    float _1271 = _1267 * _1269;
    float _1272 = _1268 * _1269;
    float _1273 = _1270 + _1146.x;
    float _1274 = _1271 + _1146.y;
    float _1275 = _1272 + _1146.z;
    [branch]
    if (_1161) {
      float _1277 = abs(_1273);
      float _1278 = abs(_1274);
      float _1279 = abs(_1275);
      float _1280 = log2(_1277);
      float _1281 = log2(_1278);
      float _1282 = log2(_1279);
      float _1283 = _1280 * resolver_output_params.x;
      float _1284 = _1281 * resolver_output_params.x;
      float _1285 = _1282 * resolver_output_params.x;
      float _1286 = exp2(_1283);
      float _1287 = exp2(_1284);
      float _1288 = exp2(_1285);
      bool _1289 = (_1286 < 0.003100000089034438f);
      if (_1289) {
        float _1291 = _1286 * 12.920000076293945f;
        _1300 = _1291;
      } else {
        float _1293 = abs(_1286);
        float _1294 = log2(_1293);
        float _1295 = _1294 * 0.4166666567325592f;
        float _1296 = exp2(_1295);
        float _1297 = _1296 * 1.0549999475479126f;
        float _1298 = _1297 + -0.054999999701976776f;
        _1300 = _1298;
      }
      bool _1301 = (_1287 < 0.003100000089034438f);
      if (_1301) {
        float _1303 = _1287 * 12.920000076293945f;
        _1312 = _1303;
      } else {
        float _1305 = abs(_1287);
        float _1306 = log2(_1305);
        float _1307 = _1306 * 0.4166666567325592f;
        float _1308 = exp2(_1307);
        float _1309 = _1308 * 1.0549999475479126f;
        float _1310 = _1309 + -0.054999999701976776f;
        _1312 = _1310;
      }
      bool _1313 = (_1288 < 0.003100000089034438f);
      if (_1313) {
        float _1315 = _1288 * 12.920000076293945f;
        _1378 = _1300;
        _1379 = _1312;
        _1380 = _1315;
      } else {
        float _1317 = abs(_1288);
        float _1318 = log2(_1317);
        float _1319 = _1318 * 0.4166666567325592f;
        float _1320 = exp2(_1319);
        float _1321 = _1320 * 1.0549999475479126f;
        float _1322 = _1321 + -0.054999999701976776f;
        _1378 = _1300;
        _1379 = _1312;
        _1380 = _1322;
      }
    } else {
      bool _1324 = (_1160 == 2);
      if (_1324) {
        float _1326 = _1273 * 0.6274039149284363f;
        float _1327 = mad(0.3292830288410187f, _1274, _1326);
        float _1328 = mad(0.04331306740641594f, _1275, _1327);
        float _1329 = _1273 * 0.06909728795289993f;
        float _1330 = mad(0.9195404052734375f, _1274, _1329);
        float _1331 = mad(0.011362316086888313f, _1275, _1330);
        float _1332 = _1273 * 0.016391439363360405f;
        float _1333 = mad(0.08801330626010895f, _1274, _1332);
        float _1334 = mad(0.8955952525138855f, _1275, _1333);
        float _1335 = _1328 * resolver_output_params.y;
        float _1336 = _1331 * resolver_output_params.y;
        float _1337 = _1334 * resolver_output_params.y;
        float _1338 = abs(_1335);
        float _1339 = abs(_1336);
        float _1340 = abs(_1337);
        float _1341 = log2(_1338);
        float _1342 = log2(_1339);
        float _1343 = log2(_1340);
        float _1344 = _1341 * resolver_output_params.x;
        float _1345 = _1342 * resolver_output_params.x;
        float _1346 = _1343 * resolver_output_params.x;
        float _1347 = exp2(_1344);
        float _1348 = exp2(_1345);
        float _1349 = exp2(_1346);
        float _1350 = _1347 * 18.8515625f;
        float _1351 = _1350 + 0.8359375f;
        float _1352 = _1347 * 18.6875f;
        float _1353 = _1352 + 1.0f;
        float _1354 = _1351 / _1353;
        float _1355 = abs(_1354);
        float _1356 = log2(_1355);
        float _1357 = _1356 * 78.84375f;
        float _1358 = exp2(_1357);
        float _1359 = _1348 * 18.8515625f;
        float _1360 = _1359 + 0.8359375f;
        float _1361 = _1348 * 18.6875f;
        float _1362 = _1361 + 1.0f;
        float _1363 = _1360 / _1362;
        float _1364 = abs(_1363);
        float _1365 = log2(_1364);
        float _1366 = _1365 * 78.84375f;
        float _1367 = exp2(_1366);
        float _1368 = _1349 * 18.8515625f;
        float _1369 = _1368 + 0.8359375f;
        float _1370 = _1349 * 18.6875f;
        float _1371 = _1370 + 1.0f;
        float _1372 = _1369 / _1371;
        float _1373 = abs(_1372);
        float _1374 = log2(_1373);
        float _1375 = _1374 * 78.84375f;
        float _1376 = exp2(_1375);
        _1378 = _1358;
        _1379 = _1367;
        _1380 = _1376;
      } else {
        _1378 = _1273;
        _1379 = _1274;
        _1380 = _1275;
      }
    }
    u0_space6[int2(_533, _1013)] = float4(_1378, _1379, _1380, 1.0f);
    bool _1382 = (_182 == 0);
    if (!_1382) {
      [branch]
      if (_1161) {
        float _1385 = abs(_1146.x);
        float _1386 = abs(_1146.y);
        float _1387 = abs(_1146.z);
        float _1388 = log2(_1385);
        float _1389 = log2(_1386);
        float _1390 = log2(_1387);
        float _1391 = _1388 * resolver_output_params.x;
        float _1392 = _1389 * resolver_output_params.x;
        float _1393 = _1390 * resolver_output_params.x;
        float _1394 = exp2(_1391);
        float _1395 = exp2(_1392);
        float _1396 = exp2(_1393);
        bool _1397 = (_1394 < 0.003100000089034438f);
        if (_1397) {
          float _1399 = _1394 * 12.920000076293945f;
          _1408 = _1399;
        } else {
          float _1401 = abs(_1394);
          float _1402 = log2(_1401);
          float _1403 = _1402 * 0.4166666567325592f;
          float _1404 = exp2(_1403);
          float _1405 = _1404 * 1.0549999475479126f;
          float _1406 = _1405 + -0.054999999701976776f;
          _1408 = _1406;
        }
        bool _1409 = (_1395 < 0.003100000089034438f);
        if (_1409) {
          float _1411 = _1395 * 12.920000076293945f;
          _1420 = _1411;
        } else {
          float _1413 = abs(_1395);
          float _1414 = log2(_1413);
          float _1415 = _1414 * 0.4166666567325592f;
          float _1416 = exp2(_1415);
          float _1417 = _1416 * 1.0549999475479126f;
          float _1418 = _1417 + -0.054999999701976776f;
          _1420 = _1418;
        }
        bool _1421 = (_1396 < 0.003100000089034438f);
        if (_1421) {
          float _1423 = _1396 * 12.920000076293945f;
          _1486 = _1408;
          _1487 = _1420;
          _1488 = _1423;
        } else {
          float _1425 = abs(_1396);
          float _1426 = log2(_1425);
          float _1427 = _1426 * 0.4166666567325592f;
          float _1428 = exp2(_1427);
          float _1429 = _1428 * 1.0549999475479126f;
          float _1430 = _1429 + -0.054999999701976776f;
          _1486 = _1408;
          _1487 = _1420;
          _1488 = _1430;
        }
      } else {
        bool _1432 = (_1160 == 2);
        if (_1432) {
          float _1434 = _1146.x * 0.6274039149284363f;
          float _1435 = mad(0.3292830288410187f, _1146.y, _1434);
          float _1436 = mad(0.04331306740641594f, _1146.z, _1435);
          float _1437 = _1146.x * 0.06909728795289993f;
          float _1438 = mad(0.9195404052734375f, _1146.y, _1437);
          float _1439 = mad(0.011362316086888313f, _1146.z, _1438);
          float _1440 = _1146.x * 0.016391439363360405f;
          float _1441 = mad(0.08801330626010895f, _1146.y, _1440);
          float _1442 = mad(0.8955952525138855f, _1146.z, _1441);
          float _1443 = _1436 * resolver_output_params.y;
          float _1444 = _1439 * resolver_output_params.y;
          float _1445 = _1442 * resolver_output_params.y;
          float _1446 = abs(_1443);
          float _1447 = abs(_1444);
          float _1448 = abs(_1445);
          float _1449 = log2(_1446);
          float _1450 = log2(_1447);
          float _1451 = log2(_1448);
          float _1452 = _1449 * resolver_output_params.x;
          float _1453 = _1450 * resolver_output_params.x;
          float _1454 = _1451 * resolver_output_params.x;
          float _1455 = exp2(_1452);
          float _1456 = exp2(_1453);
          float _1457 = exp2(_1454);
          float _1458 = _1455 * 18.8515625f;
          float _1459 = _1458 + 0.8359375f;
          float _1460 = _1455 * 18.6875f;
          float _1461 = _1460 + 1.0f;
          float _1462 = _1459 / _1461;
          float _1463 = abs(_1462);
          float _1464 = log2(_1463);
          float _1465 = _1464 * 78.84375f;
          float _1466 = exp2(_1465);
          float _1467 = _1456 * 18.8515625f;
          float _1468 = _1467 + 0.8359375f;
          float _1469 = _1456 * 18.6875f;
          float _1470 = _1469 + 1.0f;
          float _1471 = _1468 / _1470;
          float _1472 = abs(_1471);
          float _1473 = log2(_1472);
          float _1474 = _1473 * 78.84375f;
          float _1475 = exp2(_1474);
          float _1476 = _1457 * 18.8515625f;
          float _1477 = _1476 + 0.8359375f;
          float _1478 = _1457 * 18.6875f;
          float _1479 = _1478 + 1.0f;
          float _1480 = _1477 / _1479;
          float _1481 = abs(_1480);
          float _1482 = log2(_1481);
          float _1483 = _1482 * 78.84375f;
          float _1484 = exp2(_1483);
          _1486 = _1466;
          _1487 = _1475;
          _1488 = _1484;
        } else {
          _1486 = _1146.x;
          _1487 = _1146.y;
          _1488 = _1146.z;
        }
      }
      u1_space6[int2(_533, _1013)] = float4(_1486, _1487, _1488, _1146.w);
    }
  } else {
    u0_space6[int2(_533, _1013)] = float4(_1156, _1157, _1158, 1.0f);
  }
  float4 _1495 = t0_space6.SampleLevel(s0_space5, float2(_42, _1018), 0.0f);
  half _1499 = half(_1495.x);
  half _1500 = half(_1495.y);
  half _1501 = half(_1495.z);
  float4 _1502 = t0_space6.SampleLevel(s0_space5, float2(_58, _1030), 0.0f);
  half _1506 = half(_1502.x);
  half _1507 = half(_1502.y);
  half _1508 = half(_1502.z);
  float4 _1509 = t0_space6.SampleLevel(s0_space5, float2(_42, _1030), 0.0f);
  half _1513 = half(_1509.x);
  half _1514 = half(_1509.y);
  half _1515 = half(_1509.z);
  float4 _1516 = t0_space6.SampleLevel(s0_space5, float2(_77, _1030), 0.0f);
  half _1520 = half(_1516.x);
  half _1521 = half(_1516.y);
  half _1522 = half(_1516.z);
  float4 _1523 = t0_space6.SampleLevel(s0_space5, float2(_42, _1055), 0.0f);
  half _1527 = half(_1523.x);
  half _1528 = half(_1523.y);
  half _1529 = half(_1523.z);
  half _1530 = min(_1506, _1520);
  half _1531 = min(_1499, _1530);
  half _1532 = min(_1531, _1527);
  half _1533 = min(_1507, _1521);
  half _1534 = min(_1500, _1533);
  half _1535 = min(_1534, _1528);
  half _1536 = min(_1508, _1522);
  half _1537 = min(_1501, _1536);
  half _1538 = min(_1537, _1529);
  half _1539 = max(_1506, _1520);
  half _1540 = max(_1499, _1539);
  half _1541 = max(_1540, _1527);
  half _1542 = max(_1507, _1521);
  half _1543 = max(_1500, _1542);
  half _1544 = max(_1543, _1528);
  half _1545 = max(_1508, _1522);
  half _1546 = max(_1501, _1545);
  half _1547 = max(_1546, _1529);
  half _1548 = 0.25h / _1541;
  half _1549 = 0.25h / _1544;
  half _1550 = 0.25h / _1547;
  half _1551 = 1.0h - _1541;
  half _1552 = _1532 * 4.0h;
  half _1553 = _1552 + -4.0h;
  half _1554 = 1.0h / _1553;
  half _1555 = _1554 * _1551;
  half _1556 = 1.0h - _1544;
  half _1557 = _1535 * 4.0h;
  half _1558 = _1557 + -4.0h;
  half _1559 = 1.0h / _1558;
  half _1560 = _1559 * _1556;
  half _1561 = 1.0h - _1547;
  half _1562 = _1538 * 4.0h;
  half _1563 = _1562 + -4.0h;
  half _1564 = 1.0h / _1563;
  half _1565 = _1564 * _1561;
  half _1566 = _1532 * _1548;
  half _1567 = -0.0h - _1566;
  half _1568 = max(_1567, _1555);
  half _1569 = _1535 * _1549;
  half _1570 = -0.0h - _1569;
  half _1571 = max(_1570, _1560);
  half _1572 = _1538 * _1550;
  half _1573 = -0.0h - _1572;
  half _1574 = max(_1573, _1565);
  half _1575 = max(_1571, _1574);
  half _1576 = max(_1568, _1575);
  half _1577 = min(_1576, 0.0h);
  half _1578 = max(-0.1875h, _1577);
  half _1579 = _147 * _1578;
  half _1580 = _1579 * 4.0h;
  half _1581 = _1580 + 1.0h;
  float _1582 = float(_1581);
  uint _1583 = f32tof16(_1582);
  uint _1584 = 30605u - _1583;
  int _1585 = _1584 & 65535;
  float _1586 = f16tof32(_1585);
  half _1587 = half(_1586);
  half _1588 = _1581 * _1587;
  half _1589 = 2.0h - _1588;
  half _1590 = _1589 * _1587;
  half _1591 = _1506 + _1499;
  half _1592 = _1591 + _1520;
  half _1593 = _1592 + _1527;
  half _1594 = _1579 * _1593;
  half _1595 = _1594 + _1513;
  half _1596 = _1590 * _1595;
  half _1597 = _1507 + _1500;
  half _1598 = _1597 + _1521;
  half _1599 = _1598 + _1528;
  half _1600 = _1579 * _1599;
  half _1601 = _1600 + _1514;
  half _1602 = _1590 * _1601;
  half _1603 = _1508 + _1501;
  half _1604 = _1603 + _1522;
  half _1605 = _1604 + _1529;
  half _1606 = _1579 * _1605;
  half _1607 = _1606 + _1515;
  half _1608 = _1590 * _1607;
  const float3 resolver_color_3 = SelectResolverSharpening(
      float3(_1596, _1602, _1608), _1495.rgb, _1502.rgb, _1509.rgb, _1516.rgb, _1523.rgb,
      resolver_output_params, resolver_normalization_point);
  half _1609 = min(half(resolver_color_3.x), _178);
  half _1610 = min(half(resolver_color_3.y), _178);
  half _1611 = min(half(resolver_color_3.z), _178);
  float4 _1613 = t1_space6.Load(int3(_32, _1013, 0));
  float _1618 = max(_1613.y, _1613.z);
  float _1619 = max(_1613.x, _1618);
  float _1620 = _1619 + _1613.w;
  bool _1621 = !(_1620 > 0.0f);
  bool _1622 = _194 || _1621;
  float _1623 = float(_1609);
  float _1624 = float(_1610);
  float _1625 = float(_1611);
  if (!_1622) {
    int _1627 = int(resolver_output_params.w);
    bool _1628 = (_1627 == 1);
    [branch]
    if (_1628) {
      bool _1630 = (_1623 < 0.040449999272823334f);
      if (_1630) {
        float _1632 = _1623 * 0.07739938050508499f;
        _1641 = _1632;
      } else {
        float _1634 = _1623 * 0.9478672742843628f;
        float _1635 = _1634 + 0.05213269963860512f;
        float _1636 = abs(_1635);
        float _1637 = log2(_1636);
        float _1638 = _1637 * 2.4000000953674316f;
        float _1639 = exp2(_1638);
        _1641 = _1639;
      }
      bool _1642 = (_1624 < 0.040449999272823334f);
      if (_1642) {
        float _1644 = _1624 * 0.07739938050508499f;
        _1653 = _1644;
      } else {
        float _1646 = _1624 * 0.9478672742843628f;
        float _1647 = _1646 + 0.05213269963860512f;
        float _1648 = abs(_1647);
        float _1649 = log2(_1648);
        float _1650 = _1649 * 2.4000000953674316f;
        float _1651 = exp2(_1650);
        _1653 = _1651;
      }
      bool _1654 = (_1625 < 0.040449999272823334f);
      if (_1654) {
        float _1656 = _1625 * 0.07739938050508499f;
        _1665 = _1656;
      } else {
        float _1658 = _1625 * 0.9478672742843628f;
        float _1659 = _1658 + 0.05213269963860512f;
        float _1660 = abs(_1659);
        float _1661 = log2(_1660);
        float _1662 = _1661 * 2.4000000953674316f;
        float _1663 = exp2(_1662);
        _1665 = _1663;
      }
      float _1666 = 1.0f / resolver_output_params.x;
      float _1667 = abs(_1641);
      float _1668 = abs(_1653);
      float _1669 = abs(_1665);
      float _1670 = log2(_1667);
      float _1671 = log2(_1668);
      float _1672 = log2(_1669);
      float _1673 = _1670 * _1666;
      float _1674 = _1671 * _1666;
      float _1675 = _1672 * _1666;
      float _1676 = exp2(_1673);
      float _1677 = exp2(_1674);
      float _1678 = exp2(_1675);
      _1733 = _1676;
      _1734 = _1677;
      _1735 = _1678;
    } else {
      bool _1680 = (_1627 == 2);
      if (_1680) {
        float _1682 = abs(_1623);
        float _1683 = abs(_1624);
        float _1684 = abs(_1625);
        float _1685 = log2(_1682);
        float _1686 = log2(_1683);
        float _1687 = log2(_1684);
        float _1688 = _1685 * 0.012683313339948654f;
        float _1689 = _1686 * 0.012683313339948654f;
        float _1690 = _1687 * 0.012683313339948654f;
        float _1691 = exp2(_1688);
        float _1692 = exp2(_1689);
        float _1693 = exp2(_1690);
        float _1694 = _1691 + -0.8359375f;
        float _1695 = _1691 * 18.6875f;
        float _1696 = 18.8515625f - _1695;
        float _1697 = _1694 / _1696;
        float _1698 = _1692 + -0.8359375f;
        float _1699 = _1692 * 18.6875f;
        float _1700 = 18.8515625f - _1699;
        float _1701 = _1698 / _1700;
        float _1702 = _1693 + -0.8359375f;
        float _1703 = _1693 * 18.6875f;
        float _1704 = 18.8515625f - _1703;
        float _1705 = _1702 / _1704;
        float _1706 = 1.0f / resolver_output_params.x;
        float _1707 = abs(_1697);
        float _1708 = abs(_1701);
        float _1709 = abs(_1705);
        float _1710 = log2(_1707);
        float _1711 = log2(_1708);
        float _1712 = log2(_1709);
        float _1713 = _1710 * _1706;
        float _1714 = _1711 * _1706;
        float _1715 = _1712 * _1706;
        float _1716 = exp2(_1713);
        float _1717 = exp2(_1714);
        float _1718 = exp2(_1715);
        float _1719 = 1.0f / resolver_output_params.y;
        float _1720 = _1719 * _1716;
        float _1721 = _1719 * _1717;
        float _1722 = _1719 * _1718;
        float _1723 = _1720 * 1.6604900360107422f;
        float _1724 = mad(-0.5876410007476807f, _1721, _1723);
        float _1725 = mad(-0.07284989953041077f, _1722, _1724);
        float _1726 = _1720 * -0.124549999833107f;
        float _1727 = mad(1.1328999996185303f, _1721, _1726);
        float _1728 = mad(-0.008349419571459293f, _1722, _1727);
        float _1729 = _1720 * -0.018150800839066505f;
        float _1730 = mad(-0.10057900100946426f, _1721, _1729);
        float _1731 = mad(1.1187299489974976f, _1722, _1730);
        _1733 = _1725;
        _1734 = _1728;
        _1735 = _1731;
      } else {
        _1733 = _1623;
        _1734 = _1624;
        _1735 = _1625;
      }
    }
    float _1736 = 1.0f - _1613.w;
    float _1737 = _1733 * _1736;
    float _1738 = _1734 * _1736;
    float _1739 = _1735 * _1736;
    float _1740 = _1737 + _1613.x;
    float _1741 = _1738 + _1613.y;
    float _1742 = _1739 + _1613.z;
    [branch]
    if (_1628) {
      float _1744 = abs(_1740);
      float _1745 = abs(_1741);
      float _1746 = abs(_1742);
      float _1747 = log2(_1744);
      float _1748 = log2(_1745);
      float _1749 = log2(_1746);
      float _1750 = _1747 * resolver_output_params.x;
      float _1751 = _1748 * resolver_output_params.x;
      float _1752 = _1749 * resolver_output_params.x;
      float _1753 = exp2(_1750);
      float _1754 = exp2(_1751);
      float _1755 = exp2(_1752);
      bool _1756 = (_1753 < 0.003100000089034438f);
      if (_1756) {
        float _1758 = _1753 * 12.920000076293945f;
        _1767 = _1758;
      } else {
        float _1760 = abs(_1753);
        float _1761 = log2(_1760);
        float _1762 = _1761 * 0.4166666567325592f;
        float _1763 = exp2(_1762);
        float _1764 = _1763 * 1.0549999475479126f;
        float _1765 = _1764 + -0.054999999701976776f;
        _1767 = _1765;
      }
      bool _1768 = (_1754 < 0.003100000089034438f);
      if (_1768) {
        float _1770 = _1754 * 12.920000076293945f;
        _1779 = _1770;
      } else {
        float _1772 = abs(_1754);
        float _1773 = log2(_1772);
        float _1774 = _1773 * 0.4166666567325592f;
        float _1775 = exp2(_1774);
        float _1776 = _1775 * 1.0549999475479126f;
        float _1777 = _1776 + -0.054999999701976776f;
        _1779 = _1777;
      }
      bool _1780 = (_1755 < 0.003100000089034438f);
      if (_1780) {
        float _1782 = _1755 * 12.920000076293945f;
        _1845 = _1767;
        _1846 = _1779;
        _1847 = _1782;
      } else {
        float _1784 = abs(_1755);
        float _1785 = log2(_1784);
        float _1786 = _1785 * 0.4166666567325592f;
        float _1787 = exp2(_1786);
        float _1788 = _1787 * 1.0549999475479126f;
        float _1789 = _1788 + -0.054999999701976776f;
        _1845 = _1767;
        _1846 = _1779;
        _1847 = _1789;
      }
    } else {
      bool _1791 = (_1627 == 2);
      if (_1791) {
        float _1793 = _1740 * 0.6274039149284363f;
        float _1794 = mad(0.3292830288410187f, _1741, _1793);
        float _1795 = mad(0.04331306740641594f, _1742, _1794);
        float _1796 = _1740 * 0.06909728795289993f;
        float _1797 = mad(0.9195404052734375f, _1741, _1796);
        float _1798 = mad(0.011362316086888313f, _1742, _1797);
        float _1799 = _1740 * 0.016391439363360405f;
        float _1800 = mad(0.08801330626010895f, _1741, _1799);
        float _1801 = mad(0.8955952525138855f, _1742, _1800);
        float _1802 = _1795 * resolver_output_params.y;
        float _1803 = _1798 * resolver_output_params.y;
        float _1804 = _1801 * resolver_output_params.y;
        float _1805 = abs(_1802);
        float _1806 = abs(_1803);
        float _1807 = abs(_1804);
        float _1808 = log2(_1805);
        float _1809 = log2(_1806);
        float _1810 = log2(_1807);
        float _1811 = _1808 * resolver_output_params.x;
        float _1812 = _1809 * resolver_output_params.x;
        float _1813 = _1810 * resolver_output_params.x;
        float _1814 = exp2(_1811);
        float _1815 = exp2(_1812);
        float _1816 = exp2(_1813);
        float _1817 = _1814 * 18.8515625f;
        float _1818 = _1817 + 0.8359375f;
        float _1819 = _1814 * 18.6875f;
        float _1820 = _1819 + 1.0f;
        float _1821 = _1818 / _1820;
        float _1822 = abs(_1821);
        float _1823 = log2(_1822);
        float _1824 = _1823 * 78.84375f;
        float _1825 = exp2(_1824);
        float _1826 = _1815 * 18.8515625f;
        float _1827 = _1826 + 0.8359375f;
        float _1828 = _1815 * 18.6875f;
        float _1829 = _1828 + 1.0f;
        float _1830 = _1827 / _1829;
        float _1831 = abs(_1830);
        float _1832 = log2(_1831);
        float _1833 = _1832 * 78.84375f;
        float _1834 = exp2(_1833);
        float _1835 = _1816 * 18.8515625f;
        float _1836 = _1835 + 0.8359375f;
        float _1837 = _1816 * 18.6875f;
        float _1838 = _1837 + 1.0f;
        float _1839 = _1836 / _1838;
        float _1840 = abs(_1839);
        float _1841 = log2(_1840);
        float _1842 = _1841 * 78.84375f;
        float _1843 = exp2(_1842);
        _1845 = _1825;
        _1846 = _1834;
        _1847 = _1843;
      } else {
        _1845 = _1740;
        _1846 = _1741;
        _1847 = _1742;
      }
    }
    u0_space6[int2(_32, _1013)] = float4(_1845, _1846, _1847, 1.0f);
    bool _1849 = (_182 == 0);
    if (!_1849) {
      [branch]
      if (_1628) {
        float _1852 = abs(_1613.x);
        float _1853 = abs(_1613.y);
        float _1854 = abs(_1613.z);
        float _1855 = log2(_1852);
        float _1856 = log2(_1853);
        float _1857 = log2(_1854);
        float _1858 = _1855 * resolver_output_params.x;
        float _1859 = _1856 * resolver_output_params.x;
        float _1860 = _1857 * resolver_output_params.x;
        float _1861 = exp2(_1858);
        float _1862 = exp2(_1859);
        float _1863 = exp2(_1860);
        bool _1864 = (_1861 < 0.003100000089034438f);
        if (_1864) {
          float _1866 = _1861 * 12.920000076293945f;
          _1875 = _1866;
        } else {
          float _1868 = abs(_1861);
          float _1869 = log2(_1868);
          float _1870 = _1869 * 0.4166666567325592f;
          float _1871 = exp2(_1870);
          float _1872 = _1871 * 1.0549999475479126f;
          float _1873 = _1872 + -0.054999999701976776f;
          _1875 = _1873;
        }
        bool _1876 = (_1862 < 0.003100000089034438f);
        if (_1876) {
          float _1878 = _1862 * 12.920000076293945f;
          _1887 = _1878;
        } else {
          float _1880 = abs(_1862);
          float _1881 = log2(_1880);
          float _1882 = _1881 * 0.4166666567325592f;
          float _1883 = exp2(_1882);
          float _1884 = _1883 * 1.0549999475479126f;
          float _1885 = _1884 + -0.054999999701976776f;
          _1887 = _1885;
        }
        bool _1888 = (_1863 < 0.003100000089034438f);
        if (_1888) {
          float _1890 = _1863 * 12.920000076293945f;
          _1953 = _1875;
          _1954 = _1887;
          _1955 = _1890;
        } else {
          float _1892 = abs(_1863);
          float _1893 = log2(_1892);
          float _1894 = _1893 * 0.4166666567325592f;
          float _1895 = exp2(_1894);
          float _1896 = _1895 * 1.0549999475479126f;
          float _1897 = _1896 + -0.054999999701976776f;
          _1953 = _1875;
          _1954 = _1887;
          _1955 = _1897;
        }
      } else {
        bool _1899 = (_1627 == 2);
        if (_1899) {
          float _1901 = _1613.x * 0.6274039149284363f;
          float _1902 = mad(0.3292830288410187f, _1613.y, _1901);
          float _1903 = mad(0.04331306740641594f, _1613.z, _1902);
          float _1904 = _1613.x * 0.06909728795289993f;
          float _1905 = mad(0.9195404052734375f, _1613.y, _1904);
          float _1906 = mad(0.011362316086888313f, _1613.z, _1905);
          float _1907 = _1613.x * 0.016391439363360405f;
          float _1908 = mad(0.08801330626010895f, _1613.y, _1907);
          float _1909 = mad(0.8955952525138855f, _1613.z, _1908);
          float _1910 = _1903 * resolver_output_params.y;
          float _1911 = _1906 * resolver_output_params.y;
          float _1912 = _1909 * resolver_output_params.y;
          float _1913 = abs(_1910);
          float _1914 = abs(_1911);
          float _1915 = abs(_1912);
          float _1916 = log2(_1913);
          float _1917 = log2(_1914);
          float _1918 = log2(_1915);
          float _1919 = _1916 * resolver_output_params.x;
          float _1920 = _1917 * resolver_output_params.x;
          float _1921 = _1918 * resolver_output_params.x;
          float _1922 = exp2(_1919);
          float _1923 = exp2(_1920);
          float _1924 = exp2(_1921);
          float _1925 = _1922 * 18.8515625f;
          float _1926 = _1925 + 0.8359375f;
          float _1927 = _1922 * 18.6875f;
          float _1928 = _1927 + 1.0f;
          float _1929 = _1926 / _1928;
          float _1930 = abs(_1929);
          float _1931 = log2(_1930);
          float _1932 = _1931 * 78.84375f;
          float _1933 = exp2(_1932);
          float _1934 = _1923 * 18.8515625f;
          float _1935 = _1934 + 0.8359375f;
          float _1936 = _1923 * 18.6875f;
          float _1937 = _1936 + 1.0f;
          float _1938 = _1935 / _1937;
          float _1939 = abs(_1938);
          float _1940 = log2(_1939);
          float _1941 = _1940 * 78.84375f;
          float _1942 = exp2(_1941);
          float _1943 = _1924 * 18.8515625f;
          float _1944 = _1943 + 0.8359375f;
          float _1945 = _1924 * 18.6875f;
          float _1946 = _1945 + 1.0f;
          float _1947 = _1944 / _1946;
          float _1948 = abs(_1947);
          float _1949 = log2(_1948);
          float _1950 = _1949 * 78.84375f;
          float _1951 = exp2(_1950);
          _1953 = _1933;
          _1954 = _1942;
          _1955 = _1951;
        } else {
          _1953 = _1613.x;
          _1954 = _1613.y;
          _1955 = _1613.z;
        }
      }
      u1_space6[int2(_32, _1013)] = float4(_1953, _1954, _1955, _1613.w);
    }
  } else {
    u0_space6[int2(_32, _1013)] = float4(_1623, _1624, _1625, 1.0f);
  }
}

#endif  // SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_AA_RESOLVER_0XA0F3AF86_HLSLI_
