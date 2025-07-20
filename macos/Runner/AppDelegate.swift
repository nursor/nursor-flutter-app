import Cocoa
import FlutterMacOS
import nursorcore

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller = NSApplication.shared.windows.first?.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.nursor.cursor_path", binaryMessenger: controller.engine.binaryMessenger)

    channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "getApplicationSupportDirectory" {
        // 获取全局 Application Support 目录
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        if let appSupportDir = paths.first {
          result(appSupportDir)
        } else {
          result(FlutterError(code: "UNAVAILABLE", message: "Application Support directory not found", details: nil))
        }
      } else if call.method == "checkNursorCert" {
        result(self.checkNursorCertificate())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(notification)
  }

  private func checkNursorCertificate() -> Bool {
    var anchors: CFArray?
    let status = SecTrustCopyAnchorCertificates(&anchors)
    if status == errSecSuccess, let certs = anchors as? [SecCertificate] {
        for cert in certs {
            if let summary = SecCertificateCopySubjectSummary(cert) as String? {
                if summary.lowercased().contains("nursor") {
                    return true
                }
            }
        }
    }
    return false
  }
}
