import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private var glass: NSVisualEffectView?
  private var desktopChannel: FlutterMethodChannel?
  private var accessibilityObserver: NSObjectProtocol?
  private var forceOpaque = false

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    flutterViewController.backgroundColor = .clear
    let windowFrame = self.frame
    let host = NSViewController()
    host.view = NSView(frame: windowFrame)
    host.view.wantsLayer = true
    host.view.layer?.cornerRadius = 24
    host.view.layer?.masksToBounds = true
    let effect = NSVisualEffectView(frame: host.view.bounds)
    effect.autoresizingMask = [.width, .height]
    effect.blendingMode = .behindWindow
    effect.material = .hudWindow
    effect.state = .active
    host.view.addSubview(effect)
    host.addChild(flutterViewController)
    flutterViewController.view.frame = host.view.bounds
    flutterViewController.view.autoresizingMask = [.width, .height]
    host.view.addSubview(flutterViewController.view)
    self.contentViewController = host
    self.backgroundColor = .clear
    self.isOpaque = false
    self.setFrame(windowFrame, display: true)
    self.glass = effect
    RegisterGeneratedPlugins(registry: flutterViewController)
    let channel = FlutterMethodChannel(name: "blitzit/desktop", binaryMessenger: flutterViewController.engine.binaryMessenger)
    self.desktopChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { result(nil); return }
      switch call.method {
      case "reportReady":
        if ProcessInfo.processInfo.environment["BLITZIT_SMOKE_TEST"] == "1" {
          NSLog("BLITZIT_SMOKE_READY visible=%@ width=%.0f height=%.0f", self.isVisible ? "true" : "false", self.frame.width, self.frame.height)
        }
        result(nil)
      case "reduceTransparency":
        result(NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency)
      case "setOpaque":
        self.forceOpaque = call.arguments as? Bool ?? false
        self.updateAppearance()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    accessibilityObserver = NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.accessibilityDisplayOptionsDidChangeNotification,
      object: nil, queue: .main
    ) { [weak self] _ in
      self?.updateAppearance()
      self?.desktopChannel?.invokeMethod("accessibilityChanged", arguments: NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency)
    }
    updateAppearance()
    super.awakeFromNib()
  }

  private func updateAppearance() {
    let opaque = forceOpaque || NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
    glass?.isHidden = opaque
    contentView?.layer?.backgroundColor = opaque ? NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.19, alpha: 1).cgColor : NSColor.clear.cgColor
  }

  deinit {
    if let observer = accessibilityObserver {
      NSWorkspace.shared.notificationCenter.removeObserver(observer)
    }
  }
}
