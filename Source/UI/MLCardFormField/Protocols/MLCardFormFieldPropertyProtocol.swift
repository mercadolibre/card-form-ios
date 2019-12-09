//
//  MLCardFormFieldPropertyProtocol.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/31/19.
//

import Foundation

protocol MLCardFormFieldPropertyProtocol {
    func fieldId() -> String
    func fieldTitle() -> String

    func minLenght() -> Int
    func maxLenght() -> Int

    func defaultValue() -> String?

    func helpMessage() -> String?
    func errorMessage() -> String?

    func patternMask() -> String?
    func validationPattern() -> String?

    func keyboardType() -> UIKeyboardType?
    func keyboardNextText() -> String?
    func keyboardBackText() -> String?
    func keyboardBackEnabled() -> Bool
    func keyboardHeight() -> CGRect?
    func shouldShowKeyboardClearButton() -> Bool
    func shouldShowTick() -> Bool
    func shouldChangeFocusOnMaxLength() -> Bool
    func pickerOptions() -> [(id: String, value: String)]?
    func shouldShowPickerInput() -> Bool
    func inputConstraintWidthMultiplier() -> CGFloat?
    mutating func setValue(value: String)
    
    func isValid(value: String?) -> Bool
}

extension MLCardFormFieldPropertyProtocol {
    func defaultValue() -> String? {
        return nil
    }
    
    func keyboardBackEnabled() -> Bool {
        return true
    }

    func keyboardHeight() -> CGRect? {
        return CGRect.zero
    }
    
    func shouldShowTick() -> Bool {
        return false
    }

    func shouldChangeFocusOnMaxLength() -> Bool {
        return false
    }
    
    func pickerOptions() -> [(id: String, value: String)]? {
        return nil
    }
    
    func shouldShowPickerInput() -> Bool {
        return false
    }
    
    func inputConstraintWidthMultiplier() -> CGFloat? {
        return nil
    }
    
    mutating func setValue(value: String) {}
    
    func isValid(value: String?) -> Bool {
        guard let value = value else { return false }
        return (minLenght()...maxLenght()).contains(value.count)
    }
}
