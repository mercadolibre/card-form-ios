//
//  MLCardFormCardInformationMarketplace.swift
//  MLCardForm
//
//  Created by Cristian Enrrique Sarmiento Cabarcas on 19/05/21.
//

import Foundation


public struct MLCardFormCardInformationMarketplace: Codable {
    let flowId: String
    let vertical: String
    let flowType: String
    var bin: String
    let callerId: String
    let clientId: String
    let siteId: String
    let odr: Bool
    let items: Array<ItemForCardInfoMarketplace>
    
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

public struct ItemForCardInfoMarketplace: Codable {
    let id:String
    public init(id:String) {
        self.id = id
    }
}
