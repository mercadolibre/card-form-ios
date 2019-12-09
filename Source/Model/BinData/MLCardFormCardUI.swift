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
    static func createCardUIForIssuerImage(_ currentModel: MLCardFormCardUI, newIssuerImageUrl: String?) -> MLCardFormCardUI {
        return MLCardFormCardUI(cardNumberLength: currentModel.cardNumberLength, cardPattern: currentModel.cardPattern, cardColor: currentModel.cardColor, cardFontColor: currentModel.cardFontColor, cardFontType: currentModel.cardFontType, securityCodeLocation: currentModel.securityCodeLocation, securityCodeLength: currentModel.securityCodeLength, issuerImageUrl: newIssuerImageUrl, paymentMethodImageUrl: currentModel.paymentMethodImageUrl, issuerImage: newIssuerImageUrl, paymentMethodImage: currentModel.paymentMethodImage)
    }
}
