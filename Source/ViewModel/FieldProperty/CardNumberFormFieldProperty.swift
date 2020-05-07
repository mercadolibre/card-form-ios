//
//  CardNumberFormFieldProperty.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 07/11/2019.
//

import Foundation
import MLCardDrawer

struct CardNumberFormFieldProperty : MLCardFormFieldPropertyProtocol {
    let remoteSetting: MLCardFormFieldSetting?
    let cardNumberValue: String?
    private let SEVENTH_DIGIT = "seventh_digit"
    
    init(remoteSetting: MLCardFormFieldSetting? = nil,
         cardNumberValue: String? = nil) {
        self.remoteSetting = remoteSetting
        self.cardNumberValue = cardNumberValue
    }

    func fieldId() -> String {
        if let name = remoteSetting?.name {
            return name
        }
        return MLCardFormFields.cardNumber.rawValue
    }

    func fieldTitle() -> String {
        if let title = remoteSetting?.title {
            return title
        }
        return "Número de tarjeta".localized
    }

    func minLenght() -> Int {
        if let lenght = remoteSetting?.lenght {
            return lenght
        }
        return 16
    }

    func maxLenght() -> Int {
        return minLenght()
    }

    func defaultValue() -> String? {
        return cardNumberValue
    }

    func helpMessage() -> String? {
        return remoteSetting?.hintMessage
    }

    func errorMessage() -> String? {
        if let error = remoteSetting?.validationMessage {
            return error
        }
        return "Número de tarjeta inválido".localized
    }

    func patternMask() -> String? {
        if let mask = remoteSetting?.mask {
            return mask
        }
        return "$$$$ $$$$ $$$$ $$$$"
    }

    func validationPattern() -> String? {
        return remoteSetting?.validationPattern
    }

    func keyboardType() -> UIKeyboardType? {
        return .numberPad
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
    
    func shouldShowTick() -> Bool {
        return true
    }
    
    func isValid(value: String?) -> Bool {
        guard let value = value, !value.isEmpty, isExtraValid(value: value) else { return false }

        let cleanValue = value.removingWhitespaceAndNewlines()
        
        if let remoteSettingLenght = remoteSetting?.lenght, cleanValue.count != remoteSettingLenght {
            return false
        } else if let pattern = validationPattern(), pattern.lowercased() == "none" {
            return true

        //*** Update IIN prefixes and length requriements if CardState is used ***//
//        } else {
//            switch CardState(fromPrefix: cleanValue) {
//            case .identified(let cardType):
//                let cardNumberLength = cardType.segmentGroupings.reduce(0, +)
//                if cleanValue.count != cardNumberLength {
//                    return false
//                }
//            default:
//                return false
//            }
        }
        
        var sum = 0
        let digitStrings = cleanValue.reversed().map { String($0) }
        
        for tuple in digitStrings.enumerated() {
            if let digit = Int(tuple.element) {
                let odd = tuple.offset % 2 == 1
                
                switch (odd, digit) {
                case (true, 9):
                    sum += 9
                case (true, 0...8):
                    sum += (digit * 2) % 9
                default:
                    sum += digit
                }
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    
    func isExtraValid(value: String?) -> Bool {
        guard let cleanValue = value?.removingWhitespaceAndNewlines(),
            cleanValue.count >= 7,
            let seventhDigit = cleanValue.prefix(7).last else { return false }

        if let extraValidations = remoteSetting?.extraValidations,
            let validation = extraValidations.first(where: { $0.name == SEVENTH_DIGIT }),
            !validation.values.isEmpty {
                for value in validation.values {
                    if value == String(seventhDigit) {
                        return true
                    }
                }
                return false
        }
        return true
    }
    
    func keyboardBackEnabled() -> Bool {
        return false
    }
}
