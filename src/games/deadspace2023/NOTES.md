# Dead Space (2023) — RenoDX HDR mod notes

Status: research + initial live RE done (2026-06-02). Greenfield — no upstream RenoDX mod, no
public shader hashes. This file is the durable home for research (with sources) + reverse
engineering. Scratch (dumped .asm/.cso, EXR) lives in `tmp/deadspace2023/`.

---

## SHIPPED ARCHITECTURE — authoritative TL;DR (read this first; details/rationale below)

- **Engine:** Frostbite (Core2 / FB3.0 family, sibling of Mass Effect Andromeda), **D3D12**.
- **Swapchain:** native HDR is **r16g16b16a16_float scRGB (extended_srgb_linear), flip** — we do
  **NOT** upgrade the swapchain, do NOT `SetUseHDR10`, do NOT force borderless. Pure shader replace +
  cb13 injection. (`DllMain`: `force_pipeline_cloning`, `expected_constant_buffer_index=13`,
  `allow_multiple_push_constants`. ps_5_0 shaders → `register(b13)` no space, mirrors MEA.)
- **DevKit limitation (load-bearing):** per-draw capture is DEAD on this engine (`devkit_list_draws`
  only records `Copy` ops — GPU-driven D3D12 / CreateCommandList1; reproduced across borderless,
  fullscreen, and with Streamline removed). All RE is by **tracked-shader bytecode/disassembly**;
  shader replacement (pipeline-cloning) works fine. Live shader iteration via devkit works.
- **Intercepted shaders (3, all ps_5_0, via `CustomShaderEntry`):**
  - `0x2F62371D` — **fused display node**: tonemap + analytic grade (bit1) + UI composite (bit8) +
    SDR (bit16) + 3D-LUT (bit2) + present → scRGB. In HDR only bit1+bit8 run (LUT/SDR off). This is
    THE HDR fix point. Also hosts film grain. (SDR present is a separate node `0x14916506` — NOT
    intercepted; SDR gameplay is left vanilla.)
  - `0x8744747A` — **bloom composite** (`o0 = scene*cb0[3] + bloom*cb0[4]`); Bloom slider scales the
    bloom term (Vanilla+ only).
  - `0xBA22203B` — **uber-post** (barrel distortion + depth fog/flash + vignette); Vignette slider
    lerps the vignette darken-factor to 1.0 (Vanilla+ only); distortion/fog untouched.
- **Tone map (grade-preserving):** `ToneMapDeadSpace(graded)` in shared.h. `graded` = the vanilla
  analytic grade, linear, 0.18=mid, **1.0 = 100-nit diffuse** (vanilla wrote `o0=graded*1.25`).
  - **Vanilla (1):** untouched native; returns `graded*100/diffuse` to cancel pipeline diffuse scaling,
    and `RENODX_SWAP_CHAIN_CLAMP_NITS` is raised to 100000 so Peak does NOT clamp it (uncapped).
  - **SDR (0):** `renodx::tonemap::renodrt::NeutralSDR(graded)`.
  - **Vanilla+ (2):** user grade (`ApplyUserColorGrading`, neutral=no-op) → optional EOTF (default Off)
    → **luminance `ExponentialRollOff`** (slope 1 → mids = authored grade; highlights → Peak) → Hue
    Shift blend toward per-channel. NOT RenoDRT (would re-grade); chosen to preserve the authored look
    (validated as standard by GoW2018/MEA, ExponentialRollOff is used in 80+ repo mods).
  - Output: `RenderIntermediatePass` → [deferred UI composite at graphics-white] → `SwapChainPass`
    (SCRGB preset). Net nits: `tonemapped * diffuse_white_nits / 80`, clamp at Peak (except Vanilla).
- **Settings (MEA-equivalent, minus RCAS):** Settings Mode (Simple/Advanced); Tone Mapping {Tone Mapper
  SDR/Vanilla/Vanilla+, Peak (auto-seeded from display), Game Brightness=diffuse, UI Brightness=graphics,
  SDR EOTF Emulation default Off}; Color Grading {Exposure, Highlights, Shadows, Contrast, Saturation,
  Highlight Saturation, Blowout, Flare, Hue Shift}; Effects {Bloom, Vignette, Film Grain Type
  (Vanilla/Monochrome/Colored), Film Grain}; Options/Links(incl. More Mods)/About.
- **Dropped (not found in capture, not faked):** Chromatic Aberration (no per-channel CA pass — only
  geometric distortion in 0xBA22203B); HDR Videos/FMV (no standalone decode pass — YUV→RGB is fused in
  0x2F62371D). Re-hunt CA in a damage/low-health scene, FMV in a cutscene.
