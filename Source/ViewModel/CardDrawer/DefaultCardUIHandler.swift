//
//  DefaultCardUIHandler.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 07/11/2019.
//

import Foundation
import MLCardDrawer

// Example - Default CardUI
class DefaultCardUIHandler: NSObject, CardUI {
    var placeholderName = "Nombre y apellido".localized.uppercased()
    var placeholderExpiration = "MM/AA"
    var bankImage: UIImage?
    var cardPattern = [4, 4, 4, 4]
    var cardFontColor: UIColor = .white
    var cardLogoImage: UIImage?
    var cardBackgroundColor: UIColor = .clear
    var securityCodeLocation: MLCardSecurityCodeLocation = .back
    var defaultUI = true
    var securityCodePattern = 3
    var cardLogoImageUrl: String?
    var bankImageUrl: String?

    func update(cardUI: MLCardFormCardUI?) {
        guard let cardDataUI = cardUI else { return }
        self.cardPattern = cardDataUI.cardPattern
        self.cardFontColor =  cardDataUI.cardFontColor.hexaToUIColor()
        self.cardBackgroundColor = cardDataUI.cardColor.hexaToUIColor()
        self.securityCodeLocation = cardDataUI.securityCodeLocation == "back" ? .back : .front
        self.defaultUI = true
        self.securityCodePattern = cardDataUI.securityCodeLength
        self.cardLogoImageUrl = cardUI?.paymentMethodImageUrl
        self.bankImageUrl = cardUI?.issuerImageUrl
    }
}
