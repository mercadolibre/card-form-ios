//
//  CardExpirationFormFieldProperty.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 07/11/2019.
//

import Foundation

struct CardExpirationFormFieldProperty : MLCardFormFieldPropertyProtocol {
    let remoteSetting: MLCardFormFieldSetting?
    
    init(remoteSetting: MLCardFormFieldSetting? = nil) {
        self.remoteSetting = remoteSetting
    }
    
    func fieldId() -> String {
        if let name = remoteSetting?.name {
            return name
        }
        return MLCardFormFields.expiration.rawValue
    }

    func fieldTitle() -> String {
        if let title = remoteSetting?.title {
            return title
        }
        return ""
    }

    func minLenght() -> Int {
        if let lenght = remoteSetting?.lenght {
            return lenght
        }
        return 4
    }

    func maxLenght() -> Int {
        return minLenght()
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
        return false
    }
    
    func shouldChangeFocusOnMaxLength() -> Bool {
        return true
    }
    
    func isValid(value: String?) -> Bool {
        guard let value = value,
            value.count == patternMask()?.count,
            let expirationDate = Calendar.current.dateFromExpiration(value) else { return false }

        if let endOfMonth = Calendar.current.date(byAdding: .month, value: 1, to: expirationDate) {
            let now = Date()
            if (endOfMonth < now) {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
}