- **Excluded by request:** RCAS / sharpening (no FxSharpness, no fxSwapchainPresent).
- **Build/deploy:** `cmake --build --preset clang-x64-release --target deadspace2023` →
  `renodx-deadspace2023.addon64`; copy into game dir with game CLOSED; only one RenoDX addon active at
  a time (park `renodx-devkit.addon64` as `.bak` when shipping, vice-versa for RE).
- **Status:** FEATURE-COMPLETE & in-game-validated (2026-06-02). Tone map (SDR/Vanilla/Vanilla+) + UI
  + Bloom/Vignette/Film Grain all confirmed; Vanilla peak-clamp fix (v6) confirmed (Peak no longer
  affects Vanilla). Not yet committed to git. Optional later: re-hunt CA (damage scene) + FMV (cutscene).

---

Game dir: `S:\SteamLibrary\steamapps\common\Dead Space (2023)`. ReShade `dxgi.dll` present.
Game ships its own `dxcompiler.dll` → for live shader iteration set devkit tools path to repo
`.\bin`. NVIDIA Streamline (`sl.*.dll`) present (DLSS/Reflex) — not required by the mod.

---

## 1. Engine & API  [confirmed]
- **Frostbite**, FB3.0 family per Wikipedia's engine table (same family as Mass Effect: Andromeda,
  NFS Unbound). Newer branch than MEA — improvements from BF2042 / NFS Unbound; renderer is the
  "Core2" generation (DLL: `Engine.Render.Core2.PlatformPcDx12.dll`). Frosty Tool Suite forks
  share tooling between NFS Unbound and Dead Space (2023) — corroborates engine generation.
  - https://en.wikipedia.org/wiki/Dead_Space_(2023_video_game)
  - https://en.wikipedia.org/wiki/Frostbite_(game_engine)
  - https://ixbt.games/en/news/2023/01/30/dlya-remeika-dead-space-ulucsili-dvizok-frosbite-s-zadelom-na-budushhee.html
  - https://github.com/HarGabt/FrostyToolsuite/tree/1.0.7
- **DirectX 12 only**, no DX11 path. DLSS2 + FSR2 upscaling, RTAO; NVIDIA Streamline integration.
  - https://www.resetera.com/threads/dead-space-remake-pc-system-requirements-revealed-on-its-steam-page-16gb-min-ram-requirement-and-dx12-only.640389/
  - https://www.pcgamingwiki.com/wiki/Dead_Space_(2023)
  - https://www.dsogaming.com/pc-performance-analyses/dead-space-remake-pc-performance-analysis/
- Deferred renderer; shipped with VRS (later toggleable on PC, removed on console after the PS5
  software-VRS-in-darks quality complaints DF documented).
  - https://www.resetera.com/threads/digital-foundry-dead-space-remake-ps5-vs-xbox-series-x-s-current-gen-graphics-and-performance-analysis.684160/
- Launch had notable stutter ("StutterStruggle"). https://www.resetera.com/threads/digital-foundry-dead-space-remake-pc-df-tech-review-the-stutterstruggle-continues.684943/

## 2. Color grading / tone mapping  [confirmed = engine-level; opinion flagged]
- Frostbite color pipeline (canonical talk: **Alex Fry, "High Dynamic Range color grading and
  display in Frostbite", GDC 2017** — often mis-attributed to Lagarde):
  - "Grade once, output many": single **3D-LUT grade** in a wide working space, then per-output
    **display mapping** (SDR / HDR10 / scRGB). ACES *principles*, not literal ACES RRT.
  - Tonemap = an **ad-hoc, hue-preserving "photographic" range compression** (`1 - exp(-x)` style
    above a knee, in ICtCp with desaturate→compress→resaturate), deliberately NOT filmic/ACES.
  - https://www.ea.com/frostbite/news/high-dynamic-range-color-grading-and-display-in-frostbite
  - https://gdcvault.com/play/1024466/High-Dynamic-Range-Color-Grading · https://www.youtube.com/watch?v=7z_EIjNG0pQ
  - deck: https://www.slideshare.net/slideshow/high-dynamic-range-color-grading-and-display-in-frostbite/72997674
- Dead Space's signature dark/desaturated/sickly look is driven by **lighting design (Intensity
  Director)** — dynamic fog/steam/flicker, light/shadow contrast — not a static post LUT.
  - https://www.ea.com/news/inside-dead-space-4-the-intensity-director
- [opinion/community] **SDR path crushes blacks** heavily ("black crush pretty much everywhere",
  flashlight needed where HDR shows detail). https://steamcommunity.com/app/1693980/discussions/0/3770110614225688607/
- No GDC/Frostbite talk specific to Dead Space grading exists publicly; LUT scope (global vs
  per-area) is undocumented — derive live.

