//
//  MLCardFormFieldPropertyProtocol.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/31/19.
//

import Foundation

public protocol MLCardFormFieldPropertyProtocol {
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
    func shouldShowToolBar() -> Bool
    func shouldChangeFocusOnMaxLength() -> Bool
    func pickerOptions() -> [(id: String, value: String)]?
    func shouldShowPickerInput() -> Bool
    func inputConstraintWidthMultiplier() -> CGFloat?
    mutating func setValue(value: String)
    
    func isValid(value: String?) -> Bool
    func isExtraValid(value: String?) -> Bool
}

extension MLCardFormFieldPropertyProtocol {
    public func defaultValue() -> String? {
        return nil
    }
    
    public func keyboardBackEnabled() -> Bool {
        return true
    }

    public func keyboardHeight() -> CGRect? {
        return CGRect.zero
    }
    
    public func shouldShowTick() -> Bool {
        return false
    }
    
    public func shouldShowToolBar() -> Bool {
        return true
    }

    public func shouldChangeFocusOnMaxLength() -> Bool {
        return false
    }

    public func pickerOptions() -> [(id: String, value: String)]? {
        return nil
    }
    
    public func shouldShowPickerInput() -> Bool { 
        return false
    }
    
    public func inputConstraintWidthMultiplier() -> CGFloat? {
        return nil
    }

    public mutating func setValue(value: String) {}
    
    public func isValid(value: String?) -> Bool {
        guard let value = value else { return false }
        return (minLenght()...maxLenght()).contains(value.count)
    }
    
    public func isExtraValid(value: String?) -> Bool {
        return true
    }
}
