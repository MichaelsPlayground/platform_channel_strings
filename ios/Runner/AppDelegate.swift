// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import UIKit
import Flutter

enum ChannelName {
  static let battery = "samples.flutter.io/battery"
  static let charging = "samples.flutter.io/charging"
}

enum BatteryState {
  static let charging = "charging"
  static let discharging = "discharging"
}

enum MyFlutterErrorCode {
  static let unavailable = "UNAVAILABLE"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    guard let controller = window?.rootViewController as? FlutterViewController else {
      fatalError("rootViewController is not type FlutterViewController")
    }
        
    // new Johannes Milke
        let batteryChannel = FlutterMethodChannel(name: ChannelName.battery,
                                                  binaryMessenger: controller.binaryMessenger)
        batteryChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in switch call.method{
            case "getBatteryLevel":
                guard let args = call.arguments as? [String: String] else {return}
                let name = args["name"]!
                result("\(name) says on IOS10 \(self.receiveBatteryLevel2())")
            default:
                result(FlutterMethodNotImplemented)
            }
            
        })
        
    /* org
    let batteryChannel = FlutterMethodChannel(name: ChannelName.battery,
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      guard call.method == "getBatteryLevel" else {
        result(FlutterMethodNotImplemented)
        return
      }

        // new
        //let args = call.arguments as? [String: String]
        //let name = args["name"]!
        // end new

        self?.receiveBatteryLevel(result: result)
        //self?.receiveBatteryLevel(result: "\(name) says \result")
    })
*/
        
        
    let chargingChannel = FlutterEventChannel(name: ChannelName.charging,
                                              binaryMessenger: controller.binaryMessenger)
    chargingChannel.setStreamHandler(self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    private func receiveBatteryLevel2() -> Int {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        if device.batteryState == UIDevice.BatteryState.unknown {
            return -1
        } else {
            return Int(device.batteryLevel * 100)
        }
    }
    
  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    guard device.batteryState != .unknown  else {
      result(FlutterError(code: MyFlutterErrorCode.unavailable,
                          message: "Battery info unavailable",
                          details: nil))
      return
    }
    result(Int(device.batteryLevel * 100))
  }
    
    

  public func onListen(withArguments arguments: Any?,
                       eventSink: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = eventSink
    UIDevice.current.isBatteryMonitoringEnabled = true
    sendBatteryStateEvent()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(AppDelegate.onBatteryStateDidChange),
      name: UIDevice.batteryStateDidChangeNotification,
      object: nil)
    return nil
  }

  @objc private func onBatteryStateDidChange(notification: NSNotification) {
    sendBatteryStateEvent()
  }

  private func sendBatteryStateEvent() {
    guard let eventSink = eventSink else {
      return
    }

    switch UIDevice.current.batteryState {
    case .full:
      eventSink(BatteryState.charging)
    case .charging:
      eventSink(BatteryState.charging)
    case .unplugged:
      eventSink(BatteryState.discharging)
    default:
      eventSink(FlutterError(code: MyFlutterErrorCode.unavailable,
                             message: "Charging status unavailable",
                             details: nil))
    }
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    eventSink = nil
    return nil
  }
}

/*import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
*/
