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
        if let identificationType = getIdentificationType() {
            return identificationType.minLength
        }
        return 1
    }
    
    func maxLenght() -> Int {
        if let identificationType = getIdentificationType() {
            return identificationType.maxLength
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
            return .numbersAndPunctuation
        }
        
        if let type = remoteSetting?.type, type == "number" {
            return .numberPad
        }
        return .numbersAndPunctuation
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
    
    func isValid(value: String?) -> Bool {
        guard let value = value else { return false }
        let cleanValue = getUnmaskedValue(value: value)
        
        if !(minLenght()...maxLenght()).contains(cleanValue.count) {
            return false
        }
        
        if let identificationType = getIdentificationType() {
            switch identificationType.id {
            case "CPF":
                let characters = cleanValue.map { String($0) }
                let numbers = characters.map { Int($0) }.compactMap { $0 }
                guard numbers.count == 11 else { return false }
                let digits = Array(numbers[0..<9])
                let firstDigit = checkDigit(for: digits, upperBound: 9, lowerBound: 0, mod: 11)
                let secondDigit = checkDigit(for: digits + [firstDigit], upperBound: 9, lowerBound: 0, mod: 11)

                return firstDigit == numbers[9] && secondDigit == numbers[10]
            case "CNPJ":
                let characters = cleanValue.map { String($0) }
                let numbers = characters.map { Int($0) }.compactMap { $0 }
                guard numbers.count == 14 else { return false }
                let digits = Array(numbers[0..<12])
                let firstDigit = checkDigit(for: digits, upperBound: 9, lowerBound: 2, mod: 11)
                let secondDigit = checkDigit(for: digits + [firstDigit], upperBound: 9, lowerBound: 2, mod: 11)
                
                return firstDigit == numbers[12] && secondDigit == numbers[13]
            default:
                return true
            }
        }
        return true
    }
    
    mutating func setValue(value: String) {
        if value != idTypeValue {
            idTypeValue = value
            idNumberValue = ""
        }
    }
    
    private func getUnmaskedValue(value: String) -> String {
        guard let characterSet = patternMask()?.replacingOccurrences(of: "$", with: "", options: NSString.CompareOptions.literal, range:nil) else { return value }
        
        let characters = value.map { String($0) }
        let patternMaskCharacterSet = CharacterSet(charactersIn: characterSet)
        let charactersRemovingPatternMask = characters.filter {
            $0.rangeOfCharacter(from: patternMaskCharacterSet) == nil
        }
        
        return charactersRemovingPatternMask.joined()
    }
    
    private func checkDigit(for digits: [Int], upperBound: Int, lowerBound: Int, mod: Int, secondMod: Int = 10) -> Int {
        guard lowerBound < upperBound else { preconditionFailure("lower bound is greater than upper bound") }

        let factors = Array((lowerBound...upperBound).reversed())
        let multiplied = digits.reversed().enumerated().map {
            return $0.element * factors[$0.offset % factors.count]
        }
        let sum = multiplied.reduce(0, +)
        return (sum % mod) % secondMod
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
