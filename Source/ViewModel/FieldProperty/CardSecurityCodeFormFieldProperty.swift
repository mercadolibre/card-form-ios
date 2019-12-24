//
//  CardSecurityCodeFormFieldProperty.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 07/11/2019.
//

import Foundation

struct CardSecurityCodeFormFieldProperty : MLCardFormFieldPropertyProtocol {
    let remoteSetting: MLCardFormFieldSetting?
    
    init(remoteSetting: MLCardFormFieldSetting? = nil) {
        self.remoteSetting = remoteSetting
    }

    func fieldId() -> String {
        if let name = remoteSetting?.name {
            return name
        }
        return MLCardFormFields.securityCode.rawValue
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
        return 3
    }

    func maxLenght() -> Int {
        if let lenght = remoteSetting?.lenght {
            return lenght
        }
        return 4
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
        return nil
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
}
