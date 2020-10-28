//
//  MLCardFormWebPayTokenizationBody.swift
//  MLCardForm
//
//  Created by Eric Ertl on 28/10/2020.
//

import Foundation

struct MLCardFormWebPayTokenizationBody: Codable {
    let cardNumberId: String
    let truncCardNumber: String
    let expirationMonth: Int
    let expirationYear: Int
    let cardholder: MLCardFormCardHolder
    let device: MLCardFormDevice
}
