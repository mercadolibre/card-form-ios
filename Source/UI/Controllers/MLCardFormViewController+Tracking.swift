//
//  MLCardFormViewController+Tracking.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

// MARK: Tracking
extension MLCardFormViewController {
    
    func trackScreen(fieldId: MLCardFormFields? = nil) {
        guard let cardType = viewModel.getPaymentMethodTypeId() else {
            return
        }
        let path = getScreenPath(cardType: cardType, fieldId: fieldId)
        let properties: [String: Any] = [:]
        MLCardFormTracker.sharedInstance.trackScreen(screenName: path, properties: properties)
    }
    
    func trackError(errorMessage: String) {
        guard let cardType = self.viewModel.getPaymentMethodTypeId() else {
            return
        }
        var properties: [String: Any] = [:]
        properties["path"] = getScreenPath(cardType: cardType)
        properties["id"] = getIdError()
        properties["message"] = errorMessage
        MLCardFormTracker.sharedInstance.trackEvent(path: "", properties: properties)
    }
    
    func getScreenPath(cardType: String, fieldId: MLCardFormFields? = nil) -> String {
        var screenPath = ""
        guard let fieldId = fieldId else { return screenPath }
        
        switch fieldId {
        case MLCardFormFields.cardNumber,
             MLCardFormFields.name,
             MLCardFormFields.expiration,
             MLCardFormFields.securityCode,
             MLCardFormFields.identificationTypesPicker,
             MLCardFormFields.identificationTypeNumber:
            screenPath = ""
        }
        return screenPath
    }
    
    func getIdError(fieldId: MLCardFormFields? = nil) -> String {
        var idError = ""
        guard let fieldId = fieldId else { return idError }
        
        switch fieldId {
        case MLCardFormFields.cardNumber,
             MLCardFormFields.name,
             MLCardFormFields.expiration,
             MLCardFormFields.securityCode,
             MLCardFormFields.identificationTypesPicker,
             MLCardFormFields.identificationTypeNumber:
            idError = ""
        }
        return idError
    }
}
