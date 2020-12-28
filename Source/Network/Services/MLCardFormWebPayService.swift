//
//  MLCardFormWebPayService.swift
//  MLCardForm
//
//  Created by Eric Ertl on 21/10/2020.
//

import Foundation

final class MLCardFormWebPayService: MLCardFormAddCardServiceBase {
    private func getATParamAndCheckConnection(completion: ((Result<MLCardFormWebPayService.AccessTokenParam, Error>) -> ())? = nil) {
        guard let privateKey = privateKey else {
            completion?(.failure(MLCardFormAddCardServiceError.missingPrivateKey))
            return
        }

        if let internetConnection = delegate?.hasInternetConnection(), !internetConnection {
            completion?(.failure(NetworkLayerError.noInternetConnection))
            return
        }
        
        let accessTokenParam = MLCardFormWebPayService.AccessTokenParam(accessToken: privateKey)
        completion?(.success(accessTokenParam))
    }
    
    func initInscription(completion: ((Result<MLCardFormWebPayInscriptionData, Error>) -> ())? = nil) {
        getATParamAndCheckConnection(completion: { [weak self] (result: Result<MLCardFormAddCardServiceBase.AccessTokenParam, Error>) in
            switch result {
            case .success(let accessTokenParam):
                guard let self = self else { return }
                let headers = self.buildJSONHeaders()
                NetworkLayer.request(router: MLCardFormApiRouter.getWebPayInitInscription(accessTokenParam, headers)) {
                    (result: Result<MLCardFormWebPayInscriptionData, Error>) in
                    completion?(result)
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }
    
    func finishInscription(inscriptionData: MLCardFormFinishInscriptionBody, completion: ((Result<MLCardFormWebPayFinishInscriptionData, Error>) -> ())? = nil) {
        getATParamAndCheckConnection(completion: { [weak self] (result: Result<MLCardFormAddCardServiceBase.AccessTokenParam, Error>) in
            switch result {
            case .success(let accessTokenParam):
                guard let self = self else { return }
                let headers = self.buildJSONHeaders()
                NetworkLayer.request(router: MLCardFormApiRouter.postWebPayFinishInscription(accessTokenParam, headers, inscriptionData)) {
                    (result: Result<MLCardFormWebPayFinishInscriptionData, Error>) in
                    completion?(result)
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }
}

// MARK: HTTP Headers
extension MLCardFormWebPayService {
    enum HeadersKeys {
        case contentType
        case xpublic

        var getKey: String {
            switch self {
            case .contentType:
                return "content-type"
            case .xpublic:
                return "X-Public"
            }
        }
    }

    struct Headers {
        let contentType: String
        let xpublic: String
    }
}

private extension MLCardFormWebPayService {
    func buildJSONHeaders() -> MLCardFormWebPayService.Headers {
        return MLCardFormWebPayService.Headers(contentType: "application/json", xpublic: "true")
    }
}
