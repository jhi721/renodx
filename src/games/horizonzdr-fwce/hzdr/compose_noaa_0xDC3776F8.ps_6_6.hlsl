// Scene compose pass — no-AA variant. Base of the three compose variants; the FXAA and
// FXAA + sharpen twins differ only in the AA stage.
// Flow: edge blend -> exposure -> grade -> (flag&1 grain) -> (flag&2 rational compressor)
// -> gamma2 3D LUT -> (flag&4 highlight re-expansion + peak clamp) -> encode switch
// Constant_176.w (1=sRGB, 2=BT.2020+PQ). Mode 2 = shared RenoDX path (../common.hlsli).

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
  float _75 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.x * TEXCOORD.x;
  float _76 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.y * TEXCOORD.y;
  float _77 = _75 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.z;
  float _78 = _76 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_000.w;
  float3 _81 = t4_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
  uint _85 = uint(SV_Position.x);
  uint _86 = uint(SV_Position.y);
  float _87 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.z));
  float _88 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.w));
  float _89 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.x));
  float _90 = float((int)(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_096.y));
  int _91 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.x & 31;
  int _92 = Scratch_PerView_000.Scratch_PerView_Constants_000.ComposeStaticBindings_Constant_008.y & 31;
  uint _93 = _85 >> _91;
  uint _94 = _86 >> _92;
  float _95 = float((int)(_93));
  float _96 = float((int)(_94));
  float _97 = max(_95, _89);
  float _98 = min(_97, _87);
  float _99 = min(_95, _89);
  float _100 = max(_99, _98);
  float _101 = max(_96, _90);
  float _102 = min(_101, _88);
  float _103 = min(_96, _90);
  float _104 = max(_103, _102);
  int _105 = int(_100);
  int _106 = int(_104);
  uint _108 = t0_space3.Load(int3(_105, _106, 0));
  bool _110 = (_108.x == 0);
  float _181;
  float _182;
  float _183;
  float _316;
  float _317;
  float _318;
  float _395;
  float _396;
  float _397;
  float _504;
  float _512;
  float _513;
  float _514;
  float _541;
  float _553;
  float _619;
  float _620;
  float _621;
  [branch]
  if (!_110) {
    int _112 = _108.x & 536870912;
    bool _113 = (_112 == 0);
    if (!_113) {
      float4 _117 = t5_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
      _181 = _117.x;
      _182 = _117.y;
      _183 = _117.z;
    } else {
      int _122 = _108.x & 268435456;
      bool _123 = (_122 == 0);
      float3 _125 = t6_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
      if (_123) {
        float _131 = t1_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
        float _133 = _131.x * 12.0f;
        float _134 = max(_133, -12.0f);
        float _135 = min(_134, 12.0f);
        float _136 = min(_133, -12.0f);
        float _137 = max(_136, _135);
        float _139 = t2_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
        float _141 = _137 + -3.0f;
        float _142 = saturate(_141);
        float _143 = _142 * 2.0f;
        float _144 = 3.0f - _143;
        float _145 = _142 * _142;
        float _146 = _145 * _144;
        float _147 = _125.x - _81.x;
        float _148 = _125.y - _81.y;
        float _149 = _125.z - _81.z;
        float _150 = _147 * _146;
        float _151 = _148 * _146;
        float _152 = _149 * _146;
        float _153 = _150 + _81.x;
        float _154 = _151 + _81.y;
        float _155 = _152 + _81.z;
        float4 _157 = t5_space3.Sample(s0_space3, float2(TEXCOORD.x, TEXCOORD.y));
        bool _161 = (_157.x > 0.0f);
        bool _162 = (_157.y > 0.0f);
        bool _163 = (_157.z > 0.0f);
        bool _164 = _161 || _162;
        bool _165 = _163 || _164;
        if (_165) {
          float4 _167 = t5_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
          float _171 = _167.x - _153;
          float _172 = _167.y - _154;
          float _173 = _167.z - _155;
          float _174 = _171 * _139.x;
          float _175 = _172 * _139.x;
          float _176 = _173 * _139.x;
          float _177 = _174 + _153;
          float _178 = _175 + _154;
          float _179 = _176 + _155;
          _181 = _177;
          _182 = _178;
          _183 = _179;
        } else {
          _181 = _153;
          _182 = _154;
          _183 = _155;
        }
      } else {
        _181 = _125.x;
        _182 = _125.y;
        _183 = _125.z;
      }
    }
  } else {
    _181 = _81.x;
    _182 = _81.y;
    _183 = _81.z;
  }
  float _185 = t0_space5.Load(2);
  float4 _189 = t7_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
  float3 _194 = t8_space3.Sample(s1_space3, float2(TEXCOORD.x, TEXCOORD.y));
  float _198 = _189.x * _189.x;
  float _199 = _189.y * _189.y;
  float _200 = _189.z * _189.z;
  float _201 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.y * 0.25f;
  float _202 = _181 * _201;
  float _203 = _182 * _201;
  float _204 = _183 * _201;
  float _205 = dot(float3(_202, _203, _204), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _206 = _205 + 9.999999974752427e-07f;
  float _207 = saturate(_206);
  float _208 = 1.0f - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _209 = _207 * _208;
  float _210 = _209 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
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
  float _226 = _223 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _227 = _224 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _228 = _225 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.w;
  float _229 = _198 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _230 = _199 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _231 = _200 / Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _232 = _185.x * 4.0f;
  float _233 = _185.x + 0.25f;
  float _234 = _232 / _233;
  float _235 = _229 * _226;
  float _236 = _230 * _227;
  float _237 = _231 * _228;
  float _238 = max(_185.x, 1.0000000031710769e-30f);
  float _239 = _235 / _238;
  float _240 = _236 / _238;
  float _241 = _237 / _238;
  float _242 = sqrt(_239);
  float _243 = sqrt(_240);
  float _244 = sqrt(_241);
  float _245 = _242 * _234;
  float _246 = _243 * _234;
  float _247 = _244 * _234;
  float _248 = _185.x + 1.0f;
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
  float _264 = _261 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _265 = _262 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _266 = _263 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.w;
  float _267 = _264 + _260;
  float _268 = _265 + _260;
  float _269 = _266 + _260;
  float _270 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.x;
  float _271 = _270 * _267;
  float _272 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.y;
  float _273 = _272 * _268;
  float _274 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.x * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_032.z;
  float _275 = _274 * _269;
  float _276 = _271 + _253;
  float _277 = _273 + _256;
  float _278 = _275 + _259;
  float _279 = _276 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.x;
  float _280 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.x - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.y;
  float _281 = _277 * _280;
  float _282 = _279 + _281;
  float _283 = _282 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _284 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.y;
  float _285 = _284 * _277;
  float _286 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_160.z;
  float _287 = _286 * _278;
  int _288 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 1;
  bool _289 = (_288 == 0);
  [branch]
  if (!_289) {
    int _292 = asint(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.z);
    int _293 = _292 & 65535;
    float _294 = float((uint)_293);
    float _295 = _294 * 1.52587890625e-05f;
    int _296 = (uint)(_292) >> 16;
    float _297 = float((uint)_296);
    float _298 = _297 * 1.52587890625e-05f;
    float _299 = _77 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.x;
    float _300 = _78 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_080.y;
    float _301 = _299 + _295;
    float _302 = _300 + _298;
    float2 _305 = t10_space3.Sample(s2_space3, float2(_301, _302));
    float _307 = _305.y + -0.5f;
    float _308 = _307 * _189.w;
    float _309 = _308 + _283;
    float _310 = _308 + _285;
    float _311 = _308 + _287;
    float _312 = max(_309, 0.0f);
    float _313 = max(_310, 0.0f);
    float _314 = max(_311, 0.0f);
    _316 = _312;
    _317 = _313;
    _318 = _314;
  } else {
    _316 = _283;
    _317 = _285;
    _318 = _287;
  }
  float _319 = _250 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_192.z;
  float _320 = _319 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.x;
  float _321 = _319 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.y;
  float _322 = _319 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.z;
  float _323 = _77 * 2.0f;
  float _324 = _78 * 2.0f;
  float _325 = _323 + -1.0f;
  float _326 = _324 + -1.0f;
  float _327 = _325 * _325;
  float _328 = _326 * _326;
  float _329 = _328 + _327;
  float _330 = sqrt(_329);
  float _331 = _330 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_064.x;
  float _332 = _331 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_064.y;
  float _333 = saturate(_332);
  float _334 = _333 * _333;
  float _335 = _334 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_048.w;
  _335 *= injectedData.fx_vignette;  // RenoDX vignette strength, 1.0 = vanilla
  float _336 = 1.0f - _335;
  float _337 = _336 * _316;
  float _338 = _336 * _317;
  float _339 = _336 * _318;
  float _340 = _320 * _335;
  float _341 = _321 * _335;
  float _342 = _322 * _335;
  float _343 = _337 + _340;
  float _344 = _338 + _341;
  float _345 = _339 + _342;
  float _346 = max(_343, 9.999999974752427e-07f);
  float _347 = max(_344, 9.999999974752427e-07f);
  float _348 = max(_345, 9.999999974752427e-07f);
  float _349 = dot(float3(_346, _347, _348), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  int _350 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 2;
  bool _351 = (_350 == 0);
  if (!_351) {
    float _353 = max(_346, 0.0f);
    float _354 = max(_347, 0.0f);
    float _355 = max(_348, 0.0f);
    float _356 = _353 * 0.9455959796905518f;
    float _357 = mad(0.045505501329898834f, _354, _356);
    float _358 = mad(0.008898990228772163f, _355, _357);
    float _359 = _353 * 0.014694600366055965f;
    float _360 = mad(0.967956006526947f, _354, _359);
    float _361 = mad(0.017349300906062126f, _355, _360);
    float _362 = _353 * 0.005567430052906275f;
    float _363 = mad(0.020142799243330956f, _354, _362);
    float _364 = mad(0.9742900133132935f, _355, _363);
    float _365 = dot(float3(0.21321800351142883f, 0.7275890111923218f, 0.059193599969148636f), float3(_358, _361, _364));
    float _366 = _365 + 1.0f;
    float _367 = _366 * _358;
    float _368 = _366 * _361;
    float _369 = _366 * _364;
    float _370 = _367 + 1.0f;
    float _371 = _368 + 1.0f;
    float _372 = _369 + 1.0f;
    float _373 = _370 * _358;
    float _374 = _371 * _361;
    float _375 = _372 * _364;
    float _376 = _373 + _366;
    float _377 = _374 + _366;
    float _378 = _375 + _366;
    float _379 = _373 / _376;
    float _380 = _374 / _377;
    float _381 = _375 / _378;
    float _382 = _379 * 1.058359980583191f;
    float _383 = mad(-0.049572598189115524f, _380, _382);
    float _384 = mad(-0.008784100413322449f, _381, _383);
    float _385 = _379 * -0.015964500606060028f;
    float _386 = mad(1.0342400074005127f, _380, _385);
    float _387 = mad(-0.01827090047299862f, _381, _386);
    float _388 = _379 * -0.00571777019649744f;
    float _389 = mad(-0.021098900586366653f, _380, _388);
    float _390 = mad(1.0268199443817139f, _381, _389);
    float _391 = max(_384, 0.0f);
    float _392 = max(_387, 0.0f);
    float _393 = max(_390, 0.0f);
    _395 = _391;
    _396 = _392;
    _397 = _393;
  } else {
    _395 = _346;
    _396 = _347;
    _397 = _348;
  }
  float _398 = dot(float3(_395, _396, _397), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _399 = max(_395, 0.0f);
  float _400 = max(_396, 0.0f);
  float _401 = max(_397, 0.0f);
  float _402 = sqrt(_399);
  float _403 = sqrt(_400);
  float _404 = sqrt(_401);
  float _405 = saturate(_402);
  float _406 = saturate(_403);
  float _407 = saturate(_404);
  float _408 = _405 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _409 = _406 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _410 = _407 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x;
  float _411 = _408 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float _412 = _409 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float _413 = _410 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y;
  float3 _415 = t1_space5.SampleLevel(s1_space3, float3(_411, _412, _413), 0.0f);
  float _419 = _415.x * _415.x;
  float _420 = _415.y * _415.y;
  float _421 = _415.z * _415.z;
  float _422 = _398 + 9.999999960041972e-13f;
  float _423 = _349 / _422;
  float _424 = max(_423, 0.0f);
  float _425 = _424 + -1.0f;
  float _426 = _425 * 0.03999999910593033f;
  float _427 = saturate(_426);
  float _428 = dot(float3(_419, _420, _421), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  float _429 = _428 * 8.0f;
  float _430 = _429 + -4.0f;
  float _431 = saturate(_430);
  float _432 = _431 * _427;
  float _433 = saturate(_419);
  float _434 = saturate(_420);
  float _435 = saturate(_421);
  int _436 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_016 & 4;
  bool _437 = (_436 == 0);
  [branch]
  if (!_437) {
    float _439 = _433 * _433;
    float _440 = _434 * _434;
    float _441 = _435 * _435;
    float _442 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _443 = _439 + _442;
    float _444 = _440 + _442;
    float _445 = _441 + _442;
    float _446 = sqrt(_443);
    float _447 = sqrt(_444);
    float _448 = sqrt(_445);
    float _449 = _446 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _450 = _447 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _451 = _448 - Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220;
    float _452 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_220 + 1.0f;
    float _453 = _449 * _452;
    float _454 = _450 * _452;
    float _455 = _451 * _452;
    float _456 = max(1.0f, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_216);
    float _457 = dot(float3(_453, _454, _455), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
    float _458 = saturate(_457);
    float _459 = _458 + -0.5f;
    float _460 = saturate(_459);
    float _461 = _458 * 0.5f;
    float _462 = 1.0f - _461;
    float _463 = 1.0f / _462;
    float _464 = _432 * 100.0f;
    float _465 = _460 * _460;
    float _466 = _465 * _464;
    float _467 = _466 + _463;
    float _468 = _467 * _458;
    float _469 = _456 + -1.0f;
    float _470 = _468 - _458;
    float _471 = max(0.0f, _470);
    float _472 = _469 * 0.03846153989434242f;
    float _473 = _472 * _471;
    float _474 = _473 + _458;
    float _475 = max(_458, 9.999999717180685e-10f);
    float _476 = 1.0f / _475;
    float _477 = _476 * _453;
    float _478 = _476 * _454;
    float _479 = _476 * _455;
    float _480 = _474 * _476;
    float _481 = max(9.999999717180685e-10f, _480);
    float _482 = abs(_477);
    float _483 = abs(_478);
    float _484 = abs(_479);
    float _485 = log2(_482);
    float _486 = log2(_483);
    float _487 = log2(_484);
    float _488 = _485 * _481;
    float _489 = _486 * _481;
    float _490 = _487 * _481;
    float _491 = exp2(_488);
    float _492 = exp2(_489);
    float _493 = exp2(_490);
    float _494 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224;
    float _495 = _494 * 0.03125f;
    bool _496 = (_474 > _495);
    if (_496) {
      float _498 = _495 + Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224;
      float _499 = Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224 - _495;
      float _500 = _499 + _474;
      float _501 = _494 / _500;
      float _502 = _498 - _501;
      _504 = _502;
    } else {
      _504 = _474;
    }
    float _505 = _504 * _491;
    float _506 = _504 * _492;
    float _507 = _504 * _493;
    float _508 = min(_505, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    float _509 = min(_506, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    float _510 = min(_507, Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_224);
    _512 = _508;
    _513 = _509;
    _514 = _510;
  } else {
    _512 = _433;
    _513 = _434;
    _514 = _435;
  }
  int _515 = int(Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.w);
  bool _516 = (_515 == 1);
  [branch]
  if (_516) {
    float _518 = abs(_512);
    float _519 = abs(_513);
    float _520 = abs(_514);
    float _521 = log2(_518);
    float _522 = log2(_519);
    float _523 = log2(_520);
    float _524 = _521 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _525 = _522 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _526 = _523 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
    float _527 = exp2(_524);
    float _528 = exp2(_525);
    float _529 = exp2(_526);
    bool _530 = (_527 < 0.003100000089034438f);
    if (_530) {
      float _532 = _527 * 12.920000076293945f;
      _541 = _532;
    } else {
      float _534 = abs(_527);
      float _535 = log2(_534);
      float _536 = _535 * 0.4166666567325592f;
      float _537 = exp2(_536);
      float _538 = _537 * 1.0549999475479126f;
      float _539 = _538 + -0.054999999701976776f;
      _541 = _539;
    }
    bool _542 = (_528 < 0.003100000089034438f);
    if (_542) {
      float _544 = _528 * 12.920000076293945f;
      _553 = _544;
    } else {
      float _546 = abs(_528);
      float _547 = log2(_546);
      float _548 = _547 * 0.4166666567325592f;
      float _549 = exp2(_548);
      float _550 = _549 * 1.0549999475479126f;
      float _551 = _550 + -0.054999999701976776f;
      _553 = _551;
    }
    bool _554 = (_529 < 0.003100000089034438f);
    if (_554) {
      float _556 = _529 * 12.920000076293945f;
      _619 = _541;
      _620 = _553;
      _621 = _556;
    } else {
      float _558 = abs(_529);
      float _559 = log2(_558);
      float _560 = _559 * 0.4166666567325592f;
      float _561 = exp2(_560);
      float _562 = _561 * 1.0549999475479126f;
      float _563 = _562 + -0.054999999701976776f;
      _619 = _541;
      _620 = _553;
      _621 = _563;
    }
  } else {
    bool _565 = (_515 == 2);
    if (_565) {
#if 1
      // renodx
      float3 renodx_output = ApplyRenoDXSceneOutput(
          float3(_346, _347, _348),
          t1_space5, s1_space3,
          Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.x,
          Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_072.y);
      _619 = renodx_output.r;
      _620 = renodx_output.g;
      _621 = renodx_output.b;
#else
      // vanilla
      float _567 = _512 * 0.6274039149284363f;
      float _568 = mad(0.3292830288410187f, _513, _567);
      float _569 = mad(0.04331306740641594f, _514, _568);
      float _570 = _512 * 0.06909728795289993f;
      float _571 = mad(0.9195404052734375f, _513, _570);
      float _572 = mad(0.011362316086888313f, _514, _571);
      float _573 = _512 * 0.016391439363360405f;
      float _574 = mad(0.08801330626010895f, _513, _573);
      float _575 = mad(0.8955952525138855f, _514, _574);
      float _576 = _569 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _577 = _572 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _578 = _575 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.y;
      float _579 = abs(_576);
      float _580 = abs(_577);
      float _581 = abs(_578);
      float _582 = log2(_579);
      float _583 = log2(_580);
      float _584 = log2(_581);
      float _585 = _582 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _586 = _583 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _587 = _584 * Scratch_PerBatch_000.Scratch_PerBatch_Constants_000.ComposeDynamicBindings_Constant_176.x;
      float _588 = exp2(_585);
      float _589 = exp2(_586);
      float _590 = exp2(_587);
      float _591 = _588 * 18.8515625f;
      float _592 = _591 + 0.8359375f;
      float _593 = _588 * 18.6875f;
      float _594 = _593 + 1.0f;
      float _595 = _592 / _594;
      float _596 = abs(_595);
      float _597 = log2(_596);
      float _598 = _597 * 78.84375f;
      float _599 = exp2(_598);
      float _600 = _589 * 18.8515625f;
      float _601 = _600 + 0.8359375f;
      float _602 = _589 * 18.6875f;
      float _603 = _602 + 1.0f;
      float _604 = _601 / _603;
      float _605 = abs(_604);
      float _606 = log2(_605);
      float _607 = _606 * 78.84375f;
      float _608 = exp2(_607);
      float _609 = _590 * 18.8515625f;
      float _610 = _609 + 0.8359375f;
      float _611 = _590 * 18.6875f;
      float _612 = _611 + 1.0f;
      float _613 = _610 / _612;
      float _614 = abs(_613);
      float _615 = log2(_614);
      float _616 = _615 * 78.84375f;
      float _617 = exp2(_616);
      _619 = _599;
      _620 = _608;
      _621 = _617;
#endif
    } else {
      _619 = _512;
      _620 = _513;
      _621 = _514;
    }
  }
  SV_Target.x = _619;
  SV_Target.y = _620;
  SV_Target.z = _621;
  SV_Target.w = _432;
  float _622 = dot(float3(_619, _620, _621), float3(0.2125999927520752f, 0.7152000069618225f, 0.0722000002861023f));
  SV_Target_1 = _622;
  OutputSignature output_signature = { SV_Target, SV_Target_1 };
  return output_signature;
}
