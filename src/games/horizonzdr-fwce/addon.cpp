/*
 * Copyright (C) 2026 Hlib Omelchenko
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <cmath>
#include <string>

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "../../utils/swapchain.hpp"
#include "./shared.h"

namespace {

  ShaderInjectData shader_injection;
  float current_settings_mode = 0.f;

  bool IsModEnabled() {
    return shader_injection.tone_map_type != HORIZON_TONE_MAP_TYPE_VANILLA;
  }

  bool IsVanillaPlus() {
    return shader_injection.tone_map_type == HORIZON_TONE_MAP_TYPE_VANILLA_PLUS;
  }

  bool IsAdvancedMode() { return current_settings_mode >= 1.f; }

  bool ShouldReplaceShader(reshade::api::command_list*) {
    return IsModEnabled();  // Vanilla uses the game's original shaders.
  }

  renodx::mods::shader::CustomShaders custom_shaders = {
    // Horizon Zero Dawn Remastered.
    CustomShaderEntryCallback(0xDC3776F8, &ShouldReplaceShader),  // Scene compose, no-AA variant
    CustomShaderEntryCallback(0xEE966BC2, &ShouldReplaceShader),  // Scene compose, FXAA variant
    CustomShaderEntryCallback(0xB04A45DA, &ShouldReplaceShader),  // Scene compose, FXAA + sharpen variant
    CustomShaderEntryCallback(0x7475EFAE, &ShouldReplaceShader),  // Menu / FMV / loading output
    CustomShaderEntryCallback(0xA3F59A8C, &ShouldReplaceShader),  // FMV decode and expansion
    // AA/upscale resolvers, listed in the same order as the HFW twins below.
    CustomShaderEntryCallback(0xDA5784EF, &ShouldReplaceShader),  // Resolver, no sampler, float cap
    CustomShaderEntryCallback(0x6089C217, &ShouldReplaceShader),  // Resolver, no sampler, half cap
    CustomShaderEntryCallback(0x9C79EDC7, &ShouldReplaceShader),  // Resolver, sampler, float cap
    CustomShaderEntryCallback(0xA0F3AF86, &ShouldReplaceShader),  // Resolver, sampler, half cap
    CustomShaderEntryCallback(0xB634FD45, &ShouldReplaceShader),  // Resolver, sampler, half cap, no sharpen

    // Horizon Forbidden West Complete Edition.
    CustomShaderEntryCallback(0x25300FC0, &ShouldReplaceShader),  // Scene compose, no-AA variant
    CustomShaderEntryCallback(0x81FF83CE, &ShouldReplaceShader),  // Scene compose, FXAA variant
    CustomShaderEntryCallback(0xE733FA60, &ShouldReplaceShader),  // Scene compose, FXAA + sharpen variant
    CustomShaderEntryCallback(0x55477A4D, &ShouldReplaceShader),  // Menu / FMV / loading output
    CustomShaderEntryCallback(0x07DE7A57, &ShouldReplaceShader),  // FMV decode and expansion
    // AA/upscale resolvers, listed in the same order as the HZDR twins above.
    CustomShaderEntryCallback(0x170D0D0F, &ShouldReplaceShader),  // Resolver, no sampler, float cap
    CustomShaderEntryCallback(0x65C56B76, &ShouldReplaceShader),  // Resolver, no sampler, half cap
    CustomShaderEntryCallback(0xF4342F55, &ShouldReplaceShader),  // Resolver, sampler, float cap
    CustomShaderEntryCallback(0x6127499F, &ShouldReplaceShader),  // Resolver, sampler, half cap
    CustomShaderEntryCallback(0xA2B068B0, &ShouldReplaceShader),  // Resolver, sampler, half cap, no sharpen
  };

  renodx::utils::settings::Settings settings = {
      new renodx::utils::settings::Setting{
          .key = "SettingsMode",
          .binding = &current_settings_mode,
          .value_type = renodx::utils::settings::SettingValueType::INTEGER,
          .default_value = 0.f,
          .can_reset = false,
          .label = "Settings Mode",
          .tooltip = "Simple hides the advanced color grading and effect controls.",
          .labels = {"Simple", "Advanced"},
          .is_global = true,
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapType",
          .binding = &shader_injection.tone_map_type,
          .value_type = renodx::utils::settings::SettingValueType::INTEGER,
          .default_value = HORIZON_TONE_MAP_TYPE_VANILLA_PLUS,
          .label = "Tone Mapper",
          .section = "Tone Mapping",
          .tooltip = "Sets the tone mapper type",
          .labels = {"Vanilla", "Vanilla+", "PsychoV-24"},
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapPeakNits",
          .binding = &shader_injection.peak_white_nits,
          .default_value = 1000.f,
          .label = "Peak Brightness",
          .section = "Tone Mapping",
          .tooltip = "Sets the value of peak white in nits",
          .min = 48.f,
          .max = 4000.f,
          .is_enabled = IsModEnabled,
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapGameNits",
          .binding = &shader_injection.diffuse_white_nits,
          .default_value = 203.f,
          .label = "Game Brightness",
          .section = "Tone Mapping",
          .tooltip = "Sets the value of 100% white in nits",
          .min = 48.f,
          .max = 500.f,
          .is_enabled = IsModEnabled,
      },
      new renodx::utils::settings::Setting{
          .key = "GammaCorrection",
          .binding = &shader_injection.gamma_correction,
          .value_type = renodx::utils::settings::SettingValueType::INTEGER,
          .default_value = HORIZON_GAMMA_CORRECTION_2_2,
          .label = "Gamma Correction",
          .section = "Tone Mapping",
          .tooltip = "Emulates a display EOTF.",
          .labels = {"Off", "2.2", "BT.1886"},
          .is_enabled = IsModEnabled,
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapBlowout",
          .binding = &shader_injection.tone_map_blowout,
          .default_value = 100.f,
          .label = "Blowout",
          .section = "Tone Mapping",
          .tooltip = "Emulates blowout from per channel tonemapping",
          .max = 100.f,
          .is_enabled = IsVanillaPlus,
          .parse = [](float value) { return value * 0.01f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapHueShift",
          .binding = &shader_injection.tone_map_hue_shift,
          .default_value = 100.f,
          .label = "Hue Shift",
          .section = "Tone Mapping",
          .tooltip = "Hue-shift emulation strength.",
          .max = 100.f,
          .is_enabled = IsVanillaPlus,
          .parse = [](float value) { return value * 0.01f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeExposure",
          .binding = &shader_injection.color_grade_exposure,
          .default_value = 1.f,
          .label = "Exposure",
          .section = "Color Grading",
          .min = 0.f,
          .max = 2.f,
          .format = "%.2f",
          .is_enabled = IsModEnabled,
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeHighlights",
          .binding = &shader_injection.color_grade_highlights,
          .default_value = 50.f,
          .label = "Highlights",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeShadows",
          .binding = &shader_injection.color_grade_shadows,
          .default_value = 50.f,
          .label = "Shadows",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeContrast",
          .binding = &shader_injection.color_grade_contrast,
          .default_value = 50.f,
          .label = "Contrast",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeSaturation",
          .binding = &shader_injection.color_grade_saturation,
          .default_value = 50.f,
          .label = "Saturation",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeHighlightSaturation",
          .binding = &shader_injection.color_grade_highlight_saturation,
          .default_value = 50.f,
          .label = "Highlight Saturation",
          .section = "Color Grading",
          .tooltip = "Adds or removes highlight color.",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeDechroma",
          .binding = &shader_injection.color_grade_dechroma,
          .default_value = 0.f,
          .label = "Dechroma",
          .section = "Color Grading",
          .tooltip = "Controls highlight desaturation due to overexposure.",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeFlare",
          .binding = &shader_injection.color_grade_flare,
          .default_value = 0.f,
          .label = "Flare",
          .section = "Color Grading",
          .tooltip = "Flare/Glare Compensation",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeLUTStrength",
          .binding = &shader_injection.color_grade_lut_strength,
          .default_value = 100.f,
          .label = "LUT Strength",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeLUTSampling",
          .binding = &shader_injection.custom_lut_tetrahedral,
          .value_type = renodx::utils::settings::SettingValueType::INTEGER,
          .default_value = 1.f,
          .label = "LUT Sampling",
          .section = "Color Grading",
          .labels = {"Trilinear", "Tetrahedral"},
          .is_enabled = IsModEnabled,
          .is_visible = IsAdvancedMode,
      },
      new renodx::utils::settings::Setting{
          .key = "FxResolverSharpeningType",
          .binding = &shader_injection.fx_resolver_sharpening_type,
          .value_type = renodx::utils::settings::SettingValueType::BOOLEAN,
          .default_value = 0.f,
          .label = "Sharpening Type",
          .section = "Effects",
          .tooltip = "Selects whether to use the vanilla sharpening or RCAS.",
          .labels = {"Vanilla", "Lilium RCAS"},
          .is_enabled = IsModEnabled,
      },
      new renodx::utils::settings::Setting{
          .key = "FxResolverSharpeningStrength",
          .binding = &shader_injection.fx_resolver_sharpening_strength,
          .default_value = 75.f,
          .label = "Sharpening Strength",
          .section = "Effects",
          .tooltip = "Adjusts Lilium RCAS sharpening strength.",
          .max = 100.f,
          .is_enabled = []() { return IsModEnabled() && shader_injection.fx_resolver_sharpening_type >= 1.f; },
          .parse = [](float value) { return value == 0.f ? 0.f : std::exp2(-(1.f - (value * 0.01f))); },
      },
      new renodx::utils::settings::Setting{
          .key = "FxVignette",
          .binding = &shader_injection.fx_vignette,
          .default_value = 100.f,
          .label = "Vignette",
          .section = "Effects",
          .tooltip = "Scales the game's vignette. 100 = vanilla, 0 = off.",
          .max = 100.f,
          .is_enabled = IsModEnabled,
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = IsAdvancedMode,
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
          .label = "- Requires HDR Rendering (Display) set to On in game.",
          .section = "About",
      },
      new renodx::utils::settings::Setting{
          .value_type = renodx::utils::settings::SettingValueType::TEXT,
          .label = "- Use the in-game Brightness slider (Display) to adjust UI/HUD brightness.",
          .section = "About",
      },
      new renodx::utils::settings::Setting{
          .value_type = renodx::utils::settings::SettingValueType::TEXT,
          .label = "- Lilium RCAS requires the in-game Sharpness slider (Graphics) set to 5.",
          .section = "About",
      },
      new renodx::utils::settings::Setting{
          .value_type = renodx::utils::settings::SettingValueType::TEXT,
          .label = "- Thanks and credits to Lilium (EndlesslyFlowering) for the HDR RCAS implementation.",
          .section = "About",
      },
  };

  void OnPresetOff() {
    renodx::utils::settings::ResetSettings();
    renodx::utils::settings::UpdateSettings({
        {"ToneMapType", HORIZON_TONE_MAP_TYPE_VANILLA},
        {"ColorGradeLUTSampling", 0.f},
      });
  }

  bool fired_on_init_swapchain = false;

  void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
    if (fired_on_init_swapchain) return;
    auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
    if (!peak.has_value()) return;
    auto* peak_setting = renodx::utils::settings::FindSetting("ToneMapPeakNits");
    if (peak_setting != nullptr) {
      peak_setting->default_value = roundf(peak.value());
    }
    fired_on_init_swapchain = true;
  }

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Horizon Zero Dawn Remastered & Horizon Forbidden West Complete Edition";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      renodx::mods::shader::on_init_pipeline_layout = [](reshade::api::device* device, auto, auto) {
        return device->get_api() == reshade::api::device_api::d3d12;  // So overlays dont kill the game
        };

      renodx::mods::shader::force_pipeline_cloning = true;
      renodx::mods::shader::expected_constant_buffer_space = 50;
      renodx::mods::shader::expected_constant_buffer_index = 0;

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
