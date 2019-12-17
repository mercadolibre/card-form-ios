//
//  MLCardFormBuilder.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

/**
 CardForm builder allows you to create a `MLCardForm`. You'll need a publicKey from MercadoPago Developers Site.
 */
@objcMembers
open class MLCardFormBuilder: NSObject {
    internal let publicKey: String?
    internal let lifeCycleDelegate: MLCardFormLifeCycleDelegate
    internal let privateKey: String?
    internal var siteId: String
    internal var flowId: String?
    internal var excludedPaymentTypes: [String]?
    internal var trackingConfiguration: MLCardFormTrackerConfiguration?
    internal var navigationCustomBackgroundColor: UIColor?
    internal var navigationCustomTextColor: UIColor?
    internal var animateOnLoad: Bool = false
    
    // MARK: Initialization
    
    /**
     Mandatory init.
     - parameter publicKey: Merchant public key / collector public key
     - parameter lifeCycleDelegate: The protocol to stay informed about credit card creation life cycle. (`didAddCard`)
     */
    public init(publicKey: String, siteId: String, lifeCycleDelegate: MLCardFormLifeCycleDelegate) {
        self.publicKey = publicKey
        self.siteId = siteId
        self.privateKey = nil
        self.lifeCycleDelegate = lifeCycleDelegate
    }
    
    /**
     Mandatory init.
     - parameter privateKey: Logged user key
     - parameter lifeCycleDelegate: The protocol to stay informed about credit card creation life cycle. (`didAddCard`)
     */
    public init(privateKey: String, siteId: String, lifeCycleDelegate: MLCardFormLifeCycleDelegate) {
        self.publicKey = nil
        self.privateKey = privateKey
        self.siteId = siteId
        self.lifeCycleDelegate = lifeCycleDelegate
    }
}

// MARK: - Setters/Builders
extension MLCardFormBuilder {
    @discardableResult @objc(setFlowIdWithID:)
    open func setFlowId(_ flowId: String) -> MLCardFormBuilder {
        self.flowId = flowId
        return self
    }

    @discardableResult
    open func setLanguage(_ language: String) -> MLCardFormBuilder {
        MLCardFormLocalizatorManager.shared.setLanguage(language)
        return self
    }

    @discardableResult @objc(setExcludedPaymentTypesWithTypes:)
    open func setExcludedPaymentTypes(_ excludedPaymentTypes: [String]) -> MLCardFormBuilder {
        self.excludedPaymentTypes = excludedPaymentTypes
        return self
    }

    /**
     It provides support for tracking related functionalities.
     - parameter trackingConfiguration: `MLCardFormTrackerConfiguration` object.
     */
    @discardableResult @objc(setTrackingConfigurationWithConfiguration:)
    open func setTrackingConfiguration(_ trackingConfiguration: MLCardFormTrackerConfiguration) -> MLCardFormBuilder {
        self.trackingConfiguration = trackingConfiguration
        return self
    }

    /**
     Customize navigation bar background color and tint text color.
     - parameter backgroundColor: `UIColor` object.
     - parameter textColor: `UIColor` object.
     */
    @discardableResult
    open func setNavigationBarCustomColor(backgroundColor: UIColor, textColor: UIColor) -> MLCardFormBuilder {
        self.navigationCustomBackgroundColor = backgroundColor
        self.navigationCustomTextColor = textColor
        return self
    }

    /**
     Determinates if MLCardForm ViewController should be present animated or not. Default is no animated. Use true only for your own custom transitions.
     - parameter animated: `Bool`
     */
    @discardableResult
    open func setAnimated(_ animated: Bool) -> MLCardFormBuilder {
        self.animateOnLoad = animated
        return self
    }
}
