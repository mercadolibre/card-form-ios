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
    
    func trackScreenGA(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()),
            var path = getStepNameGA(cardFormField) else { return }
        
        var trackModel = MLCardFormGAModel()
        
        switch fieldId {
        case MLCardFormFields.securityCode:
            return
        default:
            break
        }
        trackModel.screen = "/CARD_FORM/" + path
        MLCardFormTracker.sharedInstance.trackScreenGA(trackInfo: trackModel)
    }
    
    func trackScreenIssuersGA() {
        var trackModel = MLCardFormGAModel()
        trackModel.screen = "/CARD_FORM/ISSUERS"
        MLCardFormTracker.sharedInstance.trackScreenGA(trackInfo: trackModel)
    }
    
    func trackInvalidEventGA(_ cardFormField: MLCardFormField) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()) else { return }
        var path = ""

        switch fieldId {
        case MLCardFormFields.securityCode:
            path = "CVV_INVALID"
        case MLCardFormFields.expiration:
            path = "DATE_INVALID"
        case MLCardFormFields.cardNumber:
            path = "INVALID"
        default:
            path = "INVALID"
        }

        var trackModel = MLCardFormGAModel()
        trackModel.action = path
        MLCardFormTracker.sharedInstance.trackEventGA(trackInfo: trackModel)
    }
    
    func getStepNameGA(_ cardFormField: MLCardFormField) -> String? {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()) else { return nil }
        
        switch fieldId {
        case MLCardFormFields.cardNumber:
            return "BIN_NUMBER"
        case MLCardFormFields.name:
            return "NAME"
        case MLCardFormFields.expiration,
            MLCardFormFields.securityCode:
            return "EXPIRATION_SECURITY"
        case MLCardFormFields.identificationTypesPicker,
            MLCardFormFields.identificationTypeNumber:
            return "IDENTIFICATION"
        }
    }
}
