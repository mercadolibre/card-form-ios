//
//  IDNumberFormFieldProperty.swift
//  MLCardForm
//
//  Created by Eric Ertl on 08/11/2019.
//

import Foundation

struct IDNumberFormFieldProperty : MLCardFormFieldPropertyProtocol {
    private let identificationTypes: [MLCardFormIdentificationType]?
    var idTypeValue: String?
    private let remoteSetting: MLCardFormFieldSetting?
    private var idNumberValue: String?
    
    init(identificationTypes: [MLCardFormIdentificationType]? = nil,
         idTypeValue: String? = nil,
         remoteSetting: MLCardFormFieldSetting? = nil,
         idNumberValue: String? = nil) {
        self.identificationTypes = identificationTypes
        self.idTypeValue = idTypeValue
        self.remoteSetting = remoteSetting
        self.idNumberValue = idNumberValue
    }
    
    func fieldId() -> String {
        if let name = remoteSetting?.name {
            return name
        }
        return MLCardFormFields.identificationTypeNumber.rawValue
    }
    
    func fieldTitle() -> String {
        if let title = remoteSetting?.title {
            return title
        }
        return ""
    }
    
    func minLenght() -> Int {
        return 1
    }
    
    func maxLenght() -> Int {
        if let lenght = remoteSetting?.lenght {
            return lenght
        }
        return 20
    }
    
    func defaultValue() -> String? {
        return idNumberValue
    }
    
    func helpMessage() -> String? {
        return remoteSetting?.hintMessage
    }
    
    func errorMessage() -> String? {
        return remoteSetting?.validationMessage
    }
    
    func patternMask() -> String? {
        if let identificationType = getIdentificationType() {
            return identificationType.mask
        }
        
        return remoteSetting?.mask
    }

    func validationPattern() -> String? {
        return remoteSetting?.validationPattern
    }
    
    func keyboardType() -> UIKeyboardType? {
        if let identificationType = getIdentificationType() {
            let type = identificationType.type
            if type == "number" {
                return .numberPad
            }
            return .default
        }
        
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
    
    mutating func setValue(value: String) {
        if value != idTypeValue {
            idTypeValue = value
            idNumberValue = ""
        }
    }
    
    private func getIdentificationType() -> MLCardFormIdentificationType? {
        if let identificationTypes = identificationTypes,
            let idTypeValue = idTypeValue {
            let identificationType = identificationTypes.first(where: { $0.name == idTypeValue })
            
            return identificationType
        }
        return nil
    }
}
