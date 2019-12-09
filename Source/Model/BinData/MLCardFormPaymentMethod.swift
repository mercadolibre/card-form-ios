//
//  MLCardFormPaymentMethod.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 28/10/2019.
//

import Foundation

struct MLCardFormPaymentMethod: Codable {
    let paymentMethodId: String
    let paymentTypeId: String
    let name: String
    let processingModes: [String]
}
