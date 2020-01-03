//
//  MLCardFormConfiguratorManager.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//

import Foundation

/** :nodoc: */
@objcMembers
open class MLCardFormConfiguratorManager: NSObject {
    // MARK: Internal definitions.
    internal static var escProtocol: MLCardFormESCProtocol = MLCardFormESCDefault()
    internal static var escConfig: MLCardFormESCConfig = MLCardFormESCConfig.createConfig()

    // MARK: Public
    // Set external implementation of MLCardFormESCProtocol
    public static func with(esc escProtocol: MLCardFormESCProtocol, tracking trackingProtocol: MLCardFormTrackerDelegate) {
        self.escProtocol = escProtocol
        MLCardFormTracker.sharedInstance.setTrackerDelegate(trackingProtocol)
    }
    
    static func updateConfig(escEnabled: Bool = false) {
        let escConfig = MLCardFormESCConfig.createConfig(enabled: escEnabled)
        self.escConfig = escConfig
    }
}
