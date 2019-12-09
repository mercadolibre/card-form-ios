//
//  MLCardFormTracker.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

@objc internal class MLCardFormTracker: NSObject {
    @objc internal static let sharedInstance = MLCardFormTracker()
    
    private weak var delegate: MLCardFormTrackerDelegate?
    private var flowDetails: [String: Any]?
    private var flowName: String?
    private var customSessionId: String?
    private var sessionService: MLCardFormSessionService = MLCardFormSessionService()
}

// MARK: Getters/setters.
internal extension MLCardFormTracker {
    
    func setDelegate(delegate: MLCardFormTrackerDelegate) {
        self.delegate = delegate
    }
    
    func setFlowDetails(flowDetails: [String: Any]?) {
        self.flowDetails = flowDetails
    }
    
    func setFlowName(name: String?) {
        self.flowName = name
    }
    
    func setCustomSessionId(_ customSessionId: String?) {
        self.customSessionId = customSessionId
    }
    
    func startNewSession() {
        sessionService.startNewSession()
    }
    
    func startNewSession(externalSessionId: String) {
        sessionService.startNewSession(externalSessionId: externalSessionId)
    }
    
    func getSessionID() -> String {
        return customSessionId ?? sessionService.getSessionId()
    }
    
    func getRequestId() -> String {
        return sessionService.getRequestId()
    }
    
    func clean() {
        MLCardFormTracker.sharedInstance.flowDetails = [:]
        MLCardFormTracker.sharedInstance.delegate = nil
    }
    
    func getFlowName() -> String? {
        return flowName
    }
}

// MARK: Public interfase.
internal extension MLCardFormTracker {
    func trackScreen(screenName: String, properties: [String: Any] = [:]) {
        if let delegate = delegate {
            var metadata = properties
            if let flowDetails = flowDetails {
                metadata["flow_detail"] = flowDetails
            }
            if let flowName = flowName {
                metadata["flow"] = flowName
            }
            metadata[MLCardFormSessionService.SESSION_ID_KEY] = getSessionID()
            //metadata["security_enabled"] = PXConfiguratorManager.hasSecurityValidation()
            metadata["session_time"] = MLCardFormTrackingStore.sharedInstance.getSecondsAfterInit()
            if let choType = MLCardFormTrackingStore.sharedInstance.getChoType() {
                metadata["checkout_type"] = choType
            }
            delegate.trackScreen(screenName: screenName, extraParams: metadata)
        }
    }
    
    func trackEvent(path: String, properties: [String: Any] = [:]) {
        if let delegate = delegate {
            var metadata = properties
            metadata[MLCardFormSessionService.SESSION_ID_KEY] = getSessionID()
            //metadata["security_enabled"] = PXConfiguratorManager.hasSecurityValidation()
            metadata["session_time"] = MLCardFormTrackingStore.sharedInstance.getSecondsAfterInit()
            if let choType = MLCardFormTrackingStore.sharedInstance.getChoType() {
                metadata["checkout_type"] = choType
            }
            metadata["session_time"] = MLCardFormTrackingStore.sharedInstance.getSecondsAfterInit()
            delegate.trackEvent(screenName: path, action: "", result: "", extraParams: metadata)
        }
    }
}
