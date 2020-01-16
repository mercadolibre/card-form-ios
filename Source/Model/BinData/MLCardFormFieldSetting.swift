//
//  MLCardFormFieldSetting.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 28/10/2019.
//

import Foundation

struct MLCardFormFieldSetting: Codable {
    let name: String
    let lenght: Int?
    let type: String
    let title: String
    let mask: String?
    let hintMessage: String?
    let validationPattern: String?
    let validationMessage: String?
}

extension MLCardFormFieldSetting {
    static func createSettingForField(_ field: MLCardFormFields, remoteSetting: MLCardFormFieldSetting? = nil, cardUI: MLCardFormCardUI? = nil) -> MLCardFormFieldSetting? {
        switch field {
        case .cardNumber:
            guard let cardUI = cardUI  else { return nil }
            let name: String = field.rawValue
            let type: String = "number"
            let title: String = "Número de tarjeta".localized
            let validationMessage: String = "Completa este campo".localized
            
            let lenght: Int = cardUI.cardNumberLength
            let mask = cardUI.cardPattern.map {
                String(repeating: "$", count: $0)
                }.joined(separator: " ")
            
            return MLCardFormFieldSetting(name: name, lenght: lenght, type: type, title: title, mask: mask, hintMessage: nil, validationPattern: cardUI.validation, validationMessage: validationMessage)
        case .securityCode:
            guard let remoteSetting = remoteSetting, let cardUI = cardUI  else { return nil }
            let name: String = remoteSetting.name
            let type: String = remoteSetting.type
            let title: String = remoteSetting.title
            let validationMessage: String? = remoteSetting.validationMessage
            let hintMessage: String? = remoteSetting.hintMessage
            
            let lenght: Int = cardUI.securityCodeLength
            let mask = String(repeating: "$", count: lenght)
            
            return MLCardFormFieldSetting(name: name, lenght: lenght, type: type, title: title, mask: mask, hintMessage: hintMessage, validationPattern: nil, validationMessage: validationMessage)
        default:
            return nil
        }
    }
}
