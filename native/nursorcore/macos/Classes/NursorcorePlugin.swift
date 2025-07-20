import Cocoa
import FlutterMacOS

public class NursorcorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "nursorcore", binaryMessenger: registrar.messenger)
    let instance = NursorcorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let xpcChannel = FlutterMethodChannel(name: "org.nursor.nursor_xpc", binaryMessenger: registrar.messenger)
    let xpcInstance = NursorXpcPlugin()
    registrar.addMethodCallDelegate(xpcInstance, channel: xpcChannel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
