//
//  MLCardFormAddCardService.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 15/11/2019.
//

import Foundation
import MLCardDrawer

enum MLCardFormAddCardServiceError: Error {
    case missingKeys
    case missingPrivateKey
}

final class MLCardFormAddCardService {
    private var publicKey: String?
    private var privateKey: String?
    weak var delegate: MLCardFormInternetConnectionProtocol?
    
    func update(publicKey: String?, privateKey: String?) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}

// MARK: QueryParams
extension MLCardFormAddCardService {
    enum QueryKeys {
        case publicKey
        case accessToken

        var getKey: String {
            switch self {
            case .publicKey:
                return "public_key"
            case .accessToken:
                return "access_token"
            }
        }
    }
    
    struct KeyParam {
        let publicKey: String?
        let accessToken: String?
        
        init(publicKey: String? = nil, accessToken: String? = nil) {
            self.publicKey = publicKey
            self.accessToken = accessToken
        }
    }

    struct AddCardParams {
        let accessToken: String
    }
}

extension MLCardFormAddCardService {
    func addCardToken(tokenizationData: MLCardFormAddCardService.TokenizationBody, addCardData: MLCardFormAddCardService.AddCardBody, completion: ((Result<MLCardFormTokenizationCardData, Error>) -> ())? = nil) {
        if publicKey == nil && privateKey == nil {
            completion?(.failure(MLCardFormAddCardServiceError.missingKeys))
            return
        }

        if let internetConnection = delegate?.hasInternetConnection(), !internetConnection {
            completion?(.failure(NetworkLayerError.noInternetConnection))
            return
        }
        let queryParams = MLCardFormAddCardService.KeyParam(publicKey: publicKey, accessToken: privateKey)
        let headers = MLCardFormAddCardService.Headers(contentType: "application/json")
        NetworkLayer.request(router: MLCardFormApiRouter.postCardTokenData(queryParams, headers, buildTokenizationBody(tokenizationData))) { (result: Result<MLCardFormTokenizationCardData, Error>) in
            completion?(result)
        }
    }
    
    func saveCard(tokenId: String, addCardData: MLCardFormAddCardService.AddCardBody, completion: ((Result<MLCardFormAddCardData, Error>) -> ())? = nil) {
        guard let privateKey = privateKey  else {
            completion?(.failure(MLCardFormAddCardServiceError.missingPrivateKey))
            return
        }
        let queryParams = MLCardFormAddCardService.AddCardParams(accessToken: privateKey)
        let headers = MLCardFormAddCardService.Headers(contentType: "application/json")
        NetworkLayer.request(router: MLCardFormApiRouter.postCardData(queryParams, headers, buildAddCardBody(tokenId, addCardData: addCardData))) {
            (result: Result<MLCardFormAddCardData, Error>) in
            completion?(result)
        }
    }
}

// MARK: HTTP Bodies & Headers
extension MLCardFormAddCardService {
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

    func buildAddCardBody(_ tokenId: String, addCardData: MLCardFormAddCardService.AddCardBody) -> MLCardFormAddCardBody {
        return MLCardFormAddCardBody(cardTokenId: tokenId, paymentMethod: addCardData.paymentMethod, issuer: addCardData.issuer)
    }

    func debugLog(_ message: Any) {
        #if DEBUG
        if let messageStr = message as? String {
            print("MLCardFormAddCardService: \(messageStr)")
        } else {
            print(message)
        }
        #endif
    }
}
