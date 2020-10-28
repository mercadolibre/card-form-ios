//
//  MLCardFormWebPayFinishInscriptionData.swift
//  MLCardForm
//
//  Created by Eric Ertl on 28/10/2020.
//

import Foundation

struct MLCardFormWebPayFinishInscriptionData: Codable {
    let responseCode: Int
    let tbkUser: String
    let errorMessage: String
    let cardNumber: String
    let bin: String
    let cardNumberLength: Int
    let issuerId: Int
}
