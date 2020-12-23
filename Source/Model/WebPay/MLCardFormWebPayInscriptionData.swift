//
//  MLCardFormWebPayInscriptionData.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import Foundation

struct MLCardFormWebPayInscriptionData: Codable {
    let tbkToken: String
    let urlWebpay: String
    let redirectUrl: String
    let user: MLCardFormWebPayUserData
}

struct MLCardFormWebPayUserData: Codable {
    let firstName: String
    let lastName: String
    let nickname: String
    let identifier: MLCardFormWebPayUserIdentifierData?
    let email: String
}

struct MLCardFormWebPayUserIdentifierData: Codable {
    let number: String?
    let type: String?
}
