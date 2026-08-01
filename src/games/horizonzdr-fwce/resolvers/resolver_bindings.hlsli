#ifndef SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_RESOLVER_BINDINGS_HLSLI_
#define SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_RESOLVER_BINDINGS_HLSLI_

// Resource bindings shared by every AA/upscale resolver in both games: identical registers
// and the same seven float4 rows in all ten permutations. The two games differ only in the
// cbuffer struct's debug name (HZDR AAResolverUpscaleParams_Constant, HFW
// AAResolverUpscaleParams), which the layout does not depend on.
//
// The sampler is deliberately absent: three of the five variants bind one and two do not,
// and the two games bind it differently. See the per-variant cores.

Texture2D<float4> t0_space6 : register(t0, space6);

Texture2D<float4> t1_space6 : register(t1, space6);

RWTexture2D<float4> u0_space6 : register(u0, space6);

RWTexture2D<float4> u1_space6 : register(u1, space6);

cbuffer cb0_space5 : register(b0, space5) {
  struct Scratch_PerBatch_Constants {
    struct AAResolverUpscaleParams_Constant {
      float4 AAResolverUpscaleParams_Constant_000;
      float4 AAResolverUpscaleParams_Constant_016;
      float4 AAResolverUpscaleParams_Constant_032;
      float4 AAResolverUpscaleParams_Constant_048;
      float4 AAResolverUpscaleParams_Constant_064;
      float4 AAResolverUpscaleParams_Constant_080;
      float4 AAResolverUpscaleParams_Constant_096;
    } Scratch_PerBatch_Constants_000;
  } Scratch_PerBatch_000 : packoffset(c000.x);
};

#endif  // SRC_GAMES_HORIZONZDR_FWCE_RESOLVERS_RESOLVER_BINDINGS_HLSLI_
