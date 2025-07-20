import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    NSApp.setActivationPolicy(.regular)

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.collectionBehavior = [.fullScreenPrimary, .canJoinAllSpaces]
    self.isReleasedWhenClosed = false
    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()

    self.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true) // 👈 关键！

  }
}
