//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <nursorcore/nursorcore_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) nursorcore_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NursorcorePlugin");
  nursorcore_plugin_register_with_registrar(nursorcore_registrar);
}
