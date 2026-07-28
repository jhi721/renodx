// HFW CE AA/upscale resolver (sampler bound, float scene cap). Body shared with HZDR 0x9C79EDC7.
// HFW takes its sampler from the SM6.6 heap instead of s0/space5.
#define HORIZON_RESOLVER_SAMPLER_HEAP_INDEX 2
#include "../resolvers/aa_resolver_0x9C79EDC7.hlsli"
