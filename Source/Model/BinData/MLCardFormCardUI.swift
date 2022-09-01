import Foundation
import MLCardDrawer

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
    let validation: String?
    let extraValidations: [MLCardFormExtraValidation]?
    let pan: MLCardFormPAN?
    
    func changeIssuerImageUrl(issuerImageUrl: String?) -> MLCardFormCardUI {
        return MLCardFormCardUI(cardNumberLength: self.cardNumberLength, cardPattern: self.cardPattern, cardColor: self.cardColor, cardFontColor: self.cardFontColor, cardFontType: self.cardFontType, securityCodeLocation: self.securityCodeLocation, securityCodeLength: self.securityCodeLength, issuerImageUrl: issuerImageUrl, paymentMethodImageUrl: self.paymentMethodImageUrl, issuerImage: issuerImageUrl, paymentMethodImage: self.paymentMethodImage, validation: self.validation, extraValidations: self.extraValidations, pan: self.pan)
    }
}
