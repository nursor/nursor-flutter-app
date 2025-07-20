#ifndef FLUTTER_PLUGIN_NURSORCORE_PLUGIN_H_
#define FLUTTER_PLUGIN_NURSORCORE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace nursorcore {

class NursorcorePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  NursorcorePlugin();

  virtual ~NursorcorePlugin();

  // Disallow copy and assign.
  NursorcorePlugin(const NursorcorePlugin&) = delete;
  NursorcorePlugin& operator=(const NursorcorePlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace nursorcore

#endif  // FLUTTER_PLUGIN_NURSORCORE_PLUGIN_H_
