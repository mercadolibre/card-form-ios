//
//  MLCardFormWebPayService.swift
//  MLCardForm
//
//  Created by Eric Ertl on 21/10/2020.
//

import Foundation

final class MLCardFormWebPayService: MLCardFormAddCardServiceBase {
    func initInscription(inscriptionData: MLCardFormInitInscriptionBody, completion: ((Result<MLCardFormWebPayInscriptionData, Error>) -> ())? = nil) {
        let headers = buildJSONHeaders()
        NetworkLayer.request(router: MLCardFormApiRouter.postWebPayInitInscription(headers, inscriptionData)) {
            (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            completion?(result)
        }
    }
    
    func finishInscription(inscriptionData: MLCardFormFinishInscriptionBody, completion: ((Result<MLCardFormWebPayFinishInscriptionData, Error>) -> ())? = nil) {
        let headers = buildJSONHeaders()
        NetworkLayer.request(router: MLCardFormApiRouter.postWebPayFinishInscription(headers, inscriptionData)) {
            (result: Result<MLCardFormWebPayFinishInscriptionData, Error>) in
            completion?(result)
        }
    }
    
    func addCardToken(tokenizationData: MLCardFormWebPayTokenizationBody, completion: ((Result<MLCardFormTokenizationCardData, Error>) -> ())? = nil) {
        if publicKey == nil && privateKey == nil {
            completion?(.failure(MLCardFormAddCardServiceError.missingKeys))
            return
        }

        if let internetConnection = delegate?.hasInternetConnection(), !internetConnection {
            completion?(.failure(NetworkLayerError.noInternetConnection))
            return
        }
        let queryParams = MLCardFormWebPayService.KeyParam(publicKey: publicKey, accessToken: privateKey)
        let headers = buildJSONHeaders()
        NetworkLayer.request(router: MLCardFormApiRouter.postWebPayCardTokenData(queryParams, headers, tokenizationData)) { (result: Result<MLCardFormTokenizationCardData, Error>) in
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
}

private extension MLCardFormWebPayService {
    func buildJSONHeaders() -> MLCardFormWebPayService.Headers {
        return MLCardFormWebPayService.Headers(contentType: "application/json")
    }
}
