//
//  DefaultCardDataHandler.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 07/11/2019.
//

import Foundation
import MLCardDrawer

class DefaultCardDataHandler: NSObject, CardData {
    // CardData
    var name = "Nombre y apellido".localized.uppercased()
    var number = ""
    var securityCode = ""
    var expiration = "MM/AA"

    // Extra MLCardForm fields
    var identificationType: String? = ""
    var identificationNumber: String? = ""
}

extension DefaultCardDataHandler: MLCardFormUserDataProtocol {
    func getName() -> String {
        return name
    }

    func getNumber() -> String {
        return number
    }

    func getSecurityCode() -> String {
        return securityCode
    }

    func getExpiration() -> String {
        return expiration
    }

    func getIdentificationType() -> String? {
        return identificationType
    }

    func getIdentificationTypeNumber() -> String? {
        return identificationNumber
    }
}
