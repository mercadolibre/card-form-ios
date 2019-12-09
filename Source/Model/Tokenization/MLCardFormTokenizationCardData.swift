//
//  MLCardFormTokenizationCardData.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 15/11/2019.
//

import Foundation

struct MLCardFormTokenizationCardData: Codable {
    let id: String
    let publicKey: String?
    let firstSixDigits: String
    let expirationMonth: Int
    let expirationYear: Int
    let lastFourDigits: String
    let cardholder: MLCardFormCardHolder?
    let status: String?
    let dateCreated: String
    let dateLastUpdated: String?
    let dateDue: String?
    let luhnValidation: Bool
    let liveMode: Bool
    let requireEsc: Bool
    let cardNumberLength: Int
    let securityCodeLength: Int
    let esc: String?
}
