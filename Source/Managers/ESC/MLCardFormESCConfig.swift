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
    
    init(_ enabled: Bool) {
        self.enabled = enabled
    }

    public func getFlowId() -> String? {
        return MLCardFormTrackingStore.sharedInstance.flowId
    }

    public func getSessionId() -> String? {
        return MLCardFormTracker.sharedInstance.getSessionID()
    }
}

// MARK: Internals
internal extension MLCardFormESCConfig {
    static func createConfig(enabled: Bool = false) -> MLCardFormESCConfig {
        return MLCardFormESCConfig(enabled)
    }
}
