/*
 * Copyright (C) 2026 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <random>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {

ShaderInjectData shader_injection;

// Dead Space (2023) fuses tonemap + grade + UI composite + present into ONE pixel shader. In HDR
// only the analytic grade (bit1) + UI composite (bit8) run; the 3D LUT (bit2) and SDR (bit16) paths
// are off (live-confirmed, see NOTES.md). One entry covers everything; branch selection is runtime.
renodx::mods::shader::CustomShaders custom_shaders = {
    CustomShaderEntry(0x2F62371D),  // fused display node (grade + UI + present -> scRGB) + film grain
    CustomShaderEntry(0x8744747A),  // bloom composite (scene + bloom) -> Bloom slider
    CustomShaderEntry(0xBA22203B),  // uber-post (distortion/fog/vignette) -> Vignette slider
};

float current_settings_mode = 0;

renodx::utils::settings::Settings settings = {
    new renodx::utils::settings::Setting{
        .key = "SettingsMode",
        .binding = &current_settings_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .can_reset = false,
        .label = "Settings Mode",
        .tooltip = "Simple hides the advanced color grading controls.",
        .labels = {"Simple", "Advanced"},
        .is_global = true,
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapMode",
        .binding = &shader_injection.tone_map_mode,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 2.f,
        .label = "Tone Mapper",
        .section = "Tone Mapping",
        .tooltip = "SDR = the game's SDR look on your HDR panel (RenoDRT NeutralSDR, for comparison). "
                   "Vanilla = untouched native passthrough. "
                   "Vanilla+ = RenoDRT HDR tone map (paper white + highlight roll-off + grading).",
        .labels = {"SDR", "Vanilla", "Vanilla+"},
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapPeakNits",
        .binding = &shader_injection.peak_white_nits,
        .default_value = 1000.f,
        .can_reset = true,
        .label = "Peak Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of peak white in nits. Set to your display's peak brightness.",
        .min = 48.f,
        .max = 4000.f,
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },  // Vanilla+
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapGameNits",
        .binding = &shader_injection.diffuse_white_nits,
        .default_value = 203.f,
        .can_reset = true,
        .label = "Game Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the value of 100% diffuse white in nits.",
        .min = 48.f,
        .max = 500.f,
        .is_enabled = []() { return shader_injection.tone_map_mode != 1.f; },  // SDR or Vanilla+
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapUINits",
        .binding = &shader_injection.graphics_white_nits,
        .default_value = 203.f,
        .can_reset = true,
        .label = "UI Brightness",
        .section = "Tone Mapping",
        .tooltip = "Sets the brightness of UI / HUD elements in nits.",
        .min = 48.f,
        .max = 500.f,
        .is_enabled = []() { return shader_injection.tone_map_mode != 1.f; },  // SDR or Vanilla+
    },
    new renodx::utils::settings::Setting{
        .key = "GammaCorrection",
        .binding = &shader_injection.gamma_correction,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "SDR EOTF Emulation",
        .section = "Tone Mapping",
        .tooltip = "Emulates an SDR display decode. Default Off: this title has no sRGB/2.2 mismatch in "
                   "HDR (2.2 would crush blacks).",
        .labels = {"None", "2.2 (Per Channel)", "2.2 (Luminance)"},
        .is_enabled = []() { return shader_injection.tone_map_mode != 1.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapExposure",
        .binding = &shader_injection.tone_map_exposure,
        .default_value = 1.f,
        .label = "Exposure",
        .section = "Color Grading",
        .tooltip = "Scene exposure. 1.0 = neutral.",
        .min = 0.25f,
        .max = 4.f,
        .format = "%.2f",
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHighlights",
        .binding = &shader_injection.tone_map_highlights,
        .default_value = 50.f,
        .label = "Highlights",
        .section = "Color Grading",
        .tooltip = "Adjusts highlight brightness. 50 = neutral.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapShadows",
        .binding = &shader_injection.tone_map_shadows,
        .default_value = 50.f,
        .label = "Shadows",
        .section = "Color Grading",
        .tooltip = "Adjusts shadow brightness. 50 = neutral.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapContrast",
        .binding = &shader_injection.tone_map_contrast,
        .default_value = 50.f,
        .label = "Contrast",
        .section = "Color Grading",
        .tooltip = "Adjusts contrast. 50 = neutral.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapSaturation",
        .binding = &shader_injection.tone_map_saturation,
        .default_value = 50.f,
        .label = "Saturation",
        .section = "Color Grading",
        .tooltip = "Adjusts overall saturation. 50 = neutral.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHighlightSaturation",
        .binding = &shader_injection.tone_map_highlight_saturation,
        .default_value = 50.f,
        .label = "Highlight Saturation",
        .section = "Color Grading",
        .tooltip = "Adds or removes color from highlights (per-channel roll-off desaturates toward white).",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapBlowout",
        .binding = &shader_injection.tone_map_blowout,
        .default_value = 0.f,
        .label = "Blowout",
        .section = "Color Grading",
        .tooltip = "Highlight dechroma (desaturate bright highlights toward white).",
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapFlare",
        .binding = &shader_injection.tone_map_flare,
        .default_value = 0.f,
        .label = "Flare",
        .section = "Color Grading",
        .tooltip = "Black-floor flare / glare compensation.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "ToneMapHueShift",
        .binding = &shader_injection.tone_map_hue_shift,
        .default_value = 0.f,
        .label = "Hue Shift",
        .section = "Color Grading",
        .tooltip = "Shifts highlight hue toward the per-channel (SDR-display) look. 0 = neutral.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxBloom",
        .binding = &shader_injection.fxBloom,
        .default_value = 50.f,
        .label = "Bloom",
        .section = "Effects",
        .tooltip = "Scales the game's bloom. 50 = vanilla, 0 = off.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxVignette",
        .binding = &shader_injection.fxVignette,
        .default_value = 50.f,
        .label = "Vignette",
        .section = "Effects",
        .tooltip = "Scales the game's vignette. 50 = vanilla, 0 = off.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.02f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrainType",
        .binding = &shader_injection.fxFilmGrainType,
        .value_type = renodx::utils::settings::SettingValueType::INTEGER,
        .default_value = 0.f,
        .label = "Film Grain Type",
        .section = "Effects",
        .tooltip = "Vanilla keeps the game's own grain. Monochrome / Colored use RenoDX perceptual "
                   "grain (reduces banding).",
        .labels = {"Vanilla", "Monochrome", "Colored"},
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .key = "FxFilmGrain",
        .binding = &shader_injection.fxFilmGrain,
        .default_value = 50.f,
        .label = "Film Grain",
        .section = "Effects",
        .tooltip = "Perceptual film grain strength. Reduces banding.",
        .max = 100.f,
        .parse = [](float value) { return value * 0.01f; },
        .is_enabled = []() { return shader_injection.tone_map_mode == 2.f && shader_injection.fxFilmGrainType != 0.f; },
        .is_visible = []() { return current_settings_mode >= 1.f; },
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::BUTTON,
        .label = "Reset All",
        .section = "Options",
        .group = "button-line-1",
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
        .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "qVSPcABQF4"); },
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
        .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "- Requires HDR enabled in-game (and Windows HDR on).",
        .section = "About",
    },
    new renodx::utils::settings::Setting{
        .value_type = renodx::utils::settings::SettingValueType::TEXT,
        .label = "- Vanilla = untouched native (other controls disabled).",
        .section = "About",
    },
};

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapMode", 1.f},  // Off preset = Vanilla (pure native passthrough)
      {"ToneMapPeakNits", 1000.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"GammaCorrection", 0.f},
      {"ToneMapExposure", 1.f},
      {"ToneMapHighlights", 50.f},
      {"ToneMapShadows", 50.f},
      {"ToneMapContrast", 50.f},
      {"ToneMapSaturation", 50.f},
      {"ToneMapHighlightSaturation", 50.f},
      {"ToneMapBlowout", 0.f},
      {"ToneMapFlare", 0.f},
      {"ToneMapHueShift", 0.f},
      {"FxBloom", 50.f},
      {"FxVignette", 50.f},
      {"FxFilmGrainType", 0.f},
      {"FxFilmGrain", 50.f},
  });
}

// Feed a fresh per-frame random seed for the perceptual film grain (TW3/MEA pattern).
void OnPresent(
    reshade::api::command_queue* queue,
    reshade::api::swapchain* swapchain,
    const reshade::api::rect* source_rect,
    const reshade::api::rect* dest_rect,
    uint32_t dirty_rect_count,
    const reshade::api::rect* dirty_rects) {
  static std::mt19937 random_generator(std::random_device{}());
  static const auto random_range = static_cast<float>(std::mt19937::max() - std::mt19937::min());
  shader_injection.customRandom = static_cast<float>(random_generator() - std::mt19937::min()) / random_range;
}

bool fired_on_init_swapchain = false;

// Seed the Peak Brightness default from the display's HDR metadata (keyed lookup, not a fixed index).
void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  if (fired_on_init_swapchain) return;
  fired_on_init_swapchain = true;
  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  auto* peak_setting = renodx::utils::settings::FindSetting("ToneMapPeakNits");
  if (peak_setting != nullptr) {
    peak_setting->default_value = peak.has_value() ? roundf(peak.value()) : 1000.f;
  }
}

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX Native HDR Fix for Dead Space (2023)";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;

        // Native HDR is ALREADY r16g16b16a16_float scRGB (extended_srgb_linear), flip-model.
        // No swapchain upgrade, no SetUseHDR10, no borderless — just replace the fused node and
        // inject settings. Output is produced via renodx::draw::SwapChainPass (SCRGB preset).

        initialized = true;
      }

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);  // seed peak default
      reshade::register_event<reshade::addon_event::present>(OnPresent);                // per-frame grain seed

      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::swapchain::Use(fdw_reason, &shader_injection);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