## 3. Native HDR — quality & defects (= the fix targets)  [confirmed unless flagged]
- Real native HDR. Toggle in-game / config `GstRender.HDR 1` in
  `%userprofile%\Documents\Dead Space (2023)\settings\steam\ProfileOptions_profile`.
  - https://www.pcgamingwiki.com/wiki/Dead_Space_(2023) · https://ps2bios.gitlab.io/blog/how-to-enable-hdr-on-dead-space-remake/
- **No real calibration:** peak appears fixed (~4000 nits), **no paper-white / peak slider**;
  ignores console system HDR calibration. Only a single Brightness slider 0-100 (default 50,
  ~exposure, non-linear) shared between SDR and HDR.
  - https://www.hdrgamer.com/2023/01/dead-space-remake-hdr-settings.html
  - https://www.ea.com/able/resources/dead-space/dead-space/pc/display-graphics
- KoKlusz HDR Gaming Database analysis (discussion #20): HDR only in windowed mode; uncapped peak;
  **light sources hue-shift unless per-channel tonemapping is applied**; G2.2 looks "omega crushed"
  (no gamma correction recommended); no sRGB/G2.2 EOTF mismatch in HDR; UI ~203 nits, in-game avg
  ~160 nits; calibration image useless.
  - https://github.com/KoKlusz/HDR-Gaming-Database/discussions/20
- [community] HDR widely reported **washed out / raised grey blacks / dim**; **breaks after
  alt-tab** (re-toggle Windows+game HDR to fix); some HDR crash/memory-leak reports. Leave
  **Windows HDR OFF** on PC (game drives HDR). Mixed reports → fragile/config-dependent.
  - https://forums.ea.com/discussions/-/-/7156626 · https://answers.ea.com/t5/Technical-Issues/Dead-Space-Remake-PC-HDR-issue/td-p/12271685
  - https://steamcommunity.com/app/1693980/discussions/0/3770110614223578228/
- Fix targets: (1) restore crushed/raised blacks + shadow detail; (2) replace fixed ~4000-nit
  uncalibratable mapping with user paper-white + peak; (3) per-channel tonemap to kill highlight
  hue shift.

## 4. Post-processing toggles  [confirmed via EA settings + config]
- Film Grain on/off (default ON); Motion Blur slider 0-100 (0=off).
- DoF: Low/High, **cannot be fully disabled in menu** (config `GstRender.AntiAliasingPost 0` /
  `GstRender.AAMode 0`). https://steamcommunity.com/app/1693980/discussions/0/3770110614225746409/
- Chromatic Aberration: **no menu toggle**, config `GstRender.ChromaticAberration 0` (mixed).
  https://steamcommunity.com/app/1693980/discussions/0/600790905291971522/
- Bloom / lens dirt / vignette: present, **no exposed toggles**.
- EA official settings: https://www.ea.com/able/resources/dead-space/dead-space/pc/display-graphics

## 5. Prior art  [confirmed]
- **No RenoDX Dead Space mod** upstream (no `src/games/deadspace*` in clshortfuse/renodx); no public
  hashes/notes. Community brute-forces HDR via **Special K** scRGB injection. Existing Nexus mods are
  SDR ReShades, not native-HDR.
  - https://github.com/clshortfuse/renodx + wiki/Mods · https://www.nexusmods.com/games/deadspace2023
  - https://wiki.special-k.info/en/HDR/Retrofit
- RenoDX has a built-in **Frostbite tonemapper** `src/shaders/tonemap/frostbite.hlsl` (port of the
  Fry talk: `1-exp(-x)` rolloff above knee, ICtCp, hue-preserving max-channel blended with
  per-channel, default hue processor darktable UCS) and a `DICE.hlsl` (Pumbo; luminance-preserving
  `1-exp(-x)` shoulder, OKLab). Closest upstream Frostbite template = `src/games/dai` (Dragon Age
  Inquisition, FB2). Local MEA work (this checkout, branch) = closest FB3 sibling.
  - https://deepwiki.com/clshortfuse/renodx/4.1-tone-mapping-system

## 6. Carry-over from Mass Effect: Andromeda (this repo's FB3 mod)
- Same Frostbite family → strategy/scaffolding transfers (present_core.hlsli, paper-white/roll-off,
  cb13/space50 injection, RenoDX shader lib). **Hashes do NOT transfer** (newer build).
- MEA is **DX11 + r10g10b10a2 HDR10/PQ swapchain**; Dead Space is **DX12 + scRGB fp16** → swapchain
  format upgrade NOT needed here; DllMain swapchain wiring differs.
- Watch the **3D-LUT Texture3D cloning caveat** (over-broad format upgrade → 2D view on cloned 3D
  resource → DEVICE_REMOVED) — constrain upgrade targets if any.

---

## 7. LIVE REVERSE ENGINEERING  [verified from raw disassembly, 2026-06-02]

### DevKit limitation (important)
Per-draw snapshot capture does NOT work on this engine: `devkit_list_draws` only ever records
`Copy` ops, **zero draws/dispatches** — reproduced across borderless, exclusive fullscreen, AND
with Streamline removed. The engine records graphics command lists via a path ReShade's addon
draw/dispatch events don't observe (modern multithreaded D3D12 / `CreateCommandList1` / GPU-driven
on the DIRECT queue; only the COPY queue's streaming copies surface). NOT a borderless or Streamline
issue. Two command queues exist: Type 0 (DIRECT) + Type 3 (COPY). Two `D3D12CreateDevice` calls.
=> RE from **tracked shaders by bytecode/disasm** (works, ~413 tracked). Shader replacement via
pipeline-cloning hooks also works (independent of draw capture) → live iteration + on-screen
validation is fine. (Same blindness likely affects Horizon Zero Dawn — also modern GPU-driven DX12.)

### Swapchain  [confirmed via devkit_status + ReShade.log]
`r16g16b16a16_float`, **scRGB / extended_srgb_linear** (`SetColorSpace1(ColorSpace=1)`), flip model,
3840×2160. Native HDR in windowed/flip (`SetFullscreenState(FALSE)`). **No format upgrade needed.**

### THE display node — `0x2F62371D` (ps_5_0)  [verified; dumped to tmp/deadspace2023/original/]
Single **FUSED** pass: tonemap + grade + UI composite + 3D-LUT + SDR/HDR encode + present → scRGB.
The one interception point for the whole HDR mod.
**[CONFIRMED live interception 2026-06-02]** A live-replacement ps_5_0 (sample t0 + blue wash)
turned the ENTIRE frame blue → we own the final display node, and live shader iteration works on
this engine despite dead draw capture. devkit reports source=File, compiles via repo bin fxc.

Bindings: cbv b0 (9×vec4); SRV **t0=scene**, **t1=UI/overlay**, **t9=Texture3D color LUT**,
**t10=grain/dither 2D**; samplers s0,s1,s2. Output: single SV_Target o0 (scRGB fp16). Fullscreen
(SV_Position + TEXCOORD0).

Flow:
1. `r0 = max(scene_t0,0) * 100` — scene 1.0 ⇒ 100 nits (input paper-white anchor).
2. `r1 = cb0[4].y & {8,1,16,2}` — **runtime branch mask** (NOT compile-time perms, unlike MEA):
   - **bit8** UI composite from t1 (UI brightness `cb0[3].y`, alpha `cb0[3].z`).
   - **bit1** HDR grade: ST.2084 PQ encode/decode roundtrip (clamps neg) + sRGB curve + 3×3
     saturation/contrast matrix driven by `cb0[6]/cb0[7]`; ends `r0 *= 100`. PQ consts present
     exactly: m1=0.159302, c1=0.835938, c2=18.851562, c3=18.6875, 1/m1=6.277395.
   - **bit16** SDR/sRGB: sRGB OETF (12.92, 1/2.4=0.416667, 1.055, -0.055, 0.003131) + YCbCr
     (BT.601) + film-grain dither from t10.
   - **bit2** 3D LUT (t9): Frostbite fp16-bit-pattern index
     `f32tof16 → utof → *cb0[4].z → *0.96875 + 0.015625 → sample_l t9`.
3. **Output `o0.xyz = r0 * 1.25`, o0.w=1** — LINEAR scRGB, no final PQ. `1.25*80nit = 100nit`
   baseline paper white. Anchors (×100 in, ×1.25 out) + cb0[6]/cb0[7]/cb0[8] are the levers for
   paper-white / peak / contrast.

**Scene dynamic range [live false-color probe, 2026-06-02]:** raw scene (t0, pre-×100) bright
sources read ~**1–10** (yellow bucket); no >100 (red) in a normal frame. So scene carries ~1 decade
of highlight headroom above the paper-white anchor — real HDR, not pre-clipped to 1.0. Vanilla
grade/LUT expands this to **~4000 nits** at the swapchain (Lilium HDR analysis on vanilla) = the
uncalibrated "uncapped peak" that clips + hue-shifts on sub-4000-nit displays. => mod target:
per-channel tonemap with USER peak/paper-white replacing the fixed ~4000-nit expansion.

Other Texture3D users (ruled out): `0xE0650F84` = volumetric fog/froxel composite (t12/t13 scatter
volumes); `0x7C46B801` = clustered light-probe / SH volume (t23-t26). Not grading.

### HDR branch decode — DECISIVE [live cb0[4].y probe + asm trace, 2026-06-02]
Live probe (replacement shader reading cb0[4].y and decoding the mask on screen) shows the active
branches in HDR: **bit1 (HDR grade) = ON, bit8 (UI composite) = ON, bit2 (3D LUT) = OFF, bit16 (SDR)
= OFF.** Confirmed t9 reads as exactly 0 to our replacement (the game doesn't bind the LUT in HDR).
=> **The 3D LUT is SDR-only. HDR grade/tone is entirely the analytic bit1 branch.** No baked-LUT
dependency; no need to read t9.

bit1 reduces (the ST.2084 PQ encode↔decode pairs at instr 12-24 and 73-86 are exact identities the
compiler left unfolded — net no-ops that just clamp ≥0):
1. `L = composited scene` (linear; r0*0.01 where r0 = scene*100 [+ bit8 UI]).
2. encode to **sRGB-gamma** of `L*100`.
3. **grade in gamma space**: contrast about 0.5 by `(1 + cb6.w*cb7.z)`, lift `-cb6.w*cb7.w`, a 3x3
   saturation/opponent matrix using `cb6.xyz`, master LERP ungraded↔graded by **`cb6.w`**, then more
   contrast `(1 + cb7.y)` + offset `(cb8.x*cb6.w + cb7.x)`.
4. decode sRGB-gamma → **linear**.
5. output `o0 = linear * 1.25` (scRGB; no PQ; **no tone roll-off → unbounded → the ~4000-nit clip**).
PQ consts (in the no-op pairs): m1=0.159302, c1=0.835938, c2=18.851562, c3=18.6875, 1/m1=6.277395.

**Mod design (settled):** faithfully reproduce bit1 grade + bit8 UI composite, then REPLACE the
naive `*1.25`-to-unbounded with a RenoDX **per-channel roll-off to USER peak + paper-white** (kills
the 4000-nit clip + highlight hue-shift, keeps the vanilla analytic grade/look). MEA-style fix;
start from present_core.hlsli + frostbite.hlsl/DICE.hlsl. No t9, no perm zoo (runtime-flag driven).

### Open / to verify
- [DONE 2026-06-02] Faithful base = 3Dmigoto decompile of the .cso (tmp/deadspace2023/original/
  0x2F62371D.ps_5_0.hlsl), loaded live, **confirmed IDENTICAL to vanilla** → interception + asm
  trace + fxc compile all verified. Decompile is the editable base for the shipping shader.
- [DONE 2026-06-02] Live test: per-channel roll-off to 1000 nits confirmed working ("only highlights
  change", Lilium peak 4000 -> ~790). Concept proven.

### SDR vs HDR grade — MEASURED [2026-06-02]
SDR final present node = **`0x14916506` (ps_5_0)** — a near-twin of the HDR node `0x2F62371D`
(same fused dispatch, same analytic-grade 3x3 matrix 17.8824/43.5161/4.11935 + cb0[6/7/8], same
LUT-indexing recipe; LUT slot t8 vs t9; dumped to tmp/deadspace2023/original/). Replacing
`0x2F62371D` has NO effect in SDR (it is the HDR-only present); SDR uses `0x14916506`.

**Live mask probe on 0x14916506 in SDR gameplay: bit1(analytic)+bit8(UI) ON, bit2(LUT)+bit16(SDR
path) OFF — IDENTICAL to HDR.** => In gameplay, SDR and HDR run the SAME analytic grade; the
colorist **3D LUT is NOT used in normal gameplay in either mode** (forcing the LUT branch gave a
BLACK half because t8 is unbound when bit2 is clear — same as t9 in HDR). The earlier agent guess
"SDR enables the LUT" was WRONG (it was an assumption; the direct probe disproved it).

**Conclusion: SDR↔HDR gameplay grade deviation ≈ ZERO.** Our analytic-faithful HDR mod already
matches the SDR-authored gameplay look. The 3D LUT is situational (menus / scripted scenes where the
game sets bit2) — NOT the base gameplay grade. => No LUT port needed for gameplay (avoids the
SDR-clamp / UpgradeToneMap complication entirely). Open: if a specific LUT-graded scene ever matters,
HDR would deviate there (bit2 off in HDR) — revisit only if observed.

### v2 — CANONICAL renodx::draw REFACTOR [2026-06-02]
Per user "по стандартам проекта": dropped the hand-rolled FinalizeDeadSpace (ExponentialRollOff/÷80)
and moved to the canonical pipeline (model: kingdomcome2/shared.h macro-driven + Witcher3 calling
SwapChainPass directly in the game shader — no proxy needed since our node writes the swapchain).
- shared.h: macro-driven RENODX_* contract. `RENODX_SWAP_CHAIN_OUTPUT_PRESET = SCRGB`,
  `RENODX_INTERMEDIATE_ENCODING = NONE`, `RENODX_TONE_MAP_TYPE = RENO_DRT`. Struct = tone_map_mode +
  peak/diffuse/graphics white + grade suite + gamma_correction.
- Shader 0x2F62371D tail: `ToneMapDeadSpace(r0) -> RenderIntermediatePass -> [deferred UI composite
  at graphics-white] -> SwapChainPass`. `ToneMapDeadSpace`: Vanilla=passthrough, SDR=`renodx::tonemap::
  renodrt::NeutralSDR` (canonical SDR look, == atlasfallen's "RenoDRT NeutralSDR" option), Vanilla+=
  `renodx::draw::ToneMapPass` (RenoDRT HDR).
- Nits chain (verified from draw.hlsl): `final_scRGB = tonemapped * diffuse_white_nits / 80`, clamp at
  peak; intermediate_scaling = diffuse/graphics, swap_chain_scaling_nits = graphics, so UI composited
  at 1.0 in the intermediate space lands at graphics_white_nits. Library handles all scaling.
- SDR-mode research: canonical SDR is EITHER an "Output Mode SDR/HDR" that switches the real swapchain
  (absolum/crimsondesert — NOT us, game owns the swapchain) OR a NeutralSDR tone-map option
  (atlasfallen — our case). We use the latter.
- Settings now canonical: Tone Mapper (SDR/Vanilla/Vanilla+), Peak/Game/UI Brightness, SDR EOTF
  Emulation (default None per KoKlusz), grade suite (exposure/highlights/shadows/contrast/saturation/
  highlight-sat/blowout/flare/hue-shift), Simple/Advanced mode.
- OPEN/verify in-game: brightness calibration (Game Brightness default 203 now, was 100); confirm
  RenoDRT mids ~match vanilla; SDR look; that SwapChainPass-in-node works on this title.

### v3 — GRADE-PRESERVING finalize [2026-06-02, current]
Per user "сохранить авторский грейд" + plan compiled-doodling-origami.md. Kept the canonical
macro-driven shared.h + RenderIntermediatePass + SwapChainPass (scRGB) output, but the Vanilla+ tone
map is now **grade-preserving ExponentialRollOff** (GoW2018/MEA pattern), NOT RenoDRT:
- `ToneMapDeadSpace` Vanilla+: `ApplyUserColorGrading` (neutral=no-op) -> optional EOTF (default Off)
  -> **luminance ExponentialRollOff** (slope 1 below knee = mids/shadows untouched = authored grade
  preserved; highlights -> peak) -> optional Hue Shift blend toward per-channel. Rationale: the
  analytic grade has NO tone compression, so "preserve" = roll off highlights only. RenoDRT would
  re-grade everything (rejected); UpgradeToneMap needs a baked curve to invert (N/A here).
- Vanilla mode returns `graded * 100/diffuse` to CANCEL the pipeline's x diffuse scaling -> exact
  native graded*1.25 (100-nit, uncapped) regardless of the Game Brightness value.
- SDR mode = `renodx::tonemap::renodrt::NeutralSDR` (unchanged).
- Added GammaCorrectHuePreserving + ApplyEotfEmulation helpers (ported from MEA). Removed the no-op
  ToneMapHueCorrection slider.
- Grade suite wired: exposure/highlights/shadows/contrast/saturation -> Create; Blowout -> dechroma;
  Highlight Saturation -> grade blowout; Hue Shift -> per-channel blend.
- Builds clean. Deployed. PENDING in-game validation (see plan Verification): loads/not-black,
  Vanilla+ mids==vanilla + highlights roll to Peak (set 460), mode switching, sliders.

### v4 — MEA-equivalent UI + Film Grain [2026-06-02, current]
Per plan compiled-doodling-origami.md (full MEA UI + Effects minus RCAS). Done so far (offline, no RE):
- **Film Grain** wired in our node: shared.h fields `fxFilmGrainType` (Vanilla/Monochrome/Colored),
  `fxFilmGrain`, `customRandom`; `ApplyFilmGrainDeadSpace` (renodx::effects::ApplyFilmGrain[Colored],
  paper-white-relative) called in 0x2F62371D after ToneMapDeadSpace, Vanilla+ only; addon `OnPresent`
  reseeds customRandom per frame (present event registered); Effects section settings added.
- **UI**: added More Mods link; About has no RCAS credit. Tone Mapping / Color Grading already MEA-like.
- NO RCAS (excluded): no FxSharpness, no fxSwapchainPresent.
### v5 — Effects RE'd + wired (Bloom, Vignette) [2026-06-02]
Phase A shader-hunt (fx-hunter agent, by bytecode signature; draw capture dead). Results:
- **Bloom composite = `0x8744747A`** (ps_5_0): `o0 = scene*cb0[3] + bloom*cb0[4]`. Wired: scale the
  bloom term by `fxBloom` (Vanilla+ only). CRC shader + Bloom slider (default 50=vanilla).
- **Vignette = `0xBA22203B`** (ps_5_0, uber-post = barrel distortion + depth fog/flash + vignette).
  Vignette block instr 81-95: darken factor `r0.x = lerp(cb0[8].x, 1, 1-pow(radius,cb0[7].w))`. Wired:
  `r0.x = lerp(1.0, r0.x, fxVignette)` (Vanilla+ only); distortion/fog kept verbatim. Vignette slider
  (default 50=vanilla). NOTE: this pass ALSO does barrel distortion (cb0[2], NOT chromatic) + a depth
  fog/flash add (cb0[3]) — left untouched.
- **Chromatic Aberration = NOT FOUND** — no per-channel-offset CA pass among tracked shaders (the
  0xBA22203B distortion is geometric, not chromatic). Slider DROPPED. Re-hunt in a damage/low-health
  scene if it ever appears.
- **FMV / HDR Videos = no separate pass** — YUV→RGB is fused in the display node 0x2F62371D (bit16/SDR
  path). No standalone Bink decode pass in this capture. Slider DROPPED. Re-hunt during a cutscene.
- All three CRC shaders (0x2F62371D + 0x8744747A + 0xBA22203B) registered via CustomShaderEntry; build
  clean. shader_injection += fxBloom, fxVignette (+ film-grain fields). Effects section = Bloom,
  Vignette, Film Grain Type, Film Grain. NO RCAS, no CA, no HDR Videos.
- [VALIDATED in-game 2026-06-02] Bloom (0↔50↔100), Vignette (0↔50), Film Grain (Mono/Colored) all
  work; distortion/fog/tonemap intact. Effects feature-complete (minus the dropped CA + HDR Videos).

### v7 — code-review fixes [2026-06-02, deployed] (review: tmp/deadspace2023/code-review.md)
1. EOTF label "BT.1886"→"2.2 (Luminance)" (value 2 is 2.2-on-luminance, not BT.1886) + "2.2"→
   "2.2 (Per Channel)". Truthful labels matching the code path / MEA.
2. Roll-off knee: `min(1,peak*0.5)` → `min(1,0.999*peak)`. Old formula dropped the knee below diffuse
   white when peak<2x game (peak_nits<2x diffuse) → compressed midtones (broke grade-preservation).
   New: knee pinned at diffuse (1.0) for all valid peaks (identical to validated peak>=2 behavior),
   always < peak.
3. SwapChainPass clamp: was `Vanilla?100000:peak` → now `VanillaPlus?peak:100000`. SDR's Peak slider is
   disabled (mode==2) but the clamp still used its stale value → SDR scene/UI crushed to a low Peak.
   Clamp at Peak ONLY in Vanilla+; Vanilla+SDR uncapped (SDR is range-bound by NeutralSDR anyway).
4. Bloom `0x8744747A`: scale rgb only (`r0.xyz *= fxBloom`), not xyzw — keep composite RT alpha = vanilla.
5. Removed dead `tone_map_hue_correction` struct field + RENODX_TONE_MAP_HUE_CORRECTION macro (unused;
   ToneMapDeadSpace hardcodes 0; we don't call ToneMapPass).
DEFERRED: review finding #5 (MEA RCAS center/neighbor mismatch on 0xAFFFA4AB) — separate mod, RCAS
excluded from Dead Space; revisit in an MEA pass. Review "Cleared" items accepted as non-bugs.

### v6 — Vanilla peak-clamp fix [2026-06-02]
BUG (user-reported): in **Vanilla** mode the image was clamped by the **Peak Brightness** slider —
Vanilla should be untouched/uncapped native. Root cause: `renodx::draw::SwapChainPass` clamps the max
channel to `swap_chain_clamp_nits`, whose RenoDX default = `RENODX_PEAK_WHITE_NITS`. Vanilla's
ToneMapDeadSpace is peak-independent otherwise, but this final clamp pinned it to Peak.
FIX (shared.h): `#define RENODX_SWAP_CHAIN_CLAMP_NITS (tone_map_mode == VANILLA ? 100000.f : peak)` —
in Vanilla the clamp is far out of range (effectively uncapped); Vanilla+/SDR still clamp at Peak.
Built + deployed 2026-06-02.

### v1 SHIPPING ADDON [built 2026-06-02, superseded]
Files in src/games/deadspace2023/: addon.cpp, shared.h, 0x2F62371D.ps_5_0.hlsl. Builds clean
(`cmake --build --preset clang-x64-release --target deadspace2023` -> renodx-deadspace2023.addon64).
- Shader = the faithful 3Dmigoto decompile (vanilla logic verbatim) + `#include "./shared.h"`; only
  the final `o0 = 1.25*r0` is replaced with `FinalizeDeadSpace(r0)`.
- shared.h `FinalizeDeadSpace`: Vanilla = `graded * 100/80` (exact passthrough); Vanilla+ =
  per-channel `renodx::tonemap::ExponentialRollOff(graded, rolloffStart, peak)` in paper-white-relative
  units, then `* paperWhite / 80` -> linear scRGB. graded 1.0 == 100-nit diffuse ref.
- addon.cpp: ONE CustomShaderEntry(0x2F62371D); settings Tone Mapper (Vanilla/Vanilla+), Peak
  Brightness, Game Brightness (default 100 = vanilla mids). DllMain: force_pipeline_cloning,
  expected_constant_buffer_index=13 (space default 0, SM5.0 register(b13), mirrors MEA — NOT HZD's
  space50), allow_multiple_push_constants. NO SetUseHDR10, NO swapchain upgrade, NO borderless
  (native scRGB fp16 flip already works). imgui.h must be included BEFORE reshade.hpp (link glue).
- Build gotchas hit: TONE_MAP_* macros are HLSL-only (#ifndef __cplusplus) -> use float literals in
  C++; missing `#include <deps/imgui/imgui.h>` -> undefined ImGui symbols at link.
- [DONE] Non-devkit path validated in-game: addon loads, Vanilla+ tames highlights, sliders work,
  Peak auto-seeds from display HDR metadata. cb b13 injection works on this DX12 SM5.0 title.
- [v1.1 2026-06-02] **UI Brightness** added. The HUD (bit8) is composited into the scene PRE-grade
  in vanilla; in Vanilla+ we now DEFER it: capture t1 color + alpha in the bit8 branch (don't touch
  r0), grade+roll-off the scene alone, then composite the HUD AFTER FinalizeDeadSpace at
  `toneMapUINits/80` (scRGB). HUD stays crisp, independent of Game Brightness and the roll-off.
  Vanilla mode keeps the exact pre-grade composite. t1 treated as LINEAR (game composites it into
  linear scene*100) — verify on screen it's not mis-encoded. Setting: UI Brightness, default 203 nits.
- [v1.2 2026-06-02] **SDR reference mode** added. ToneMapType renumbered to MEA convention:
  **0=SDR, 1=Vanilla, 2=Vanilla+** (default 2). SDR = `saturate(graded)` clamp at diffuse white +
  SDR-on-2.2 EOTF emulation (`gamma::DecodeSafe(srgb::EncodeSafe(c), 2.2)`) scaled to Game Brightness
  -> for A/B-ing the SDR look on the HDR panel. Peak enabled only for Vanilla+(2); Game/UI Brightness
  enabled for SDR or Vanilla+ (!=1). Off preset = Vanilla(1). UI is deferred for SDR + Vanilla+,
  pre-grade-composited only for Vanilla(1).
- [v1.3 2026-06-02] SDR mode highlight handling fixed. A hard `saturate(graded)` flattened the
  HDR-grade's >1.0 highlights to flat white (less detail than native SDR). Switched to the project's
  canonical SDR transform **`renodx::tonemap::renodrt::NeutralSDR(graded)`** (RenoDRT to 100 nits —
  rolls highlights into SDR range with desaturation, keeps bright objects distinguishable), scaled to
  Game Brightness, /80 scRGB. (Canonical pattern confirmed: lib tonemapper = RenoDRT driven by
  peak/game nits; "SDR look" = NeutralSDR, used internally by the upgrade-tonemap path. HZD's
  saturate(graded) is just a vanilla/SDR DEBUG view, not the real SDR look.)
- OPEN: Highlight Saturation control (per-channel roll-off desaturates bright sources toward white —
  expected, but a blowout/highlight-sat slider can restore color). Deferred per user.
- Identify cb0 field meanings live for the grade params (cb6.xyz/.w, cb7.x/.y/.z/.w, cb8.x) — may
  just preserve them verbatim and only re-anchor peak/paper-white.
- Resolution-scale<100% upscale-present variant? (MEA had one.) At native 100% 0x2F62371D is final.
- Not all ~150 pixel shaders disassembled → check for a Resolution-Scale<100% upscale-present
  variant (MEA had a Catmull-Rom bicubic present). At native 100%, `0x2F62371D` is final.
- Confirm whether `0x2F62371D` writes the swapchain directly or an intermediate that's Copy'd.
- UI source / whether a dedicated HUD pass exists (UI composited inside `0x2F62371D` via t1).

### Dumped (scratch) in tmp/deadspace2023/original/
- `0x2F62371D.ps_5_0.cso`, `0x2F62371D.ps_5_0.asm`
