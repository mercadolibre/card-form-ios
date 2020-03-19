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
    var cardFontColor: UIColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    var cardLogoImage: UIImage?
    var cardBackgroundColor: UIColor = UIColor(red: 213/255, green: 213/255, blue: 213/255, alpha: 1)
    var securityCodeLocation: MLCardSecurityCodeLocation = .back
    var defaultUI = true
    var securityCodePattern = 3
    var cardLogoImageUrl: String?
    var bankImageUrl: String?
    var fontType: String = ""

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
        self.fontType = cardUI?.cardFontType ?? ""
    }
}
