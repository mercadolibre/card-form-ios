//
//  MLCardFormESCConfig.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//

import Foundation

/**
 Whe use this object to store properties related to ESC module.
 Check MLCardFormESCProtocol methods.
 */

/** :nodoc: */
@objcMembers
open class MLCardFormESCConfig: NSObject {
    public let enabled: Bool
    public let sessionId: String
    public let flow: String
    
    init(_ enabled: Bool, _ sessionId: String, _ flow: String) {
        self.enabled = enabled
        self.sessionId = sessionId
        self.flow = flow
    }
}

// MARK: Internals
internal extension MLCardFormESCConfig {
    static func createConfig(enabled: Bool = false, sessionId: String? = nil, flow: String? = nil) -> MLCardFormESCConfig {
        var sessionId = sessionId
        if sessionId == nil {
            sessionId = MLCardFormTracker.sharedInstance.getSessionID()
        }
        var flow = flow
        if flow == nil {
            flow = MLCardFormTracker.sharedInstance.getFlowName() ?? "MLCardForm"
        }
        return MLCardFormESCConfig(enabled, sessionId ?? "", flow ?? "")
    }
}
