//
//  MLCardFormViewController+TrackingMelidata.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

// MARK: Tracking
extension MLCardFormViewController {
    
    func trackScreen(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            let screenName = getScreenName(cardFormField) else { return }
        
        switch fieldId {
        case MLCardFormFields.cardNumber,
             MLCardFormFields.expiration,
             MLCardFormFields.securityCode:
            MLCardFormTracker.sharedInstance.trackScreen(screenName: screenName)
        case MLCardFormFields.name:
            let prepopulated: Bool = !String.isNullOrEmpty(viewModel.storedCardName)
            MLCardFormTracker.sharedInstance.trackScreen(screenName: screenName, properties: ["prepopulated": prepopulated])
        case MLCardFormFields.identificationTypesPicker,
             MLCardFormFields.identificationTypeNumber:
            let prepopulated: Bool = !String.isNullOrEmpty(viewModel.storedIDNumber)
            MLCardFormTracker.sharedInstance.trackScreen(screenName: screenName, properties: ["prepopulated": prepopulated])
        }
    }
    
    func trackNextEvent(_ cardFormField: MLCardFormField) {
        trackNextPrevEvent(cardFormField, path: "/card_form/next")
    }
    
    func trackPreviousEvent(_ cardFormField: MLCardFormField) {
        trackNextPrevEvent(cardFormField, path: "/card_form/back")
    }
    
    func trackNextPrevEvent(_ cardFormField: MLCardFormField, path: String) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            let stepName = getStepName(cardFormField) else { return }
        switch fieldId {
        case MLCardFormFields.cardNumber,
             MLCardFormFields.name,
             MLCardFormFields.identificationTypeNumber:
            MLCardFormTracker.sharedInstance.trackEvent(path: path, properties: ["current_step": stepName])
        case MLCardFormFields.expiration:
            MLCardFormTracker.sharedInstance.trackEvent(path: path, properties: ["current_step": stepName + "_date"])
        case MLCardFormFields.securityCode:
            MLCardFormTracker.sharedInstance.trackEvent(path: path, properties: ["current_step": stepName + "_cvv"])
        default:
            break
        }
    }
    
    func trackValidEvent(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            let path = getScreenName(cardFormField) else { return }
        let validEventPath = "/valid"
        switch fieldId {
        case MLCardFormFields.cardNumber:
            viewModel.trackValidBinNumber(path: path + validEventPath)
        case MLCardFormFields.name,
            MLCardFormFields.identificationTypeNumber:
            MLCardFormTracker.sharedInstance.trackEvent(path: path + validEventPath)
        case MLCardFormFields.expiration:
            MLCardFormTracker.sharedInstance.trackEvent(path: path + "/date" + validEventPath)
        case MLCardFormFields.securityCode:
            MLCardFormTracker.sharedInstance.trackEvent(path: path + "/cvv" + validEventPath)
        default:
            break
        }
    }
    
    func trackInvalidEvent(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            let path = getScreenName(cardFormField) else { return }
        let invalidEventPath = "/invalid"
        switch fieldId {
        case MLCardFormFields.cardNumber:
            let bin_number = cardFormField.getUnmaskedValue() ?? ""
            MLCardFormTracker.sharedInstance.trackEvent(path: path + invalidEventPath, properties: ["bin_number": bin_number.prefix(6)])
        case MLCardFormFields.expiration:
            MLCardFormTracker.sharedInstance.trackEvent(path: path + "/date" + invalidEventPath)
        case MLCardFormFields.securityCode:
            MLCardFormTracker.sharedInstance.trackEvent(path: path + "/cvv" + invalidEventPath)
        case MLCardFormFields.identificationTypeNumber:
            if let idTypeCardFormField = viewModel.getCardFormFieldWithID(MLCardFormFields.identificationTypesPicker),
                let type = idTypeCardFormField.getValue(),
                let value = cardFormField.getUnmaskedValue() {
                MLCardFormTracker.sharedInstance.trackEvent(path: path + invalidEventPath, properties: ["type": type, "value": value])
            }
        default:
            break
        }
    }
    
    func trackClearEvent(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            let path = getScreenName(cardFormField) else { return }
        let clearEventPath = "/clear"
        switch fieldId {
        case MLCardFormFields.cardNumber,
             MLCardFormFields.name:
            MLCardFormTracker.sharedInstance.trackEvent(path: path + clearEventPath)
        default:
            break
        }
    }

    func trackErrorEvent(binNumber: String, error: Error) {
        var path = "/card_form/error"
        let errorMessage = error.localizedDescription
        var properties: [String: Any] = ["error_step": "bin_number", "error_message": errorMessage]
        switch error {
        case NetworkLayerError.statusCode(status: let status, message: _, userErrorMessage: _):
            if status == 400 {
                path = "/card_form/bin_number/unknown"
                properties = ["bin_number": binNumber.prefix(6)]
            }
        default:
            break
        }
        MLCardFormTracker.sharedInstance.trackEvent(path: path, properties: properties)
    }
    
    func trackScreenIssuers() {
        MLCardFormTracker.sharedInstance.trackScreen(screenName: "/card_form/issuers", properties: ["issuers_quantity": viewModel.getIssuers()?.count ?? 0])
    }
    
    func getScreenName(_ cardFormField: MLCardFormField) -> String? {
        guard let stepName = getStepName(cardFormField) else { return nil }
        return "/card_form/" + stepName
    }
    
    func getStepName(_ cardFormField: MLCardFormField) -> String? {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()) else { return nil }
        
        switch fieldId {
        case MLCardFormFields.cardNumber:
            return "bin_number"
        case MLCardFormFields.name:
            return "name"
        case MLCardFormFields.expiration,
             MLCardFormFields.securityCode:
            return "expiration_security"
        case MLCardFormFields.identificationTypesPicker,
             MLCardFormFields.identificationTypeNumber:
            return "identification"
        }
    }
}
