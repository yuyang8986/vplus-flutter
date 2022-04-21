import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    //    let killItChannel = FlutterMethodChannel(name: "Killit",
    //                                              binaryMessenger: controller.binaryMessenger)
    // killItChannel.setMethodCallHandler({
    //      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
    //      // Note: this method is invoked on the UI thread.
    //      // Handle battery messages.
    //    })
    FirebaseApp.configure()
    //GMSServices.provideAPIKey("AIzaSyBdMkcqhC_viVUAVejYdk7ad7Z4wi3y_kE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
