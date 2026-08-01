// HFW CE scene compose, no-AA variant. Twin of
// hzdr/compose_noaa_0xDC3776F8, same math. Only the cbuffer layout differs.

#include "../common.hlsli"

Texture2D<uint> t0_space3 : register(t0, space3);

Texture2D<float> t1_space3 : register(t1, space3);

Texture2D<float> t2_space3 : register(t2, space3);

Texture2D<float3> t4_space3 : register(t4, space3);

Texture2D<float4> t5_space3 : register(t5, space3);

Texture2D<float3> t6_space3 : register(t6, space3);

Texture2D<float4> t7_space3 : register(t7, space3);

Texture2D<float3> t8_space3 : register(t8, space3);

Texture2D<float2> t9_space3 : register(t9, space3);

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
      float4 ComposeDynamicBindings_Constant_016;
      float4 ComposeDynamicBindings_Constant_032;
      float2 ComposeDynamicBindings_Constant_048;
      float2 ComposeDynamicBindings_Constant_056;
      float4 ComposeDynamicBindings_Constant_064;
      int4 ComposeDynamicBindings_Constant_080;
      float4 ComposeDynamicBindings_Constant_096;
      float4 ComposeDynamicBindings_Constant_112;
      float4 ComposeDynamicBindings_Constant_128;
      float4 ComposeDynamicBindings_Constant_144;
      float4 ComposeDynamicBindings_Constant_160;
      float4 ComposeDynamicBindings_Constant_176;
      float4 ComposeDynamicBindings_Constant_192;
      float ComposeDynamicBindings_Constant_208;
      int ComposeDynamicBindings_Constant_212;
    } Scratch_PerBatch_Constants_000;
  } Scratch_PerBatch_000 : packoffset(c000.x);
};

