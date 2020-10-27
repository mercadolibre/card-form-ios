//
//  MLCardFormWebPayService.swift
//  MLCardForm
//
//  Created by Eric Ertl on 21/10/2020.
//

import Foundation

final class MLCardFormWebPayService {
    weak var delegate: MLCardFormInternetConnectionProtocol?
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
    
    struct InitInscriptionBody: Codable {
        let username: String
        let email: String
        let responseUrl: String
    }
}

extension MLCardFormWebPayService {
    func initInscription(inscriptionData: MLCardFormWebPayService.InitInscriptionBody, completion: ((Result<MLCardFormWebPayInscriptionData, Error>) -> ())? = nil) {
        let headers = MLCardFormWebPayService.Headers(contentType: "application/json")
        NetworkLayer.request(router: MLCardFormApiRouter.postWebPayInitInscription(headers, buildWebPayInscriptionBody(inscriptionData: inscriptionData))) {
            (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            completion?(result)
        }
    }
}

private extension MLCardFormWebPayService {
    func buildWebPayInscriptionBody(inscriptionData: MLCardFormWebPayService.InitInscriptionBody) -> MLCardFormInitInscriptionBody {
        return MLCardFormInitInscriptionBody(username: inscriptionData.username, email: inscriptionData.email, responseUrl: inscriptionData.responseUrl)
    }
}
