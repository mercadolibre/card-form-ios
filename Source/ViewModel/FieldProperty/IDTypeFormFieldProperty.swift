//
//  IDTypeFormFieldProperty.swift
//  MLCardForm
//
//  Created by Eric Ertl on 08/11/2019.
//

import Foundation

struct IDTypeFormFieldProperty : MLCardFormFieldPropertyProtocol {
    private let identificationTypes: [MLCardFormIdentificationType]?
    private let idTypeValue: String?
    private let keyBoardHeight: CGRect?
    
    init(identificationTypes: [MLCardFormIdentificationType]? = nil,
         idTypeValue: String? = nil, keyboardHeight: CGRect? = nil) {
        self.identificationTypes = identificationTypes
        self.idTypeValue = idTypeValue
        self.keyBoardHeight = keyboardHeight
    }

    func fieldId() -> String {
        return MLCardFormFields.identificationTypesPicker.rawValue
    }
    
    func fieldTitle() -> String {
        return " "
    }
    
    func minLenght() -> Int {
        return 1
    }
    
    func maxLenght() -> Int {
        return 10
    }
    
    func defaultValue() -> String? {
        return idTypeValue
    }
    
    func helpMessage() -> String? {
        return nil
    }
    
    func errorMessage() -> String? {
        return nil
    }
    
    func patternMask() -> String? {
        return nil
    }

    func validationPattern() -> String? {
        return nil
    }
    
    func keyboardType() -> UIKeyboardType? {
        return nil
    }

    func keyboardHeight() -> CGRect? {
        return keyBoardHeight
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
    
    func pickerOptions() -> [(id: String, value: String)]? {
        if let idTypes = identificationTypes {
            var response = [(id: String, value: String)]()
            for idType in idTypes {
                response.append((idType.id, idType.name.uppercased()))
            }
            return response
        }
        return nil
    }
    
    func shouldShowPickerInput() -> Bool {
        return true
    }
    
    func inputConstraintWidthMultiplier() -> CGFloat? {
        return 0.25
    }
}
