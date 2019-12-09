//
//  MLCardFormVendorSpecificAttributes.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 21/11/2019.
//

import Foundation

struct MLCardFormVendorSpecificAttributes: Codable {

    var deviceIdiom: String?
    var canSendSMS = 1
    var canMakePhoneCalls = 1
    var deviceLanguage: String?
    var deviceModel: String?
    var deviceName: String?
    var simulator = 0

    public init() {
        let device: UIDevice = UIDevice.current
        if device.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            self.deviceIdiom = "Pad"
        } else {
            self.deviceIdiom = "Phone"
        }

        if Locale.preferredLanguages.count > 0 {
            self.deviceLanguage = Locale.preferredLanguages[0]
        }

        if !String.isNullOrEmpty(device.model) {
            self.deviceModel = device.model
        }

        if !String.isNullOrEmpty(device.name) {
            self.deviceName = device.name
        }
    }
}
