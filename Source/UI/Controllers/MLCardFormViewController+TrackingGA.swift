//
//  MLCardFormViewController+TrackingGA.swift
//  MLCardForm
//
//  Created by Yxzandra Carolina Cordero Giron on 07-01-22.
//

import Foundation
import UIKit

// MARK: Tracking GA
extension MLCardFormViewController {
    
    func trackValidEventGA(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            var path = getStepNameGA(cardFormField) else { return }
        
        var trackModel = MLCardFormGAModel()
        trackModel.action = "VALID_" + path
        trackModel.label = cardFormField.helpLabel.text
        MLCardFormTracker.sharedInstance.trackEventGA(trackInfo: trackModel)
    }
    
    func trackInvalidEventGA(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            var path = getStepNameGA(cardFormField) else { return }

        switch fieldId {
        case MLCardFormFields.cardNumber:
            path = "CARD_NUMBER"
        default:
            break
        }

        var trackModel = MLCardFormGAModel()
        trackModel.action = "ERROR_" + path
        trackModel.label = cardFormField.helpLabel.text
        MLCardFormTracker.sharedInstance.trackEventGA(trackInfo: trackModel)
    }
    
    func getStepNameGA(_ cardFormField: MLCardFormField) -> String? {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()) else { return nil }
        
        switch fieldId {
        case MLCardFormFields.cardNumber:
            return "BIN_NUMBER"
        case MLCardFormFields.name:
            return "NAME"
        case MLCardFormFields.expiration:
            return "EXPIRATION_DATE"
        case MLCardFormFields.securityCode:
            return "SECURITY_CODE"
        case MLCardFormFields.identificationTypesPicker,
             MLCardFormFields.identificationTypeNumber:
            return "IDENTIFICATION_NUMBER"
        }
    }
}
