import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
            let eventChannel = FlutterEventChannel(name: "beaconHandlerEvent", binaryMessenger: controller.binaryMessenger)
            eventChannel.setStreamHandler(BeaconHandler())
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class BeaconHandler: NSObject, FlutterStreamHandler {
    
    var beaconViewModel = BeaconViewModel()
       
        // Declare our eventSink, it will be initialized later
        private var eventSink: FlutterEventSink?
        
        func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
            print("onListen......")
            self.eventSink = eventSink
        
            beaconViewModel.startMonitoring() { status in
                eventSink(status)
            }
            
            return nil
        }
        
        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            eventSink = nil
            return nil
        }
    }
