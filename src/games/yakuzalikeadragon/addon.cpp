/*
 * Copyright (C) 2026 Hlib Omelchenko
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <embed/shaders.h>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"

namespace {

ShaderInjectData shader_injection;

// Hot-swap the fp16 clone onto this draw's render targets so HDR (>1.0) survives instead of clamping
// into the 8-bit originals (the clone already exists; it must be swapped in per draw).
bool ActivateRenderTargetClones(reshade::api::command_list* cmd_list) {
  auto rtvs = renodx::utils::swapchain::GetRenderTargets(cmd_list);
  bool changed = false;
  for (auto rtv : rtvs) {
    changed = renodx::mods::swapchain::ActivateCloneHotSwap(cmd_list->get_device(), rtv) || changed;
  }
  if (changed) {
    renodx::mods::swapchain::FlushDescriptors(cmd_list);
    renodx::mods::swapchain::RewriteRenderTargets(cmd_list, rtvs.size(), rtvs.data(), {0});
  }
  return true;
}

// True once 0xEE858EE5 ran this frame (reset on present). Pause skips it (alpha-blends a dim overlay
// over the previous frame), so false at the final blit means a non-HDR/pause frame.
bool tonemap_ran_this_frame = false;

// Tone-map pass: flag the HDR path active, then hot-swap.
bool OnDrawToneMap(reshade::api::command_list* cmd_list) {
  tonemap_ran_this_frame = true;
  return ActivateRenderTargetClones(cmd_list);
}

// Final blit: hot-swap only if 0xEE858EE5 ran this frame. On a pause frame the clone is unwritten
// (stale olive), so skip -> the blit reads the original buffer = vanilla SDR pause (pre-HDR behavior).
bool OnDrawFinalBlit(reshade::api::command_list* cmd_list) {
  if (!tonemap_ran_this_frame) return true;
  return ActivateRenderTargetClones(cmd_list);
}

renodx::mods::shader::CustomShaders custom_shaders = {
    // Late HDR composite -> tonemap/color grade -> gamma-2.2 working space with HDR headroom.
    {0xEE858EE5, {.crc32 = 0xEE858EE5, .code = __0xEE858EE5, .on_draw = &OnDrawToneMap}},
    // Pre-final blit (passthrough copy): 0xEE858EE5 output -> b8g8r8a8 buffer read by 0x814A9A6B.
    // Hot-swap this RT to fp16; otherwise the copy clamps the HDR signal right before present.
    {0xB236AEE0, {.crc32 = 0xB236AEE0, .code = __0xB236AEE0, .on_draw = &ActivateRenderTargetClones}},
    // Final blit -> scRGB linear for the HDR swap chain (skips the clone on pause frames).
    {0x814A9A6B, {.crc32 = 0x814A9A6B, .code = __0x814A9A6B, .on_draw = &OnDrawFinalBlit}},
};

float current_settings_mode = 0.f;

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "SettingsMode",
        .binding = &current_settings_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Settings Mode",
        .tooltip = "Simple hides the color grading and fine-tuning controls.",
        .labels = {"Simple", "Advanced"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "toneMapType",
        .binding = &shader_injection.toneMapType,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "Vanilla = native reference (clamped to paper white). Vanilla+ = game's own tone curve "
                   "+ grade, highlights extended to HDR (most faithful).",
        .labels = {"Vanilla", "Vanilla+"},
    },
    new renodx::utils::settings::Setting{
        .key = "toneMapPeakNits",
        .binding = &shader_injection.toneMapPeakNits,
        .default_value = 1000.f,
        .can_reset = true,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits",
        .min = 48.f,
        .max = 4000.f,
        .is_enabled = []() { return shader_injection.toneMapType >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "toneMapGameNits",
        .binding = &shader_injection.toneMapGameNits,
        .default_value = 203.f,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of 100% white in nits",
        .min = 48.f,
        .max = 500.f,
    },
    new renodx::utils::settings::Setting{
        .key = "toneMapGammaCorrection",
        .binding = &shader_injection.toneMapGammaCorrection,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 1.f,
        .label = "Gamma Correction",
        .section = "Tone Mapping",
        .tooltip = "Emulates a display EOTF.",
        .labels = {"Off", "2.2", "BT.1886"},
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "colorGradeLUTStrength",
        .binding = &shader_injection.colorGradeLUTStrength,
        .default_value = 100.f,
        .label = "LUT Strength",
        .section = "Color Grading",
        .tooltip = "Strength of the game's original color grade in HDR.",
        .max = 100.f,
        .is_enabled = []() { return shader_injection.toneMapType >= 1.f; },
        .parse = [](float value) { return value * 0.01f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-1",
        // Single source of truth: each setting's own .default_value. ResetSettings skips can_reset
        // == false (none of ours) and is_global (Settings Mode stays put). Peak resets to the
        // display-seeded default set in OnInitSwapchain, not a stale 1000.
        .on_change = []() { renodx::utils::settings::ResetSettings(); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "RenoDX Discord",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "2fJJMBReAW"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "HDR Den Discord",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x5865F2,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/XUhv", "tR54yc"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "More Mods",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x2B3137,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx/wiki/Mods"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Github",
        .section = "Links",
        .group = "button-line-2",
        .tint = 0x2B3137,
        .on_change = []() { renodx::utils::platform::LaunchURL("https://github.com/clshortfuse/renodx"); },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "Version: " + std::string(renodx::utils::date::ISO_DATE),
        .section = "About",
        .tooltip = std::string(__DATE__),
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "- Requires HDR enabled in Windows display settings.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "- Vanilla+: game's tone curve, highlights extended to HDR.",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "- Peak Brightness = your display's peak nits. Game Brightness = paper-white (100% diffuse).",
        .section = "About",
    },
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSetting("toneMapType", 0.f);
  renodx::utils::settings::UpdateSetting("toneMapPeakNits", 203.f);
  renodx::utils::settings::UpdateSetting("toneMapGameNits", 203.f);
  renodx::utils::settings::UpdateSetting("toneMapGammaCorrection", 0.f);
  renodx::utils::settings::UpdateSetting("colorGradeLUTStrength", 100.f);
}

// Clear the per-frame HDR flag at end of frame (0xEE858EE5 sets it before the blit, present clears
// it for the next). At present, not the blit, to stay correct across the engine's wrapped present.
void OnPresent(
    reshade::api::command_queue* queue,
    reshade::api::swapchain* swapchain,
    const reshade::api::rect* source_rect,
    const reshade::api::rect* dest_rect,
    uint32_t dirty_rect_count,
    const reshade::api::rect* dirty_rects) {
  tonemap_ran_this_frame = false;
}

bool fired_peak_seed = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  // Retarget the fp16 upgrade to the REAL back-buffer aspect (post buffers are back-buffer-sized) so
  // non-16:9 displays match too. Concrete float (not BACK_BUFFER sentinel) keeps the match
  // independent of back_buffer_desc at clone time. Runs before the level-load post buffers; re-run
  // on every resize.
  auto* device = swapchain->get_device();
  auto desc = device->get_resource_desc(swapchain->get_current_back_buffer());
  if (desc.texture.height != 0) {
    const float aspect = static_cast<float>(desc.texture.width) / static_cast<float>(desc.texture.height);
    for (auto& target : renodx::mods::swapchain::swap_chain_upgrade_targets) {
      if (target.new_format == reshade::api::format::r16g16b16a16_typeless) {
        target.aspect_ratio = aspect;
      }
    }
    // OnInitDevice already copied the (stale 16:9) globals into the per-device list the matcher reads;
    // re-push so the corrected aspect lands before the post buffers are created.
    renodx::utils::resource::upgrade::SetUpgradeInfos(device, renodx::mods::swapchain::swap_chain_upgrade_targets);
  }

  // Seed Peak default from display nits, once, only on a swap chain that reports HDR metadata: the
  // transient boot swap chain may have none -> don't pin Peak and block re-seeding from the real one.
  if (fired_peak_seed) return;
  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (!peak.has_value()) return;
  for (auto* setting : settings) {  // by key, not index — a reorder must not retarget this
    if (setting->key == "toneMapPeakNits") {
      setting->default_value = roundf(peak.value());
      break;
    }
  }
  fired_peak_seed = true;
}

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Yakuza: Like a Dragon";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      renodx::mods::shader::force_pipeline_cloning = true;
      renodx::mods::shader::expected_constant_buffer_index = 0u;
      renodx::mods::shader::expected_constant_buffer_space = 50u;

      renodx::mods::swapchain::expected_constant_buffer_index = 0u;
      renodx::mods::swapchain::expected_constant_buffer_space = 50u;

      renodx::mods::swapchain::force_borderless = false;
      renodx::mods::swapchain::prevent_full_screen = true;
      renodx::mods::swapchain::use_resource_cloning = true;
      // No swap-chain proxy: RenoDX resizes the swap chain in place to fp16 scRGB and
      // hot-swaps fp16 clones along the post chain.

      // Upgrade back-buffer-sized color buffers to fp16 by view cloning + hot swap: the original stays
      // r8g8b8a8/b8g8r8a8 (gbuffer passes read it unchanged), the clone is swapped in only on the
      // present path (avoids the in-place reinterpret that corrupted the MSAA gbuffers). Two formats:
      // r8g8b8a8 (post/tone-map buffers) and b8g8r8a8 (swap chain + the 0xB236AEE0 pre-blit buffer).
      // Aspect filter excludes the 32^3 LUTs; the 16:9 here is a pre-swapchain fallback only —
      // OnInitSwapchain overwrites it with the real back-buffer ratio before any post buffer exists.
      // KNOWN-ISSUE (battle 3D chars semi-transparent): a battle Copy into the upgraded
      // r8g8b8a8 clone desyncs it; that clone is indistinguishable from the overworld HDR carrier by
      // every filter, so no config scoping fixes battle without killing overworld HDR.
      for (auto old_format : {reshade::api::format::r8g8b8a8_typeless,
                              reshade::api::format::b8g8r8a8_typeless}) {
        renodx::mods::swapchain::swap_chain_upgrade_targets.push_back({
            .old_format = old_format,
            .new_format = reshade::api::format::r16g16b16a16_typeless,
            .use_resource_view_cloning = true,
            .use_resource_view_hot_swap = true,
            .aspect_ratio = 16.f / 9.f,
        });
      }

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::register_event<reshade::addon_event::present>(OnPresent);
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_addon(h_module);
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
