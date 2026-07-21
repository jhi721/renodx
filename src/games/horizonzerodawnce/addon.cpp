/*
 * Copyright (C) 2026 Hlib Omelchenko
 * SPDX-License-Identifier: MIT
 */

#define ImTextureID ImU64

#define DEBUG_LEVEL_0

#include <deps/imgui/imgui.h>
#include <include/reshade.hpp>

#include <embed/shaders.h>

#include "../../mods/shader.hpp"
#include "../../mods/swapchain.hpp"
#include "../../utils/date.hpp"
#include "../../utils/platform.hpp"
#include "../../utils/settings.hpp"
#include "./shared.h"

namespace {

  ShaderInjectData shader_injection;

  bool ShouldReplaceShader(reshade::api::command_list* cmd_list) {
    (void)cmd_list;
    return shader_injection.tone_map_type != 0.f;  // Vanilla = no shader replacement
  }

  // FMV decode draw = a video is on screen this frame. The shared menu/FMV/loading output pass uses
  // this flag to skip highlight emulation for cinematics while keeping it for menus/loading.
  // Reset in OnPresent.
  bool OnVideoDecode(reshade::api::command_list* cmd_list) {
    shader_injection.custom_video_active = 1.f;
    return ShouldReplaceShader(cmd_list);
  }

  renodx::mods::shader::CustomShaders custom_shaders = {
      CustomShaderEntryCallback(0xB444C8F0, &ShouldReplaceShader),  // Scene composite + grade + LUT + OETF
      CustomShaderEntryCallback(0x29103068, &ShouldReplaceShader),  // Menu / FMV / loading output transform
      CustomShaderEntryCallback(0x6EC6FED7, &OnVideoDecode),        // FMV YCbCr decode fix + video-active flag
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
          .tooltip = "Simple hides the advanced color grading and effect controls.",
          .labels = {"Simple", "Advanced"},
          .is_global = true,
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapType",
          .binding = &shader_injection.tone_map_type,
          .value_type = renodx::utils::settings::SettingValueType::INTEGER,
          .default_value = 1.f,
          .label = "Tone Mapper",
          .section = "Tone Mapping",
          .tooltip = "Sets the tone mapper type",
          .labels = {"Vanilla", "Vanilla+", "Vanilla+ (Neutwo)", "Vanilla+ (PsychoV-24)"},
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapPeakNits",
          .binding = &shader_injection.peak_white_nits,
          .default_value = 1000.f,
          .can_reset = true,
          .label = "Peak Brightness",
          .section = "Tone Mapping",
          .tooltip = "Sets the value of peak white in nits",
          .min = 100.f,
          .max = 4000.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ToneMapGameNits",
          .binding = &shader_injection.diffuse_white_nits,
          .default_value = 203.f,
          .can_reset = true,
          .label = "Game Brightness",
          .section = "Tone Mapping",
          .tooltip = "Sets the value of 100% white in nits",
          .min = 48.f,
          .max = 500.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "GammaCorrection",
          .binding = &shader_injection.gamma_correction,
          .value_type = renodx::utils::settings::SettingValueType::INTEGER,
          .default_value = 1.f,
          .label = "Gamma Correction",
          .section = "Tone Mapping",
          .tooltip = "Emulates a display EOTF.",
          .labels = {"Off", "2.2", "BT.1886"},
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
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
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeHighlights",
          .binding = &shader_injection.color_grade_highlights,
          .default_value = 50.f,
          .label = "Highlights",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeShadows",
          .binding = &shader_injection.color_grade_shadows,
          .default_value = 50.f,
          .label = "Shadows",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeContrast",
          .binding = &shader_injection.color_grade_contrast,
          .default_value = 50.f,
          .label = "Contrast",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeSaturation",
          .binding = &shader_injection.color_grade_saturation,
          .default_value = 50.f,
          .label = "Saturation",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeHighlightSaturation",
          .binding = &shader_injection.color_grade_highlight_saturation,
          .default_value = 50.f,
          .label = "Highlight Saturation",
          .section = "Color Grading",
          .tooltip = "Adds or removes highlight color.",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeDechroma",
          .binding = &shader_injection.color_grade_dechroma,
          .default_value = 0.f,
          .label = "Dechroma",
          .section = "Color Grading",
          .tooltip = "Controls highlight desaturation due to overexposure.",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeFlare",
          .binding = &shader_injection.color_grade_flare,
          .default_value = 0.f,
          .label = "Flare",
          .section = "Color Grading",
          .tooltip = "Flare/Glare Compensation",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.02f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeLUTStrength",
          .binding = &shader_injection.color_grade_lut_strength,
          .default_value = 100.f,
          .label = "LUT Strength",
          .section = "Color Grading",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "ColorGradeLUTSampling",
          .binding = &shader_injection.custom_lut_tetrahedral,
          .value_type = renodx::utils::settings::SettingValueType::INTEGER,
          .default_value = 1.f,
          .label = "LUT Sampling",
          .section = "Color Grading",
          .labels = {"Trilinear", "Tetrahedral"},
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "FxBloom",
          .binding = &shader_injection.fx_bloom,
          .default_value = 100.f,
          .label = "Bloom",
          .section = "Effects",
          .tooltip = "Scales the game's bloom. 100 = vanilla, 0 = off.",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "FxLightShaft",
          .binding = &shader_injection.fx_light_shaft,
          .default_value = 100.f,
          .label = "Light Shafts",
          .section = "Effects",
          .tooltip = "Scales the game's light shafts (god rays). 100 = vanilla, 0 = off.",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "FxFlare",
          .binding = &shader_injection.fx_flare,
          .default_value = 100.f,
          .label = "Lens Flare",
          .section = "Effects",
          .tooltip = "Scales the game's lens flare. 100 = vanilla, 0 = off.",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.01f; },
          .is_visible = []() { return current_settings_mode >= 1.f; },
      },
      new renodx::utils::settings::Setting{
          .key = "FxVignette",
          .binding = &shader_injection.fx_vignette,
          .default_value = 100.f,
          .label = "Vignette",
          .section = "Effects",
          .tooltip = "Scales the game's vignette. 100 = vanilla, 0 = off.",
          .max = 100.f,
          .is_enabled = []() { return shader_injection.tone_map_type >= 1.f; },
          .parse = [](float value) { return value * 0.01f; },
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
          .label = "- Requires HDR rendering on in game (Display).",
          .section = "About",
      },
      new renodx::utils::settings::Setting{
          .value_type = renodx::utils::settings::SettingValueType::TEXT,
          .label = "- Leave the in-game Brightness (Display) at the default 50%.",
          .section = "About",
      },
      new renodx::utils::settings::Setting{
          .value_type = renodx::utils::settings::SettingValueType::TEXT,
          .label = "- Leave the in-game HDR Brightness (Display > HDR settings) at 50.",
          .section = "About",
      },
      new renodx::utils::settings::Setting{
          .value_type = renodx::utils::settings::SettingValueType::TEXT,
          .label = "- Use the in-game HDR Whitepoint slider (Display > HDR settings) to adjust UI/HUD brightness.",
          .section = "About",
      },
  };

  void OnPresetOff() {
    // "Off" preset = pure native-HDR passthrough: ToneMapType 0 disables shader replacement, so
    // every shader setting below is render-inert. Values reset to first-launch defaults except
    // the pure-vanilla toggles: ToneMapType = 0 and ColorGradeLUTSampling = 0/Trilinear.
    renodx::utils::settings::UpdateSettings({
        {"ToneMapType", 0.f},
        {"ToneMapPeakNits", 1000.f},
        {"ToneMapGameNits", 203.f},
        {"GammaCorrection", 1.f},
        {"ColorGradeExposure", 1.f},
        {"ColorGradeHighlights", 50.f},
        {"ColorGradeShadows", 50.f},
        {"ColorGradeContrast", 50.f},
        {"ColorGradeSaturation", 50.f},
        {"ColorGradeHighlightSaturation", 50.f},
        {"ColorGradeDechroma", 0.f},
        {"ColorGradeFlare", 0.f},
        {"ColorGradeLUTStrength", 100.f},
        {"ColorGradeLUTSampling", 0.f},
        {"FxBloom", 100.f},
        {"FxLightShaft", 100.f},
        {"FxFlare", 100.f},
        {"FxVignette", 100.f},
      });
  }

  bool fired_on_init_swapchain = false;

  void OnInitSwapchain(reshade::api::swapchain* swapchain, bool resize) {
    if (fired_on_init_swapchain) return;
    // Latch only on a successful read: the transient boot swapchain may have no HDR
    // metadata, and we must not pin the default to 1000 and block re-seeding from the
    // real HDR swapchain.
    auto peak = renodx::utils::swapchain::GetPeakNits(swapchain);
    if (!peak.has_value()) return;
    auto* peak_setting = renodx::utils::settings::FindSetting("ToneMapPeakNits");
    if (peak_setting != nullptr) {
      peak_setting->default_value = roundf(peak.value());
    }
    fired_on_init_swapchain = true;
  }

  // Reset the FMV flag each frame; the 0x6EC6FED7 callback re-sets it while a video decodes.
  void OnPresent(
    reshade::api::command_queue* queue,
    reshade::api::swapchain* swapchain,
    const reshade::api::rect* source_rect,
    const reshade::api::rect* dest_rect,
    uint32_t dirty_rect_count,
    const reshade::api::rect* dirty_rects) {
    shader_injection.custom_video_active = 0.f;
  }

}  // namespace

