//
//  MLCardFormConfiguratorManager.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//

import Foundation

/// :nodoc
@objcMembers
open class MLCardFormConfiguratorManager: NSObject {
    // MARK: Internal definitions.
    internal static var escProtocol: MLCardFormESCProtocol = MLCardFormESCDefault()
    internal static var escConfig: MLCardFormESCConfig = MLCardFormESCConfig.createConfig()
    
    // MARK: Public
    // Set external implementation of MLCardFormESCProtocol
    public static func with(esc escProtocol: MLCardFormESCProtocol) {
        self.escProtocol = escProtocol
    }
    
    static func updateConfig(enabled: Bool = false, sessionId: String? = nil, flow: String? = nil) {
        var sessionId = sessionId
        if sessionId == nil {
            sessionId = MLCardFormConfiguratorManager.escConfig.sessionId
        }
        var flow = flow
        if flow == nil {
            flow = MLCardFormConfiguratorManager.escConfig.flow
        }
        let escConfig = MLCardFormESCConfig.createConfig(enabled: enabled, sessionId: sessionId, flow: flow)
        self.escConfig = escConfig
    }
}
