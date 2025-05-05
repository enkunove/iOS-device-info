import UIKit
import Flutter
import CoreTelephony
import SystemConfiguration.CaptiveNetwork
import SystemConfiguration
import CoreMotion
import AVFoundation
import LocalAuthentication
import Darwin
import MachO

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "device_info_channel", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { call, result in
      if call.method == "getDeviceInfo" {
        result(self.getAllDeviceInfo())
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getAllDeviceInfo() -> [String: Any] {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    
    var info = [String: Any]()

    // UIDevice
    info["name"] = device.name
    info["model"] = device.model
    info["localizedModel"] = device.localizedModel
    info["systemName"] = device.systemName
    info["systemVersion"] = device.systemVersion
    info["identifierForVendor"] = device.identifierForVendor?.uuidString ?? "unknown"
    info["batteryLevel"] = device.batteryLevel
    info["batteryState"] = device.batteryState.rawValue
    info["orientation"] = device.orientation.rawValue
    info["isMultitaskingSupported"] = device.isMultitaskingSupported
    info["userInterfaceIdiom"] = device.userInterfaceIdiom.rawValue

    // sysctl
    info["machine"] = getSysctlValue("hw.machine")
    info["cpuCount"] = ProcessInfo.processInfo.processorCount
    info["activeProcessorCount"] = ProcessInfo.processInfo.activeProcessorCount
    info["hostName"] = ProcessInfo.processInfo.hostName

    // Screen
    let screen = UIScreen.main
    info["screenWidth"] = screen.bounds.size.width
    info["screenHeight"] = screen.bounds.size.height
    info["screenScale"] = screen.scale
    info["brightness"] = screen.brightness

    // Locale
    let locale = Locale.current
    info["localeIdentifier"] = locale.identifier
    info["regionCode"] = locale.regionCode ?? ""
    info["languageCode"] = locale.languageCode ?? ""
    info["currencyCode"] = locale.currencyCode ?? ""

    // Storage
    if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()) {
      if let total = attrs[.systemSize] as? NSNumber, let free = attrs[.systemFreeSize] as? NSNumber {
        info["totalStorage"] = total.int64Value
        info["freeStorage"] = free.int64Value
      }
    }

    // RAM
    info["physicalMemory"] = ProcessInfo.processInfo.physicalMemory

    // Camera
    let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    info["hasCamera"] = cameraAvailable

    // Biometrics
    let context = LAContext()
    var error: NSError?
    let biometricAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    info["biometricAvailable"] = biometricAvailable
    info["biometricType"] = context.biometryType.rawValue

    // Motion sensors
    let motion = CMMotionManager()
    info["hasGyro"] = motion.isGyroAvailable
    info["hasAccelerometer"] = motion.isAccelerometerAvailable
    info["hasMagnetometer"] = motion.isMagnetometerAvailable

    // Network - IP
    info["ipAddress"] = getWiFiAddress() ?? "unknown"

    // Carrier
    let networkInfo = CTTelephonyNetworkInfo()
    if let carrier = networkInfo.serviceSubscriberCellularProviders?.values.first {
      info["carrierName"] = carrier.carrierName ?? ""
      info["isoCountryCode"] = carrier.isoCountryCode ?? ""
      info["mobileCountryCode"] = carrier.mobileCountryCode ?? ""
      info["mobileNetworkCode"] = carrier.mobileNetworkCode ?? ""
    }

    return info
  }

  private func getSysctlValue(_ key: String) -> String {
    var size: size_t = 0
    sysctlbyname(key, nil, &size, nil, 0)
    var result = [CChar](repeating: 0, count: size)
    sysctlbyname(key, &result, &size, nil, 0)
    return String(cString: result)
  }

  private func getWiFiAddress() -> String? {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    if getifaddrs(&ifaddr) == 0 {
      var ptr = ifaddr
      while ptr != nil {
        defer { ptr = ptr?.pointee.ifa_next }
        let interface = ptr!.pointee
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6),
           let name = String(validatingUTF8: interface.ifa_name), name == "en0" {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                      &hostname, socklen_t(hostname.count),
                      nil, socklen_t(0), NI_NUMERICHOST)
          address = String(cString: hostname)
        }
      }
      freeifaddrs(ifaddr)
    }
    return address
  }
}
