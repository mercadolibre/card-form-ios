//
//  MLCardFormFingerprint.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 21/11/2019.
//

import Foundation

final class MLCardFormFingerprint: NSObject, Codable {
    var os: String?
    var vendorIds: [MLCardFormDeviceId]?
    var model: String?
    var systemVersion: String?
    var resolution: String?
    var vendorSpecificAttributes: MLCardFormVendorSpecificAttributes?

    public override init() {
        super.init()
        deviceFingerprint()
    }
}

// MARK: Private functions.
private extension MLCardFormFingerprint {
    func deviceFingerprint() {
        let device: UIDevice = UIDevice.current

        self.os = "iOS"
        self.vendorIds = getDevicesIds()

        if !String.isNullOrEmpty(device.model) {
            self.model = device.model
        }

        if !String.isNullOrEmpty(device.systemVersion) {
            self.systemVersion = device.systemVersion
        }

        self.resolution = getDeviceResolution()
        self.vendorSpecificAttributes = MLCardFormVendorSpecificAttributes()
    }

    func getDevicesIds() -> [MLCardFormDeviceId]? {
        let systemVersionString: String = UIDevice.current.systemVersion
        guard let version = systemVersionString.components(separatedBy: ".").first else { return nil }
        let systemVersion: Float = (version as NSString).floatValue

        if systemVersion < 6 {
            let uuid: String = getUUID()
            if !String.isNullOrEmpty(uuid) {
                return [MLCardFormDeviceId(name: "uuid", value: uuid)]
            }
        } else {
            let vendorId: String = UIDevice.current.identifierForVendor!.uuidString
            let uuid: String = getUUID()

            let vendorCardFormDeviceId = MLCardFormDeviceId(name: "vendor_id", value: vendorId)
            let uuidCardFormDeviceId = MLCardFormDeviceId(name: "uuid", value: uuid)

            return [vendorCardFormDeviceId, uuidCardFormDeviceId]
        }
        return nil
    }

    func getDeviceResolution() -> String {
        let screenSize: CGRect = UIScreen.main.bounds
        let width = NSString(format: "%.0f", screenSize.width)
        let height = NSString(format: "%.0f", screenSize.height)
        return "\(width)x\(height)"
    }
    
    func getUUID() -> String {
        return UUID().uuidString.lowercased()
    }
}
