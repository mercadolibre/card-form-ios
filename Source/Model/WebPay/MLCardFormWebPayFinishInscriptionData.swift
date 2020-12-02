//
//  MLCardFormWebPayFinishInscriptionData.swift
//  MLCardForm
//
//  Created by Eric Ertl on 28/10/2020.
//

import Foundation

struct MLCardFormWebPayFinishInscriptionData: Codable {
    let card: MLCardFormWebPayCard
}

struct MLCardFormWebPayCard: Codable {
    let id: String
    let firstSixDigits: String
    let number: String
    let expirationYear: Int
    let expirationMonth: Int
    let length: Int
    let issuer: MLCardFormWebPayIssuer
    let paymentMethod: MLCardFormWebPayPaymentMethod
}

struct MLCardFormWebPayIssuer: Codable {
    let id: Int
}

struct MLCardFormWebPayPaymentMethod: Codable {
    let id: String
    let name: String
    let paymentTypeId: String
}
