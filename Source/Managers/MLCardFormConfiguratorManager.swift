//
//  MLCardFormConfiguratorManager.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//  Refactor by bgarelli, 10/25/2022

import MLMelidata
import MLAnalytics

public final class MLCardFormConfiguratorManager {
    public var builder: MLMelidataTrackBuilder?
    public var session: MLSession?

    static var escProtocol: MLCardFormESCProtocol = MLCardFormESCDefault()
    static var escConfig: MLCardFormESCConfig = MLCardFormESCConfig.createConfig()
    private static var shared = MLCardFormConfiguratorManager()

    public static func initialize() {
        MLCardFormTracker.sharedInstance.setTrackerDelegate(shared)
    }
    
    static func updateConfig(escEnabled: Bool = false) {
        let escConfig = MLCardFormESCConfig.createConfig(enabled: escEnabled)
        self.escConfig = escConfig
    }
}

extension MLCardFormConfiguratorManager: MLCardFormTrackerDelegate {
    public func trackScreen(screenName: String, extraParams: [String : Any]?) {
        self.builder = MLMelidata.trackView(withPath: screenName)
        self.builder?.withDictionary(extraParams)
        self.builder?.send()

        if MLAuthenticationManager.sharedInstance()?.getSession() != nil {
            self.session = MLAuthenticationManager.sharedInstance()?.getSession()
        }

        if let flowId = extraParams?["flow_id"] {
            MLGAI.sharedInstance()?
                .trackScreen(
                    withPath: screenName.uppercased(),
                    key: self.session?.siteId,
                    userId: self.session?.userId,
                    sampleRate: nil,
                    customDimensions: ["7": "MARKETPLACE", "8": "CORE", "89": flowId]
                )
        }
    }

    public func trackEvent(screenName: String?, extraParams: [String : Any]?) {
        self.builder = MLMelidata.trackEvent(withPath: screenName)
        self.builder?.withDictionary(extraParams)
        self.builder?.send()

        guard let screenName = screenName, screenName.contains("invalid"),
              let flowId = extraParams?["flow_id"]
        else { return }

        var action = "INVALID"
        if screenName.contains("date") {
            action = "DATE_" + action
        } else if screenName.contains("cvv") {
            action = "CVV_" + action
        }

        MLGAI.sharedInstance()?.trackEvent(
            withAction: action,
            category: "/CARD_FORM/",
            label: nil,
            value: nil,
            customDimensions: ["7": "MARKETPLACE", "8": "CORE", "89": flowId]
        )
    }
}
