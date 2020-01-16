//
//  CardNameFormFieldProperty.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 07/11/2019.
//

import Foundation

struct CardNameFormFieldProperty : MLCardFormFieldPropertyProtocol {
    let remoteSetting: MLCardFormFieldSetting?
    let cardNameValue: String?
    
    init(remoteSetting: MLCardFormFieldSetting? = nil,
         cardNameValue: String? = nil) {
        
        self.remoteSetting = remoteSetting
        self.cardNameValue = cardNameValue
    }
    
    func fieldId() -> String {
        if let name = remoteSetting?.name {
            return name
        }
        return MLCardFormFields.name.rawValue
    }

    func fieldTitle() -> String {
        if let title = remoteSetting?.title {
            return title
        }
        return "Nombre del titular".localized
    }

    func minLenght() -> Int {
        return 3
    }

    func maxLenght() -> Int {
        if let lenght = remoteSetting?.lenght {
            return lenght
        }
        return 50
    }
    
    func defaultValue() -> String? {
        return cardNameValue
    }

    func helpMessage() -> String? {
        return remoteSetting?.hintMessage
    }

    func errorMessage() -> String? {
        return remoteSetting?.validationMessage
    }

    func patternMask() -> String? {
        return remoteSetting?.mask
    }

    func validationPattern() -> String? {
        return remoteSetting?.validationPattern
    }

    func keyboardType() -> UIKeyboardType? {
        if let type = remoteSetting?.type, type == "number" {
            return .numberPad
        }
        return .default
    }

    func keyboardNextText() -> String? {
        return "Siguiente".localized
    }

    func keyboardBackText() -> String? {
        return "Anterior".localized
    }

    func shouldShowKeyboardClearButton() -> Bool {
        return true
    }
    
    func isValid(value: String?) -> Bool {
        guard let value = value else { return false }
        if minLenght() ... maxLenght() ~= value.count {
            if let pattern = validationPattern() {
                do {
                    let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                    let range = NSRange(value.startIndex..., in: value)
                    return regex.firstMatch(in: value, options: [], range: range) != nil
                } catch {
                    // regex was malformed!
                    return true
                }
            } else {
                return true
            }
        } else {
            return false
        }
    }
}
