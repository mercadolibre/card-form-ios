//
//  MLCardFormWebPayService.swift
//  MLCardForm
//
//  Created by Eric Ertl on 21/10/2020.
//

import Foundation

final class MLCardFormWebPayService: MLCardFormAddCardServiceBase {
    func initInscription(inscriptionData: MLCardFormWebPayService.InitInscriptionBody, completion: ((Result<MLCardFormWebPayInscriptionData, Error>) -> ())? = nil) {
        let headers = MLCardFormWebPayService.Headers(contentType: "application/json")
        NetworkLayer.request(router: MLCardFormApiRouter.postWebPayInitInscription(headers, buildWebPayInscriptionBody(inscriptionData: inscriptionData))) {
            (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            completion?(result)
        }
    }
    
    func finishInscription(inscriptionData: MLCardFormWebPayService.FinishInscriptionBody, completion: ((Result<MLCardFormWebPayFinishInscriptionData, Error>) -> ())? = nil) {
        let headers = MLCardFormWebPayService.Headers(contentType: "application/json")
        NetworkLayer.request(router: MLCardFormApiRouter.postWebPayFinishInscription(headers, buildWebPayFinishInscriptionBody(inscriptionData: inscriptionData))) {
            (result: Result<MLCardFormWebPayFinishInscriptionData, Error>) in
            completion?(result)
        }
    }
    
    func addCardToken(tokenizationData: MLCardFormWebPayService.TokenizationBody, completion: ((Result<MLCardFormTokenizationCardData, Error>) -> ())? = nil) {
        if publicKey == nil && privateKey == nil {
            completion?(.failure(MLCardFormAddCardServiceError.missingKeys))
            return
        }

        if let internetConnection = delegate?.hasInternetConnection(), !internetConnection {
            completion?(.failure(NetworkLayerError.noInternetConnection))
            return
        }
        let queryParams = MLCardFormWebPayService.KeyParam(publicKey: publicKey, accessToken: privateKey)
        let headers = MLCardFormWebPayService.Headers(contentType: "application/json")
        NetworkLayer.request(router: MLCardFormApiRouter.postWebPayCardTokenData(queryParams, headers, buildTokenizationBody(tokenizationData))) { (result: Result<MLCardFormTokenizationCardData, Error>) in
            completion?(result)
        }
    }
}

// MARK: HTTP Headers
extension MLCardFormWebPayService {
    enum HeadersKeys {
        case contentType

        var getKey: String {
            switch self {
            case .contentType:
                return "content-type"
            }
        }
    }

    struct Headers {
        let contentType: String
    }
    
    struct InitInscriptionBody {
        let username: String
        let email: String
        let responseUrl: String
    }
    
    struct FinishInscriptionBody {
        let token: String
    }
    
    struct TokenizationBody {
        let cardNumberId: String
        let truncCardNumber: String
        let expirationMonth: Int
        let expirationYear: Int
        let cardholder: MLCardFormCardHolder
        let device: MLCardFormDevice
    }
}

private extension MLCardFormWebPayService {
    func buildWebPayInscriptionBody(inscriptionData: MLCardFormWebPayService.InitInscriptionBody) -> MLCardFormInitInscriptionBody {
        return MLCardFormInitInscriptionBody(username: inscriptionData.username, email: inscriptionData.email, responseUrl: inscriptionData.responseUrl)
    }
    
    func buildWebPayFinishInscriptionBody(inscriptionData: MLCardFormWebPayService.FinishInscriptionBody) -> MLCardFormFinishInscriptionBody {
        return MLCardFormFinishInscriptionBody(token: inscriptionData.token)
    }
    
    func buildTokenizationBody(_ tokenizationData: MLCardFormWebPayService.TokenizationBody) -> MLCardFormWebPayTokenizationBody {
        return MLCardFormWebPayTokenizationBody(cardNumberId: tokenizationData.cardNumberId, truncCardNumber: tokenizationData.truncCardNumber, expirationMonth: tokenizationData.expirationMonth, expirationYear: tokenizationData.expirationYear, cardholder: tokenizationData.cardholder, device: tokenizationData.device)
    }
}
