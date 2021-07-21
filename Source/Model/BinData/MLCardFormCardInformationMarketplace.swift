//
//  MLCardFormCardInformationMarketplace.swift
//  MLCardForm
//
//  Created by Cristian Enrrique Sarmiento Cabarcas on 19/05/21.
//

import Foundation

@objcMembers
public class MLCardFormCardInformationMarketplace: NSObject, Codable {
    let flowId: String
    let vertical: String
    let flowType: String
    var bin: String
    let callerId: String
    let clientId: String
    let siteId: String
    let odr: Bool
    let items: Array<ItemForCardInfoMarketplace>
    
    /// init
    /// - Parameters:
    ///   - flowId: Your flow identifier. Using for tracking and traffic segmentation.
    ///   - vertical: Your vertical identifier. Using for tracking and traffic segmentation.
    ///   - flowType: Your flow type. Using for tracking and traffic segmentation.
    ///   - bin: First six numbers of the card (it must be sent empty and they are entered automatically)
    ///   - callerId: caller Id  used in service
    ///   - clientId: client Id  used in service
    ///   - siteId: Country Meli/MP Site identifier - Ej: MLA, MLB..
    ///   - odr: Indicate whether to get ODR icon
    ///   - items: List of items that are being used in the checkout flow
    public init(flowId: String,
                vertical: String,
                flowType: String,
                bin: String,
                callerId: String,
                clientId: String,
                siteId: String,
                odr: Bool,
                items: Array<ItemForCardInfoMarketplace>) {
        self.flowId = flowId
        self.vertical = vertical
        self.flowType = flowType
        self.bin = bin
        self.callerId = callerId
        self.clientId = clientId
        self.siteId = siteId
        self.odr = odr
        self.items = items
    }
}

@objcMembers
public class ItemForCardInfoMarketplace: NSObject, Codable {
    let id:String
    public init(id:String) {
        self.id = id
    }
}
