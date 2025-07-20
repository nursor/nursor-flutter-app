#include "include/nursorcore/nursorcore_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "nursorcore_plugin.h"

void NursorcorePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  nursorcore::NursorcorePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
