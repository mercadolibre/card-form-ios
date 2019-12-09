//
//  MLCardFormBinData.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 28/10/2019.
//

import Foundation

struct MLCardFormBinData: Codable {
    let escEnabled: Bool
    let enabled: Bool
    let errorMessage: String?
    let paymentMethod: MLCardFormPaymentMethod
    let cardUI: MLCardFormCardUI
    let additionalSteps: [String]
    let issuers: [MLCardFormIssuer]
    let fieldsSetting: [MLCardFormFieldSetting]
    let identificationTypes: [MLCardFormIdentificationType]

    // convertFromSnakeCase strategy converts cardUI to cardUi
    // https://developer.apple.com/documentation/foundation/jsondecoder/keydecodingstrategy/convertfromsnakecase
    enum CodingKeys: String, CodingKey {
        case escEnabled
        case enabled
        case errorMessage
        case paymentMethod
        case cardUI = "cardUi"
        case additionalSteps
        case issuers
        case fieldsSetting
        case identificationTypes
    }
}

// MARK: MLCardFormBinData Factory
extension MLCardFormBinData {
    static func cardFormBinDataWithFilteredIssuers(_ cardFormBinData: MLCardFormBinData, issuer: MLCardFormIssuer? = nil) -> MLCardFormBinData {
        var issuers: [MLCardFormIssuer]
        if let issuer = issuer {
            issuers = [issuer]
        } else {
            issuers = filterIssuersWithNoImage(cardFormBinData.issuers)
        }
        return MLCardFormBinData(escEnabled: cardFormBinData.escEnabled, enabled: cardFormBinData.enabled, errorMessage: cardFormBinData.errorMessage, paymentMethod: cardFormBinData.paymentMethod, cardUI: cardFormBinData.cardUI, additionalSteps: cardFormBinData.additionalSteps, issuers: issuers, fieldsSetting: cardFormBinData.fieldsSetting, identificationTypes: cardFormBinData.identificationTypes)
    }
    
    private static func filterIssuersWithNoImage(_ issuers: [MLCardFormIssuer]) -> [MLCardFormIssuer] {
        return issuers.filter{
            if let imageURL = $0.imageUrl {
                return !imageURL.isEmpty
            }
            return false
        }
    }
}
