import Flutter
import UIKit

public class SwiftMyIdPlugin: NSObject, FlutterPlugin {

  private let myidSdk = MyIdSdk()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "myid_uz", binaryMessenger: registrar.messenger())
    let instance = SwiftMyIdPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method.elementsEqual("startSdk")){
      let config = call.arguments as! NSDictionary
      myidSdk.start(config, result: result)
    }
  }
}
