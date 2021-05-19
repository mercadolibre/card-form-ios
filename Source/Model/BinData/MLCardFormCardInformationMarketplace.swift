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
}

public struct ItemForCardInfoMarketplace: Codable {
    let id:String
}
