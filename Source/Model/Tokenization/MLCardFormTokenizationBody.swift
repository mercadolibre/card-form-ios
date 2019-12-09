//
//  MLCardFormTokenizationBody.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 19/11/2019.
//

import Foundation

struct MLCardFormTokenizationBody: Codable {
    let cardNumber: String
    let securityCode: String
    let expirationMonth: Int
    let expirationYear: Int
    let cardholder: MLCardFormCardHolder
    let requireEsc: Bool = true
    let device: MLCardFormDevice
}
