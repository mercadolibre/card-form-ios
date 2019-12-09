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
//        #if DEBUG
//        return true
//        #else
        guard let value = value, value.count == patternMask()?.count else { return false }
        let cleanValue = value.replacingOccurrences(of: " ", with: "")
        
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
//        #endif
    }
    
    func keyboardBackEnabled() -> Bool {
        return false
    }
}
