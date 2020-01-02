import FlutterMacOS

public class SwiftAudioplayersPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "audioplayers", binaryMessenger: registrar.messenger)
    let instance = SwiftAudioplayersPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("macOS")
  }
}
