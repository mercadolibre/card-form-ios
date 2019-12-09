//
//  MLCardFormTrackerConfiguration.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

@objcMembers
open class MLCardFormTrackerConfiguration: NSObject {
    let delegate: MLCardFormTrackerDelegate?
    let flowName: String?
    let flowDetails: [String: Any]?
    let sessionId: String?
    
    public init(delegate: MLCardFormTrackerDelegate? = nil,
                flowName: String? = nil,
                flowDetails: [String: Any]? = nil,
                sessionId: String?) {
        self.delegate = delegate
        self.flowName = flowName
        self.flowDetails = flowDetails
        self.sessionId = sessionId
    }
    
    internal func updateTracker() {
        if let delegate = delegate {
            MLCardFormTracker.sharedInstance.setDelegate(delegate: delegate)
            MLCardFormTracker.sharedInstance.setFlowName(name: flowName)
            MLCardFormTracker.sharedInstance.setFlowDetails(flowDetails: flowDetails)
        }
        if let sessionId = sessionId {
            MLCardFormTracker.sharedInstance.setCustomSessionId(sessionId)
        }
    }
}
