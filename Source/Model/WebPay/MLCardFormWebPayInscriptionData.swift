//
//  MLCardFormWebPayInscriptionData.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import Foundation

struct MLCardFormWebPayInscriptionData: Codable {
    let token: String
    let urlWebpay: String
    let errorMessage: String
}
