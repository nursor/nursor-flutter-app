import Cocoa
import FlutterMacOS
import os.log // 使用 os_log 替代 NSLog



@objc(NursorXpcPlugin) // 这个名字需要与 Dart 端的 MethodChannel 名称匹配
public class NursorXpcPlugin: NSObject, FlutterPlugin {

    // MARK: - Properties
    
    private var xpcConnection: NSXPCConnection?
    private let logger = OSLog(subsystem: "org.nursor.nursor_xpc", category: "Plugin")
    
    // MethodChannel 名称，与 Flutter 端保持一致。
    private static let channelName = "org.nursor.nursor_xpc" 
    
    // MARK: - FlutterPlugin Registration

    public static func register(with registrar: FlutterPluginRegistrar) {
        NSLog("registerd--------------------------")
        os_log(.info, log: OSLog(subsystem: "org.nursor.nursor_xpc", category: "Plugin"), 
           "Registering NursorXpcPlugin with channel: %{public}@", channelName)
        
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger)
        let instance = NursorXpcPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // MARK: - MethodChannel Handling

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        os_log(.info, log: self.logger, "Received method call: %{public}@", call.method) 
        
        switch call.method {
        case "getPlatformVersion": // 保留了默认的示例方法
            result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
        case "startService": // 您的 XPC 业务逻辑方法
            executeServiceAction(method: .start, result: result)
        case "stopService": // 您的 XPC 业务逻辑方法
            executeServiceAction(method: .stop, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - XPC Connection Management
    
    private func establishXPCConnection() -> NSXPCConnection {
        let connection = NSXPCConnection(machServiceName: "org.nursor.nursor-core", options: [])
        
        connection.remoteObjectInterface = NSXPCInterface(with: NursorCoreServiceProtocol.self)
        
        connection.invalidationHandler = { [weak self] in
            os_log(.error, log: self?.logger ?? .default, "XPC connection invalidated.")
            self?.xpcConnection = nil
        }
        
        connection.interruptionHandler = { [weak self] in
            os_log(.error, log: self?.logger ?? .default, "XPC connection interrupted.")
            self?.xpcConnection = nil
        }
        
        return connection
    }
    
    private func getXPCService() -> NursorCoreServiceProtocol? {
        if xpcConnection == nil { 
            xpcConnection = establishXPCConnection()
            xpcConnection?.resume() 
            os_log(.info, log: self.logger, "XPC connection established and resumed.")
        } else if xpcConnection?.remoteObjectProxy == nil { 
             os_log(.error, log: self.logger, "XPC connection exists but remote object proxy is nil.")
             xpcConnection?.invalidate() 
             xpcConnection = establishXPCConnection()
             xpcConnection?.resume()
             os_log(.info, log: self.logger, "XPC connection re-established and resumed due to missing proxy.")
        }
        
        return xpcConnection?.remoteObjectProxyWithErrorHandler { error in
            os_log(.error, log: self.logger, "XPC remote object proxy error: %{public}@", error.localizedDescription)
            self.xpcConnection?.invalidate() 
            self.xpcConnection = nil
        } as? NursorCoreServiceProtocol
    }
    
    // MARK: - Service Actions Helpers
    
    fileprivate enum ServiceAction {
        case start
        case stop
    }
    
    /// Executes a service action (start or stop) and returns the result via FlutterResult.
    private func executeServiceAction(method: ServiceAction, result: @escaping FlutterResult) {
        guard let service = getXPCService() else {
            DispatchQueue.main.async { 
                os_log(.error, log: self.logger, "Failed to get XPC service for %{public}@", method.description)
                result(FlutterError(code: "XPC_CONNECTION_FAILED",
                                  message: "Could not establish XPC connection to helper service.",
                                  details: nil))
            }
            return
        }
        
        let action: (@escaping (Bool, Error?) -> Void) -> Void
        let methodName: String
        
        switch method {
        case .start:
            action = service.startService
            methodName = "startService"
        case .stop:
            action = service.stopService
            methodName = "stopService"
        }
        
        action { [weak self] success, error in
            guard let self = self else { return } 
            DispatchQueue.main.async { 
                if success {
                    os_log(.info, log: self.logger, "%{public}@ succeeded.", methodName)
                    result(true)
                } else {
                    let errorMessage = error?.localizedDescription ?? "Unknown error"
                    os_log(.error, log: self.logger, "%{public}@ failed: %{public}@", methodName, errorMessage)
                    result(FlutterError(code: "SERVICE_ERROR",
                                      message: "\(methodName) failed: \(errorMessage)",
                                      details: nil))
                }
            }
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        xpcConnection?.invalidate() 
        xpcConnection = nil
        os_log(.info, log: logger, "NursorXpcPlugin deinitialized.")
    }
} // <--- NursorXpcPlugin class definition ends here

// *******************************************************************
// ************ 这里是文件作用域！extension 必须放在类定义的外面 ************
// *******************************************************************
extension NursorXpcPlugin.ServiceAction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .start: return "startService"
        case .stop: return "stopService"
        }
    }
}