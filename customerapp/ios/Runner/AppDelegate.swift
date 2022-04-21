import UIKit
import Flutter
import FirebaseCore
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBdMkcqhC_viVUAVejYdk7ad7Z4wi3y_kE")
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 13.0, *) {
    } else {
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: self)
    } 
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