#define CB Scratch_PerBatch_000.Scratch_PerBatch_Constants_000

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
  SamplerState s0_heap = SamplerDescriptorHeap[0];
  SamplerState s1_heap = SamplerDescriptorHeap[2];
  SamplerState s2_heap = SamplerDescriptorHeap[17];
  float _78 = CB.ComposeDynamicBindings_Constant_000.x * TEXCOORD.x;
  float _79 = CB.ComposeDynamicBindings_Constant_000.y * TEXCOORD.y;
  float _80 = _78 + CB.ComposeDynamicBindings_Constant_000.z;
  float _81 = _79 + CB.ComposeDynamicBindings_Constant_000.w;
  float3 _83 = t4_space3.Sample(s0_heap, float2(TEXCOORD.x, TEXCOORD.y));
  uint _87 = uint(SV_Position.x);
  uint _88 = uint(SV_Position.y);
  float _89 = float((int)(CB.ComposeDynamicBindings_Constant_080.z));
  float _90 = float((int)(CB.ComposeDynamicBindings_Constant_080.w));
  float _91 = float((int)(CB.ComposeDynamicBindings_Constant_080.x));
  float _92 = float((int)(CB.ComposeDynamicBindings_Constant_080.y));
  int _93 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.x & 31;
  int _94 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.y & 31;
  uint _95 = _87 >> _93;
  uint _96 = _88 >> _94;
  float _97 = float((int)(_95));
  float _98 = float((int)(_96));
  float _99 = max(_97, _91);
  float _100 = min(_99, _89);
  float _101 = min(_97, _91);
  float _102 = max(_101, _100);
  float _103 = max(_98, _92);
  float _104 = min(_103, _90);
  float _105 = min(_98, _92);
  float _106 = max(_105, _104);
  int _107 = int(_102);
  int _108 = int(_106);
  uint _111 = t0_space3.Load(int3(_107, _108, 0));
  bool _112 = (_111.x == 0);
  float _182;
  float _183;
  float _184;
  float _315;
  float _316;
  float _317;
  float _394;
  float _395;
  float _396;
  float _503;
  float _511;
  float _512;
  float _513;
  float _540;
  float _552;
  float _618;
  float _619;
  float _620;
  [branch]
  if (!_112) {
    int _114 = _111.x & 536870912;
    bool _115 = (_114 == 0);
    if (!_115) {
      float4 _118 = t5_space3.Sample(s1_heap, float2(TEXCOORD.x, TEXCOORD.y));
      _182 = _118.x;
      _183 = _118.y;
      _184 = _118.z;
    } else {
      int _123 = _111.x & 268435456;
      bool _124 = (_123 == 0);
      float3 _126 = t6_space3.Sample(s1_heap, float2(TEXCOORD.x, TEXCOORD.y));
      if (_124) {
        float _133 = t1_space3.Sample(s0_heap, float2(TEXCOORD.x, TEXCOORD.y));
        float _134 = _133.x * 12.0f;
        float _135 = max(_134, -12.0f);
        float _136 = min(_135, 12.0f);
        float _137 = min(_134, -12.0f);
        float _138 = max(_137, _136);
        float _141 = t2_space3.Sample(s1_heap, float2(TEXCOORD.x, TEXCOORD.y));
        float _142 = _138 + -3.0f;
        float _143 = saturate(_142);
        float _144 = _143 * 2.0f;
        float _145 = 3.0f - _144;
        float _146 = _143 * _143;
        float _147 = _146 * _145;
        float _148 = _126.x - _83.x;
        float _149 = _126.y - _83.y;
        float _150 = _126.z - _83.z;
        float _151 = _148 * _147;
        float _152 = _149 * _147;
        float _153 = _150 * _147;
        float _154 = _151 + _83.x;
        float _155 = _152 + _83.y;
        float _156 = _153 + _83.z;
        float4 _158 = t5_space3.Sample(s0_heap, float2(TEXCOORD.x, TEXCOORD.y));
        bool _162 = (_158.x > 0.0f);
        bool _163 = (_158.y > 0.0f);
        bool _164 = (_158.z > 0.0f);
        bool _165 = _162 || _163;
        bool _166 = _164 || _165;
        if (_166) {
          float4 _168 = t5_space3.Sample(s1_heap, float2(TEXCOORD.x, TEXCOORD.y));
          float _172 = _168.x - _154;
          float _173 = _168.y - _155;
          float _174 = _168.z - _156;
          float _175 = _172 * _141.x;
          float _176 = _173 * _141.x;
          float _177 = _174 * _141.x;
          float _178 = _175 + _154;
          float _179 = _176 + _155;
          float _180 = _177 + _156;
          _182 = _178;
          _183 = _179;
          _184 = _180;
        } else {
          _182 = _154;
          _183 = _155;
          _184 = _156;
        }
      } else {
        _182 = _126.x;
        _183 = _126.y;
        _184 = _126.z;
      }
    }
  } else {
    _182 = _83.x;
    _183 = _83.y;
    _184 = _83.z;
  }
  float _187 = t0_space5.Load(2);
  float4 _189 = t7_space3.Sample(s1_heap, float2(TEXCOORD.x, TEXCOORD.y));
  float3 _194 = t8_space3.Sample(s1_heap, float2(TEXCOORD.x, TEXCOORD.y));
  float _198 = _189.x * _189.x;
  float _199 = _189.y * _189.y;
  float _200 = _189.z * _189.z;
  float _201 = CB.ComposeDynamicBindings_Constant_176.y * 0.25f;
  float _202 = _182 * _201;
  float _203 = _183 * _201;
  float _204 = _184 * _201;
  float _205 = dot(float3(_202, _203, _204), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _206 = _205 + 9.999999974752427e-07f;
  float _207 = saturate(_206);
  float _208 = 1.0f - CB.ComposeDynamicBindings_Constant_144.w;
  float _209 = _207 * _208;
  float _210 = _209 + CB.ComposeDynamicBindings_Constant_144.w;
  float _211 = max(_202, 0.0f);
  float _212 = max(_203, 0.0f);
  float _213 = max(_204, 0.0f);
  float _214 = log2(_211);
  float _215 = log2(_212);
  float _216 = log2(_213);
  float _217 = _214 * _210;
  float _218 = _215 * _210;
  float _219 = _216 * _210;
  float _220 = exp2(_217);
  float _221 = exp2(_218);
  float _222 = exp2(_219);
  float _223 = _220 / _201;
  float _224 = _221 / _201;
  float _225 = _222 / _201;
  float _226 = _223 * CB.ComposeDynamicBindings_Constant_144.w;
  float _227 = _224 * CB.ComposeDynamicBindings_Constant_144.w;
  float _228 = _225 * CB.ComposeDynamicBindings_Constant_144.w;
  float _229 = _198 / CB.ComposeDynamicBindings_Constant_176.z;
  float _230 = _199 / CB.ComposeDynamicBindings_Constant_176.z;
  float _231 = _200 / CB.ComposeDynamicBindings_Constant_176.z;
  float _232 = _187.x * 4.0f;
  float _233 = _187.x + 0.25f;
  float _234 = _232 / _233;
  float _235 = _229 * _226;
  float _236 = _230 * _227;
  float _237 = _231 * _228;
  float _238 = max(_187.x, 1.0000000031710769e-30f);
  float _239 = _235 / _238;
  float _240 = _236 / _238;
  float _241 = _237 / _238;
  float _242 = sqrt(_239);
  float _243 = sqrt(_240);
  float _244 = sqrt(_241);
  float _245 = _242 * _234;
  float _246 = _243 * _234;
  float _247 = _244 * _234;
  float _248 = _187.x + 1.0f;
  float _249 = _248 + _234;
  float _250 = 1.0f / _249;
  float _251 = _229 + _226;
  float _252 = _251 + _245;
  float _253 = _250 * _252;
  float _254 = _230 + _227;
  float _255 = _254 + _246;
  float _256 = _255 * _250;
  float _257 = _231 + _228;
  float _258 = _257 + _247;
  float _259 = _258 * _250;
  float _260 = dot(float3(_194.x, _194.y, _194.z), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _261 = _194.x - _260;
  float _262 = _194.y - _260;
  float _263 = _194.z - _260;
  float _264 = _261 * CB.ComposeDynamicBindings_Constant_016.w;
  float _265 = _262 * CB.ComposeDynamicBindings_Constant_016.w;
  float _266 = _263 * CB.ComposeDynamicBindings_Constant_016.w;
  float _267 = _264 + _260;
  float _268 = _265 + _260;
  float _269 = _266 + _260;
  float _270 = CB.ComposeDynamicBindings_Constant_176.x * CB.ComposeDynamicBindings_Constant_016.x;
  float _271 = _270 * _267;
  float _272 = CB.ComposeDynamicBindings_Constant_176.x * CB.ComposeDynamicBindings_Constant_016.y;
  float _273 = _272 * _268;
  float _274 = CB.ComposeDynamicBindings_Constant_176.x * CB.ComposeDynamicBindings_Constant_016.z;
  float _275 = _274 * _269;
  float _276 = _271 + _253;
  float _277 = _273 + _256;
  float _278 = _275 + _259;
  float _279 = _276 * CB.ComposeDynamicBindings_Constant_144.x;
  float _280 = CB.ComposeDynamicBindings_Constant_144.x - CB.ComposeDynamicBindings_Constant_144.y;
  float _281 = _277 * _280;
  float _282 = _279 + _281;
  float _283 = _282 * CB.ComposeDynamicBindings_Constant_176.z;
  float _284 = CB.ComposeDynamicBindings_Constant_176.z * CB.ComposeDynamicBindings_Constant_144.y;
  float _285 = _284 * _277;
  float _286 = CB.ComposeDynamicBindings_Constant_176.z * CB.ComposeDynamicBindings_Constant_144.z;
  float _287 = _286 * _278;
  int _288 = CB.ComposeDynamicBindings_Constant_212 & 1;
  bool _289 = (_288 == 0);
  [branch]
  if (!_289) {
    int _292 = asint(CB.ComposeDynamicBindings_Constant_064.z);
    int _293 = _292 & 65535;
    float _294 = float((uint)_293);
    float _295 = _294 * 1.52587890625e-05f;
    int _296 = (uint)(_292) >> 16;
    float _297 = float((uint)_296);
    float _298 = _297 * 1.52587890625e-05f;
    float _299 = _80 * CB.ComposeDynamicBindings_Constant_064.x;
    float _300 = _81 * CB.ComposeDynamicBindings_Constant_064.y;
    float _301 = _299 + _295;
    float _302 = _300 + _298;
    float2 _305 = t9_space3.Sample(s2_heap, float2(_301, _302));
    float _307 = _305.y + -0.5f;
    float _308 = _307 * _189.w;
    float _309 = _308 + _283;
    float _310 = _308 + _285;
    float _311 = _308 + _287;
    float _312 = max(_309, 0.0f);
    float _313 = max(_310, 0.0f);
    float _314 = max(_311, 0.0f);
    _315 = _312;
    _316 = _313;
    _317 = _314;
  } else {
    _315 = _283;
    _316 = _285;
    _317 = _287;
  }
  float _318 = _250 * CB.ComposeDynamicBindings_Constant_176.z;
  float _319 = _318 * CB.ComposeDynamicBindings_Constant_032.x;
  float _320 = _318 * CB.ComposeDynamicBindings_Constant_032.y;
  float _321 = _318 * CB.ComposeDynamicBindings_Constant_032.z;
  float _322 = _80 * 2.0f;
  float _323 = _81 * 2.0f;
  float _324 = _322 + -1.0f;
  float _325 = _323 + -1.0f;
  float _326 = _324 * _324;
  float _327 = _325 * _325;
  float _328 = _327 + _326;
  float _329 = sqrt(_328);
  float _330 = _329 * CB.ComposeDynamicBindings_Constant_048.x;
  float _331 = _330 + CB.ComposeDynamicBindings_Constant_048.y;
  float _332 = saturate(_331);
  float _333 = _332 * _332;
  float _334 = _333 * CB.ComposeDynamicBindings_Constant_032.w;
  _334 *= injectedData.fx_vignette;  // RenoDX vignette strength, 1.0 = vanilla
  float _335 = 1.0f - _334;
  float _336 = _335 * _315;
  float _337 = _335 * _316;
  float _338 = _335 * _317;
  float _339 = _319 * _334;
  float _340 = _320 * _334;
  float _341 = _321 * _334;
  float _342 = _336 + _339;
  float _343 = _337 + _340;
  float _344 = _338 + _341;
  float _345 = max(_342, 9.999999974752427e-07f);
  float _346 = max(_343, 9.999999974752427e-07f);
  float _347 = max(_344, 9.999999974752427e-07f);
  float _348 = dot(float3(_345, _346, _347), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  int _349 = CB.ComposeDynamicBindings_Constant_212 & 2;
  bool _350 = (_349 == 0);
  if (!_350) {
    float _352 = max(_345, 0.0f);
    float _353 = max(_346, 0.0f);
    float _354 = max(_347, 0.0f);
    float _355 = _352 * 0.9455959796905518f;
    float _356 = mad(0.045505501329898834f, _353, _355);
    float _357 = mad(0.008898990228772163f, _354, _356);
    float _358 = _352 * 0.014694600366055965f;
    float _359 = mad(0.967956006526947f, _353, _358);
    float _360 = mad(0.017349300906062126f, _354, _359);
    float _361 = _352 * 0.005567430052906275f;
    float _362 = mad(0.020142799243330956f, _353, _361);
    float _363 = mad(0.9742900133132935f, _354, _362);
    float _364 = dot(float3(0.21321800351142883f, 0.7275890111923218f, 0.059193599969148636f), float3(_357, _360, _363));
    float _365 = _364 + 1.0f;
    float _366 = _365 * _357;
    float _367 = _365 * _360;
    float _368 = _365 * _363;
    float _369 = _366 + 1.0f;
    float _370 = _367 + 1.0f;
    float _371 = _368 + 1.0f;
    float _372 = _369 * _357;
    float _373 = _370 * _360;
    float _374 = _371 * _363;
    float _375 = _372 + _365;
    float _376 = _373 + _365;
    float _377 = _374 + _365;
    float _378 = _372 / _375;
    float _379 = _373 / _376;
    float _380 = _374 / _377;
    float _381 = _378 * 1.058359980583191f;
    float _382 = mad(-0.049572598189115524f, _379, _381);
    float _383 = mad(-0.008784100413322449f, _380, _382);
    float _384 = _378 * -0.015964500606060028f;
    float _385 = mad(1.0342400074005127f, _379, _384);
    float _386 = mad(-0.01827090047299862f, _380, _385);
    float _387 = _378 * -0.00571777019649744f;
    float _388 = mad(-0.021098900586366653f, _379, _387);
    float _389 = mad(1.0268199443817139f, _380, _388);
    float _390 = max(_383, 0.0f);
    float _391 = max(_386, 0.0f);
    float _392 = max(_389, 0.0f);
    _394 = _390;
    _395 = _391;
    _396 = _392;
  } else {
    _394 = _345;
    _395 = _346;
    _396 = _347;
  }
  float _397 = dot(float3(_394, _395, _396), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _398 = max(_394, 0.0f);
  float _399 = max(_395, 0.0f);
  float _400 = max(_396, 0.0f);
  float _401 = sqrt(_398);
  float _402 = sqrt(_399);
  float _403 = sqrt(_400);
  float _404 = saturate(_401);
  float _405 = saturate(_402);
  float _406 = saturate(_403);
  float _407 = _404 * CB.ComposeDynamicBindings_Constant_056.x;
  float _408 = _405 * CB.ComposeDynamicBindings_Constant_056.x;
  float _409 = _406 * CB.ComposeDynamicBindings_Constant_056.x;
  float _410 = _407 + CB.ComposeDynamicBindings_Constant_056.y;
  float _411 = _408 + CB.ComposeDynamicBindings_Constant_056.y;
  float _412 = _409 + CB.ComposeDynamicBindings_Constant_056.y;
  float3 _414 = t1_space5.SampleLevel(s1_heap, float3(_410, _411, _412), 0.0f);
  float _418 = _414.x * _414.x;
  float _419 = _414.y * _414.y;
  float _420 = _414.z * _414.z;
  float _421 = _397 + 9.999999960041972e-13f;
  float _422 = _348 / _421;
  float _423 = max(_422, 0.0f);
  float _424 = _423 + -1.0f;
  float _425 = _424 * 0.03999999910593033f;
  float _426 = saturate(_425);
  float _427 = dot(float3(_418, _419, _420), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _428 = _427 * 8.0f;
  float _429 = _428 + -4.0f;
  float _430 = saturate(_429);
  float _431 = _430 * _426;
  float _432 = saturate(_418);
  float _433 = saturate(_419);
  float _434 = saturate(_420);
  int _435 = CB.ComposeDynamicBindings_Constant_212 & 4;
  bool _436 = (_435 == 0);
  [branch]
  if (!_436) {
    float _438 = _432 * _432;
    float _439 = _433 * _433;
    float _440 = _434 * _434;
    float _441 = CB.ComposeDynamicBindings_Constant_192.w * CB.ComposeDynamicBindings_Constant_192.w;
    float _442 = _438 + _441;
    float _443 = _439 + _441;
    float _444 = _440 + _441;
    float _445 = sqrt(_442);
    float _446 = sqrt(_443);
    float _447 = sqrt(_444);
    float _448 = _445 - CB.ComposeDynamicBindings_Constant_192.w;
    float _449 = _446 - CB.ComposeDynamicBindings_Constant_192.w;
    float _450 = _447 - CB.ComposeDynamicBindings_Constant_192.w;
    float _451 = CB.ComposeDynamicBindings_Constant_192.w + 1.0f;
    float _452 = _448 * _451;
    float _453 = _449 * _451;
    float _454 = _450 * _451;
    float _455 = max(1.0f, CB.ComposeDynamicBindings_Constant_192.z);
    float _456 = dot(float3(_452, _453, _454), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    float _457 = saturate(_456);
    float _458 = _457 + -0.5f;
    float _459 = saturate(_458);
    float _460 = _457 * 0.5f;
    float _461 = 1.0f - _460;
    float _462 = 1.0f / _461;
    float _463 = _431 * 100.0f;
    float _464 = _459 * _459;
    float _465 = _464 * _463;
    float _466 = _465 + _462;
    float _467 = _466 * _457;
    float _468 = _455 + -1.0f;
    float _469 = _467 - _457;
    float _470 = max(0.0f, _469);
    float _471 = _468 * 0.03846153989434242f;
    float _472 = _471 * _470;
    float _473 = _472 + _457;
    float _474 = max(_457, 9.999999717180685e-10f);
    float _475 = 1.0f / _474;
    float _476 = _475 * _452;
    float _477 = _475 * _453;
    float _478 = _475 * _454;
    float _479 = _473 * _475;
    float _480 = max(9.999999717180685e-10f, _479);
    float _481 = abs(_476);
    float _482 = abs(_477);
    float _483 = abs(_478);
    float _484 = log2(_481);
    float _485 = log2(_482);
    float _486 = log2(_483);
    float _487 = _484 * _480;
    float _488 = _485 * _480;
    float _489 = _486 * _480;
    float _490 = exp2(_487);
    float _491 = exp2(_488);
    float _492 = exp2(_489);
    float _493 = CB.ComposeDynamicBindings_Constant_208 * CB.ComposeDynamicBindings_Constant_208;
    float _494 = _493 * 0.03125f;
    bool _495 = (_473 > _494);
    if (_495) {
      float _497 = _494 + CB.ComposeDynamicBindings_Constant_208;
      float _498 = CB.ComposeDynamicBindings_Constant_208 - _494;
      float _499 = _498 + _473;
      float _500 = _493 / _499;
      float _501 = _497 - _500;
      _503 = _501;
    } else {
      _503 = _473;
    }
    float _504 = _503 * _490;
    float _505 = _503 * _491;
    float _506 = _503 * _492;
    float _507 = min(_504, CB.ComposeDynamicBindings_Constant_208);
    float _508 = min(_505, CB.ComposeDynamicBindings_Constant_208);
    float _509 = min(_506, CB.ComposeDynamicBindings_Constant_208);
    _511 = _507;
    _512 = _508;
    _513 = _509;
  } else {
    _511 = _432;
    _512 = _433;
    _513 = _434;
  }
  int _514 = int(CB.ComposeDynamicBindings_Constant_160.w);
  bool _515 = (_514 == 1);
  [branch]
  if (_515) {
    float _517 = abs(_511);
    float _518 = abs(_512);
    float _519 = abs(_513);
    float _520 = log2(_517);
    float _521 = log2(_518);
    float _522 = log2(_519);
    float _523 = _520 * CB.ComposeDynamicBindings_Constant_160.x;
    float _524 = _521 * CB.ComposeDynamicBindings_Constant_160.x;
    float _525 = _522 * CB.ComposeDynamicBindings_Constant_160.x;
    float _526 = exp2(_523);
    float _527 = exp2(_524);
    float _528 = exp2(_525);
    bool _529 = (_526 < 0.003100000089034438f);
    if (_529) {
      float _531 = _526 * 12.920000076293945f;
      _540 = _531;
    } else {
      float _533 = abs(_526);
      float _534 = log2(_533);
      float _535 = _534 * 0.4166666567325592f;
      float _536 = exp2(_535);
      float _537 = _536 * 1.0549999475479126f;
      float _538 = _537 + -0.054999999701976776f;
      _540 = _538;
    }
    bool _541 = (_527 < 0.003100000089034438f);
    if (_541) {
      float _543 = _527 * 12.920000076293945f;
      _552 = _543;
    } else {
      float _545 = abs(_527);
      float _546 = log2(_545);
      float _547 = _546 * 0.4166666567325592f;
      float _548 = exp2(_547);
      float _549 = _548 * 1.0549999475479126f;
      float _550 = _549 + -0.054999999701976776f;
      _552 = _550;
    }
    bool _553 = (_528 < 0.003100000089034438f);
    if (_553) {
      float _555 = _528 * 12.920000076293945f;
      _618 = _540;
      _619 = _552;
      _620 = _555;
    } else {
      float _557 = abs(_528);
      float _558 = log2(_557);
      float _559 = _558 * 0.4166666567325592f;
      float _560 = exp2(_559);
      float _561 = _560 * 1.0549999475479126f;
      float _562 = _561 + -0.054999999701976776f;
      _618 = _540;
      _619 = _552;
      _620 = _562;
    }
  } else {
    bool _564 = (_514 == 2);
    if (_564) {
      // RenoDX replaces the vanilla mode-2 tail (BT.2020 * paper white -> pow(gamma) -> PQ).
      float3 renodx_output = ApplyRenoDXSceneOutput(
          float3(_345, _346, _347),
          t1_space5, s1_heap,
          CB.ComposeDynamicBindings_Constant_056.x,
          CB.ComposeDynamicBindings_Constant_056.y);
      _618 = renodx_output.r;
      _619 = renodx_output.g;
      _620 = renodx_output.b;
    } else {
      _618 = _511;
      _619 = _512;
      _620 = _513;
    }
  }
  SV_Target.x = _618;
  SV_Target.y = _619;
  SV_Target.z = _620;
  SV_Target.w = _431;
  float _621 = dot(float3(_618, _619, _620), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  SV_Target_1 = _621;
  OutputSignature output_signature = { SV_Target, SV_Target_1 };
  return output_signature;
}
