/*
 * Copyright (C) 2026 Hlib Omelchenko
 * Copyright (C) 2025 Carlos Lopez
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <string>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../templates/settings.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/random.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {

renodx::mods::shader::CustomShaders custom_shaders = {
    __ALL_CUSTOM_SHADERS,
};

ShaderInjectData shader_injection;

bool IsToneMapped() { return shader_injection.tone_map_type != 0.f; }

renodx::utils::settings::Settings settings = renodx::templates::settings::JoinSettings({
    renodx::templates::settings::CreateDefaultSettings({
        {"ToneMapType",
         {.binding = &shader_injection.tone_map_type,
          .labels = {"Vanilla", "PsychoV-30"},
          // Stock parse is `value * 3.f`, sized for the template's three labels; this control has two.
          .parse = [](float value) { return value; }}},
        {"ToneMapPeakNits", {.binding = &shader_injection.peak_white_nits, .is_enabled = IsToneMapped}},
        {"ToneMapGameNits", {.binding = &shader_injection.diffuse_white_nits, .is_enabled = IsToneMapped}},
        {"ToneMapUINits", {.binding = &shader_injection.graphics_white_nits, .is_enabled = IsToneMapped}},
        {"SceneGradeStrength", {.binding = &shader_injection.scene_grade_strength, .is_enabled = IsToneMapped}},
        {"ColorGradeExposure", {.binding = &shader_injection.tone_map_exposure, .is_enabled = IsToneMapped}},
        {"ColorGradeHighlights", {.binding = &shader_injection.tone_map_highlights, .is_enabled = IsToneMapped}},
        {"ColorGradeShadows", {.binding = &shader_injection.tone_map_shadows, .is_enabled = IsToneMapped}},
        {"ColorGradeContrast", {.binding = &shader_injection.tone_map_contrast, .is_enabled = IsToneMapped}},
        {"ColorGradeSaturation", {.binding = &shader_injection.tone_map_saturation, .is_enabled = IsToneMapped}},
    }),

    {
        renodx::templates::settings::CreateSetting({
            renodx::templates::settings::VISIBLE_INTERMEDIATE_CONFIG,
            {
                .key = "colorGradeLUTSampling",
                .binding = &shader_injection.custom_lut_sampling,
                .value_type = renodx::utils::settings::SettingValueType::INTEGER,
                .default_value = 1.f,
                .label = "LUT Sampling",
                .section = "Color Grading",
                .labels = {"Trilinear", "Tetrahedral"},
                .is_enabled = IsToneMapped,
            },
        }),

        renodx::templates::settings::CreateSetting({
            renodx::templates::settings::FX_BLOOM_CONFIG,
            {.binding = &shader_injection.custom_bloom, .is_enabled = IsToneMapped},
        }),

        renodx::templates::settings::CreateSetting({
            renodx::templates::settings::FX_VIGNETTE_CONFIG,
            {.binding = &shader_injection.custom_vignette, .is_enabled = IsToneMapped},
        }),

        renodx::templates::settings::CreateSetting({
            .key = "FXFilmGrain",
            .binding = &shader_injection.custom_film_grain,
            .default_value = 50.f,
            .label = "Film Grain",
            .section = "Effects",
            .is_enabled = IsToneMapped,
            .parse = [](float value) { return value * 0.01f; },
        }),

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "Reset All",
            .section = "Options",
            .group = "button-line-1",
            .on_change = []() { renodx::utils::settings::ResetSettings(); },
        },

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "HDR Match",
            .section = "Options",
            .group = "button-line-1",
            .on_change = []() {
              renodx::utils::settings::ResetSettings();
              renodx::utils::settings::UpdateSettings({
                  {"ToneMapGameNits", 250.f},
                  {"ColorGradeExposure", 1.2f},
                  {"ColorGradeHighlights", 60.f},
                  {"ColorGradeSaturation", 55.f},
              });
            },
        },

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "RenoDX Discord",
            .section = "Links",
            .group = "button-line-2",
            .tint = 0x5865F2,
            .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "Ce9bQHQrSV"); },
        },

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "HDR Den Discord",
            .section = "Links",
            .group = "button-line-2",
            .tint = 0x5865F2,
            .on_change = []() { renodx::utils::platform::LaunchURL("https://discord.gg/", "5WZXDpmbpP"); },
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
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "ShortFuse's Ko-Fi",
            .section = "Links",
            .group = "button-line-3",
            .tint = 0xFF5A16,
            .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/shortfuse"); },
        },

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::BUTTON,
            .label = "DristoforColumb's Ko-Fi",
            .section = "Links",
            .group = "button-line-3",
            .tint = 0xFF5A16,
            .on_change = []() { renodx::utils::platform::LaunchURL("https://ko-fi.com/dristoforcolumb"); },
        },

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::TEXT,
            .label = std::string("Build: ") + renodx::utils::date::ISO_DATE_TIME,
            .section = "About",
        },

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::TEXT,
            .label = "- Requires Calibration -> Enable HDR set to Auto",
            .section = "About",
        },

        new renodx::utils::settings::Setting{
            .value_type = renodx::utils::settings::SettingValueType::TEXT,
            .label = "- Covers the whole trilogy",
            .section = "About",
        },
    },
});

void OnPresetOff() {
  renodx::utils::settings::UpdateSettings({
      {"ToneMapType", 0.f},
      {"ToneMapGameNits", 203.f},
      {"ToneMapUINits", 203.f},
      {"SceneGradeStrength", 100.f},
      {"ColorGradeExposure", 1.f},
      {"ColorGradeHighlights", 50.f},
      {"ColorGradeShadows", 50.f},
      {"ColorGradeContrast", 50.f},
      {"ColorGradeSaturation", 50.f},
      {"FxBloom", 50.f},
      {"FxVignette", 50.f},
      {"FXFilmGrain", 50.f},
      {"colorGradeLUTSampling", 0.f},
  });
}

bool fired_on_init_swapchain = false;

void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
  if (fired_on_init_swapchain) return;
  fired_on_init_swapchain = true;

  auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
  if (!peak.has_value()) return;

  auto* setting = renodx::utils::settings::FindSetting("ToneMapPeakNits");
  if (setting == nullptr) return;
  setting->default_value = peak.value();
  setting->can_reset = true;
}

bool initialized = false;

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Mass Effect : Legendary Edition";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      if (!initialized) {
        renodx::mods::shader::force_pipeline_cloning = true;
        renodx::mods::shader::expected_constant_buffer_space = 50;
        renodx::mods::shader::expected_constant_buffer_index = 13;
        renodx::mods::shader::allow_multiple_push_constants = true;
        renodx::utils::random::binds.push_back(&shader_injection.custom_random);

        initialized = true;
      }

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);

      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::random::Use(fdw_reason);
  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
