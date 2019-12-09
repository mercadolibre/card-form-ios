//
//  MLCardFormCardUI.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 28/10/2019.
//

import Foundation

struct MLCardFormCardUI: Codable {
    let cardNumberLength: Int
    let cardPattern: [Int]
    let cardColor: String
    let cardFontColor: String
    let cardFontType: String
    let securityCodeLocation: String
    let securityCodeLength: Int
    let issuerImageUrl: String?
    let paymentMethodImageUrl: String?
    let issuerImage: String?
    let paymentMethodImage: String?
}

// MARK: MLCardFormCardUI Factory
extension MLCardFormCardUI {
    static func copyCardUIWithIssuerImage(_ cardFormCardUI: MLCardFormCardUI, issuerImageUrl: String?) -> MLCardFormCardUI {
        return MLCardFormCardUI(cardNumberLength: cardFormCardUI.cardNumberLength, cardPattern: cardFormCardUI.cardPattern, cardColor: cardFormCardUI.cardColor, cardFontColor: cardFormCardUI.cardFontColor, cardFontType: cardFormCardUI.cardFontType, securityCodeLocation: cardFormCardUI.securityCodeLocation, securityCodeLength: cardFormCardUI.securityCodeLength, issuerImageUrl: issuerImageUrl, paymentMethodImageUrl: cardFormCardUI.paymentMethodImageUrl, issuerImage: issuerImageUrl, paymentMethodImage: cardFormCardUI.paymentMethodImage)
    }
}
