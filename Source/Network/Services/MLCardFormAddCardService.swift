//
//  MLCardFormAddCardService.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 15/11/2019.
//

import Foundation
import MLCardDrawer

final class MLCardFormAddCardService: MLCardFormAddCardServiceBase {
    var bearer = "Bearer "
    func addCardToken(tokenizationData: MLCardFormAddCardService.TokenizationBody, completion: ((Result<MLCardFormTokenizationCardData, Error>) -> ())? = nil) {
        if publicKey == nil && privateKey == nil {
            completion?(.failure(MLCardFormAddCardServiceError.missingKeys))
            return
        }
        guard let privateKey = privateKey else {
            completion?(.failure(MLCardFormAddCardServiceError.missingPrivateKey))
            return
        }
        let accessBearerToken = bearer + privateKey

        if let internetConnection = delegate?.hasInternetConnection(), !internetConnection {
            completion?(.failure(NetworkLayerError.noInternetConnection))
            return
        }
        let queryParams = MLCardFormAddCardService.KeyParam(publicKey: publicKey, accessToken: privateKey)
        

        let headers = MLCardFormAddCardService.Headers(contentType: "application/json",
                                                       xFlowId: getFlowId(),
                                                       sessionId: MLCardFormTracker.sharedInstance.getSessionID(),
                                                       accessToken: accessBearerToken)
        
        NetworkLayer.request(router: MLCardFormApiRouter.postCardTokenData(headers, buildTokenizationBody(tokenizationData))) { (result: Result<MLCardFormTokenizationCardData, Error>) in
            completion?(result)
        }
    }
    
    func saveCard(tokenId: String, addCardData: MLCardFormAddCardService.AddCardBody, completion: ((Result<MLCardFormAddCardData, Error>) -> ())? = nil) {
        guard let privateKey = privateKey, let acceptThirdPartyCard = acceptThirdPartyCard, let activateCard = activateCard else {
            completion?(.failure(MLCardFormAddCardServiceError.missingPrivateKey))
            return
        }
        
        let accessBearerToken = bearer + privateKey
        let accessTokenParam = MLCardFormAddCardService.AccessTokenParam(accessToken: privateKey)
        let headers = MLCardFormAddCardService.Headers(contentType: "application/json",
                                                       xFlowId: getFlowId(),
                                                       sessionId: MLCardFormTracker.sharedInstance.getSessionID(),
                                                       accessToken: accessBearerToken)
        
        NetworkLayer.request(router: MLCardFormApiRouter.postCardData(headers, buildAddCardBody(tokenId, addCardData: addCardData, features: CardFormFeatures(acceptThirdPartyCard: acceptThirdPartyCard, activateCard: activateCard)))) {
            (result: Result<MLCardFormAddCardData, Error>) in
            completion?(result)
        }
    }
}

// MARK: HTTP Bodies & Headers
extension MLCardFormAddCardService {
    enum HeadersKeys {
        case contentType
        case xFlowId
        case sessionId
        case accessToken

        var getKey: String {
            switch self {
            case .contentType: return "content-type"
            case .xFlowId: return "x-flow-id"
            case .sessionId: return "X-Session-Id"
            case .accessToken: return "Authorization"
            }
        }
    }

    struct Headers {
        let contentType: String
        let xFlowId: String
        let sessionId: String
        let accessToken: String
    }

    struct TokenizationBody {
        let cardNumber: String
        let securityCode: String
        let expirationMonth: Int
        let expirationYear: Int
        let cardholder: MLCardFormCardHolder
        let device: MLCardFormDevice
    }

    struct AddCardBody {
        let paymentMethod: MLCardFormAddCardPaymentMethod
        let issuer: MLCardFormAddCardIssuer
    }
}

// MARK: Privates
private extension MLCardFormAddCardService {
    func buildTokenizationBody(_ tokenizationData: MLCardFormAddCardService.TokenizationBody) -> MLCardFormTokenizationBody {
        return MLCardFormTokenizationBody(cardNumber: tokenizationData.cardNumber, securityCode: tokenizationData.securityCode, expirationMonth: tokenizationData.expirationMonth, expirationYear: tokenizationData.expirationYear, cardholder: tokenizationData.cardholder, device: tokenizationData.device)
    }

    func buildAddCardBody(_ tokenId: String, addCardData: MLCardFormAddCardService.AddCardBody, features: CardFormFeatures) -> MLCardFormAddCardBody {
        return MLCardFormAddCardBody(cardTokenId: tokenId, paymentMethod: addCardData.paymentMethod, issuer: addCardData.issuer, features: features)
    }
}
