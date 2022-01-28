//
//  MLCardFormTracker.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

final class MLCardFormTracker: NSObject {
    internal enum TrackerParams: String {
        case sessionId = "session_id"
        case sessionTime  = "session_time"
        case siteId = "site_id"
        case flowId = "flow_id"
        case bin
        case issuer
        case paymentMethodId = "payment_method_id"
        case paymentMethodType = "payment_method_type"
        case errorStep = "error_step"
        case errorMessage = "error_message"
        case dimensionFlowId = "89"
        case dimensionMarketplace = "7"
        case dimensionCore = "8"
        var value: String {
            return self.rawValue
        }
    }
    internal static let sharedInstance = MLCardFormTracker()
    private let category = "/CARD_FORM/"
    private var sessionService: MLCardFormSessionService = MLCardFormSessionService()
    private var trackerDelegate: MLCardFormTrackerDelegate?
    private var trackerStore: MLCardFormTrackingStore = MLCardFormTrackingStore.sharedInstance
    
}

// MARK: Getters/setters.
internal extension MLCardFormTracker {
    func setTrackerDelegate(_ delegate: MLCardFormTrackerDelegate) {
        trackerDelegate = delegate
    }

    func set(flowId: String, siteId: String) {
        trackerStore.flowId = flowId
        trackerStore.siteId = siteId
    }

    func startNewSession() {
        sessionService.startNewSession()
        trackerStore.initializeInitDate()
    }
    
    func getSessionID() -> String {
        return sessionService.getSessionId()
    }
    
    func clean() {
        trackerStore.clean()
    }
}

// MARK: Track methods.
internal extension MLCardFormTracker {
    func trackScreen(screenName: String, properties: [String: Any] = [:]) {
        if let delegate = trackerDelegate {
            let metadata = buildCommonParams(properties)
            delegate.trackScreen(screenName: screenName, extraParams: metadata)
        }
    }
    
    func trackEvent(path: String, properties: [String: Any] = [:]) {
        if let delegate = trackerDelegate {
            let metadata = buildCommonParams(properties)
            delegate.trackEvent(screenName: path, extraParams: metadata)
        }
    }
    
    func trackScreenGA(trackInfo: MLCardFormGAModel) {
        if let delegate = trackerDelegate {
            trackInfo.category = category
            trackInfo.customDimensions = buildCommonParamsGA(trackInfo.customDimensions)
            delegate.trackScreenGA(trackInfo: trackInfo)
        }
    }
    
    func trackEventGA(trackInfo: MLCardFormGAModel) {
        if let delegate = trackerDelegate {
            trackInfo.category = category
            trackInfo.customDimensions = buildCommonParamsGA(trackInfo.customDimensions)
            delegate.trackEventGA(trackInfo: trackInfo)
        }
    }

    private func buildCommonParams(_ properties: [String: Any]) -> [String: Any] {
        var metadata = properties
        if let flowId = trackerStore.flowId {
            metadata[TrackerParams.flowId.value] = flowId
        }
        if let siteId = trackerStore.siteId {
            metadata[TrackerParams.siteId.value] = siteId
        }
        metadata[TrackerParams.sessionId.value] = getSessionID()
        metadata[TrackerParams.sessionTime.value] = trackerStore.getSecondsAfterInit()
        return metadata
    }
    
    private func buildCommonParamsGA(_ properties: [String: Any]) -> [String: Any] {
        var metadata = properties
        metadata[TrackerParams.dimensionMarketplace.value] = "MARKETPLACE"
        metadata[TrackerParams.dimensionCore.value] = "CORE"
        if let flowId = trackerStore.flowId {
            metadata[TrackerParams.dimensionFlowId.value] = flowId
        }
        return metadata
    }
}
