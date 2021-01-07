//
//  MLCardFormFinishInscriptionBody.swift
//  MLCardForm
//
//  Created by Eric Ertl on 21/10/2020.
//

import Foundation

struct MLCardFormFinishInscriptionBody: Codable {
    let siteId: String
    let cardholder: MLCardFormWebPayCardHolderData
    let token: String
}

struct MLCardFormWebPayCardHolderData: Codable {
    let name: String
    let identification: MLCardFormWebPayUserIdentifierData?
}
