//
//  MLCardFormAddCardBody.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 22/11/2019.
//

import Foundation

struct MLCardFormAddCardBody: Codable {
    let cardTokenId: String
    let paymentMethod: MLCardFormAddCardPaymentMethod
    let issuer: MLCardFormAddCardIssuer
}