extern "C" __declspec(dllexport) constexpr const char* NAME = "RenoDX";
extern "C" __declspec(dllexport) constexpr const char* DESCRIPTION = "RenoDX for Horizon Zero Dawn Complete Edition";

BOOL APIENTRY DllMain(HMODULE h_module, DWORD fdw_reason, LPVOID lpv_reserved) {
  switch (fdw_reason) {
    case DLL_PROCESS_ATTACH:
      if (!reshade::register_addon(h_module)) return FALSE;

      // Decima compiles its PSO catalog on a large worker-thread pool; synchronous replacement can
      // race the first use of a replacement pipeline. Defer replacement to a safe point.
      renodx::utils::shader::use_replace_async = true;

      renodx::mods::shader::force_pipeline_cloning = true;
      renodx::mods::shader::expected_constant_buffer_index = 0;
      renodx::mods::shader::expected_constant_buffer_space = 50;

      // Only inject b0/space50 into the game's D3D12 pipeline layouts. ReShade overlay paths can
      // surface non-D3D12 layouts; injecting into those hard-crashes the game at pipeline creation.
      renodx::mods::shader::on_init_pipeline_layout = [](reshade::api::device* device, auto, auto) {
        return device->get_api() == reshade::api::device_api::d3d12;
        };

      reshade::register_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::register_event<reshade::addon_event::present>(OnPresent);
      break;
    case DLL_PROCESS_DETACH:
      reshade::unregister_event<reshade::addon_event::init_swapchain>(OnInitSwapchain);
      reshade::unregister_event<reshade::addon_event::present>(OnPresent);
      reshade::unregister_addon(h_module);
      break;
  }

  renodx::utils::settings::Use(fdw_reason, &settings, &OnPresetOff);
  renodx::mods::shader::Use(fdw_reason, custom_shaders, &shader_injection);

  return TRUE;
}
