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
    internal let flowId: String
    internal let siteId: String
    internal let cardInfoMarketplace: MLCardFormCardInformationMarketplace?
    internal var excludedPaymentTypes: [String]?
    internal var navigationCustomBackgroundColor: UIColor?
    internal var navigationCustomTextColor: UIColor?
    internal var addStatusBarBackground: Bool?
    internal var animateOnLoad: Bool = false
    internal var shouldConfigureNavigation: Bool?
    internal let acceptThirdPartyCard: Bool
    internal let activateCard: Bool
    private var tracker: MLCardFormTracker = MLCardFormTracker.sharedInstance
    internal var productId: String?
    internal var platform: String?
    
    // MARK: Initialization
    
    /**
     Mandatory init.
     - parameter publicKey: Merchant public key / collector public key
     - parameter siteId: Country Meli/MP Site identifier - Ej: MLA, MLB..
     - parameter flowId: Your flow identifier. Using for tracking and traffic segmentation.
     - parameter acceptThirdPartyCard: Indicates if card form must accept cards with identity number that does not match MP user. Only for MLA.
     - parameter activateCard: Indicates if the card must be activated after its creation. Not activated card will be visible only once in PX checkout to that specific product.
     - parameter lifeCycleDelegate: The protocol to stay informed about credit card creation life cycle. (`didAddCard`)
     */
    public init(publicKey: String,
                siteId: String,
                flowId: String,
                acceptThirdPartyCard: Bool = true,
                activateCard: Bool = true,
                lifeCycleDelegate: MLCardFormLifeCycleDelegate,
                productId: String? = nil,
                platform: String? = nil) {
        self.publicKey = publicKey
        self.privateKey = nil
        self.siteId = siteId
        self.flowId = flowId
        self.lifeCycleDelegate = lifeCycleDelegate
        self.cardInfoMarketplace = nil
        self.acceptThirdPartyCard = acceptThirdPartyCard
        self.activateCard = activateCard
        tracker.set(flowId: flowId, siteId: siteId)
        self.productId = productId
        self.platform = platform
    }
    
    /// Mandatory init.
    /// - Parameters:
    ///   - publicKey: Merchant public key / collector public key
    ///   - cardInformation: Information related to the card and the transaction you will carry out with it.
    ///   - lifeCycleDelegate: The protocol to stay informed about credit card creation life cycle. (`didAddCard`)
    ///   - acceptThirdPartyCard: Indicates if card form must accept cards with identity number that does not match MP user. Only for MLA.
    ///   - activateCard: Indicates if the card must be activated after its creation. Not activated card will be visible only once in PX checkout to that specific product.
    
    public init(publicKey: String,
                acceptThirdPartyCard: Bool = true,
                activateCard: Bool = true,
                cardInformation:MLCardFormCardInformationMarketplace,
                lifeCycleDelegate: MLCardFormLifeCycleDelegate,
                productId: String? = nil,
                platform: String? = nil) {
        self.publicKey = publicKey
        self.privateKey = nil
        self.siteId = cardInformation.siteId
        self.flowId = cardInformation.flowId
        self.lifeCycleDelegate = lifeCycleDelegate
        self.cardInfoMarketplace = cardInformation
        self.acceptThirdPartyCard = acceptThirdPartyCard
        self.activateCard = activateCard
        tracker.set(flowId: flowId, siteId: siteId)
        self.productId = productId
        self.platform = platform
    }
    
    /**
     Mandatory init.
     - parameter privateKey: Logged access token - user key
     - parameter siteId: Country Meli/MP Site identifier - Ej: MLA, MLB..
     - parameter flowId: Your flow identifier. Using for tracking and traffic segmentation.
     - parameter acceptThirdPartyCard: Indicates if card form must accept cards with identity number that does not match MP user. Only for MLA.
     - parameter activateCard: Indicates if the card must be activated after its creation. Not activated card will be visible only once in PX checkout to that specific product.
     - parameter lifeCycleDelegate: The protocol to stay informed about credit card creation life cycle. (`didAddCard`)
     */
    public init(privateKey: String,
                siteId: String,
                flowId: String,
                acceptThirdPartyCard: Bool = true,
                activateCard: Bool = true,
                lifeCycleDelegate: MLCardFormLifeCycleDelegate,
                productId: String? = nil,
                platform: String? = nil) {
        self.publicKey = nil
        self.privateKey = privateKey
        self.siteId = siteId
        self.flowId = flowId
        self.lifeCycleDelegate = lifeCycleDelegate
        self.cardInfoMarketplace = nil
        self.acceptThirdPartyCard = acceptThirdPartyCard
        self.activateCard = activateCard
        tracker.set(flowId: flowId, siteId: siteId)
        self.productId = productId
        self.platform = platform
    }
    
    /// Mandatory init.
    /// - Parameters:
    ///   - privateKey: Logged access token - user key
    ///   - cardInformation: Information related to the card and the transaction you will carry out with it.
    ///   - lifeCycleDelegate: The protocol to stay informed about credit card creation life cycle. (`didAddCard`)
    ///   - acceptThirdPartyCard: Indicates if card form must accept cards with identity number that does not match MP user. Only for MLA.
    ///   - activateCard: Indicates if the card must be activated after its creation. Not activated card will be visible only once in PX checkout to that specific product.
    
    public init(privateKey: String,
                acceptThirdPartyCard: Bool = true,
                activateCard: Bool = true,
                cardInformation:MLCardFormCardInformationMarketplace,
                lifeCycleDelegate: MLCardFormLifeCycleDelegate,
                productId: String? = nil,
                platform: String? = nil) {
        self.publicKey = nil
        self.privateKey = privateKey
        self.siteId = cardInformation.siteId
        self.flowId = cardInformation.flowId
        self.lifeCycleDelegate = lifeCycleDelegate
        self.cardInfoMarketplace = cardInformation
        self.acceptThirdPartyCard = acceptThirdPartyCard
        self.activateCard = activateCard
        tracker.set(flowId: flowId, siteId: siteId)
        self.productId = productId
        self.platform = platform
    }
    
    public func getSiteId() -> String {
        return siteId
    }
}

// MARK: - Setters/Builders
extension MLCardFormBuilder {
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
     Determinates if MLCardForm ViewController should be add a view for the statusBar with the color of the navigationBar or not. Default is true.
     - parameter animated: `Bool`
     */
    @discardableResult
    open func setShouldAddStatusBarBackground(_ addStatusBarBackground: Bool) -> MLCardFormBuilder {
        self.addStatusBarBackground = addStatusBarBackground
        return self
    }

    /**
     Determinates if MLCardForm ViewController should be in charge of configuring navigation. Default is true.
     - parameter configureNavigation: `Bool`
     */
    @discardableResult
    open func setShouldConfigureNavigation(_ configureNavigation: Bool) -> MLCardFormBuilder {
        self.shouldConfigureNavigation = configureNavigation
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
