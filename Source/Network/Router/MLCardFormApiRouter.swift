//
//  MLCardFormApiRouter.swift
//  CardForm
//
//  Created by Juan sebastian Sanzone on 10/30/19.
//  Copyright © 2019 JS. All rights reserved.
//

import Foundation

enum MLCardFormApiRouter {

    case getCardData(MLCardFormBinService.QueryParams, MLCardFormBinService.Headers)
    case postCardTokenData(MLCardFormAddCardService.KeyParam, MLCardFormAddCardService.Headers, MLCardFormTokenizationBody)
    case postCardData(MLCardFormAddCardService.AccessTokenParam, MLCardFormAddCardService.Headers, MLCardFormAddCardBody)
    case getWebPayInitInscription(MLCardFormWebPayService.AccessTokenParam, MLCardFormWebPayService.Headers)
    case postWebPayFinishInscription(MLCardFormWebPayService.AccessTokenParam, MLCardFormWebPayService.Headers, MLCardFormFinishInscriptionBody)

    var scheme: String {
        switch self {
        case .getCardData, .postCardTokenData, .postCardData, .getWebPayInitInscription, .postWebPayFinishInscription:
            return "https"
        }
    }

    var host: String {
        switch self {
        case .getCardData, .postCardTokenData, .postCardData, .getWebPayInitInscription, .postWebPayFinishInscription:
            return "api.mercadopago.com"
        }
    }

    var path: String {
        switch self {
        case .getCardData:
            return "/production/px_mobile/v1/card"
        case .postCardTokenData:
            return "/v1/card_tokens"
        case .postCardData:
            return "/production/px_mobile/v1/card"
        case .getWebPayInitInscription:
            return "/production/px_mobile/v1/card_webpay/inscription/init"
        case .postWebPayFinishInscription:
            return "/production/px_mobile/v1/card_webpay/inscription/finish"
        }
    }

    var headers: [String : String]? {
        switch self {
        case .getCardData(_ , let headers):
            return [MLCardFormBinService.HeadersKeys.userAgent.getKey: headers.userAgent,
                    MLCardFormBinService.HeadersKeys.xDensity.getKey: headers.xDensity,
                    MLCardFormBinService.HeadersKeys.acceptLanguage.getKey: headers.acceptLanguage,
                    MLCardFormBinService.HeadersKeys.xProductId.getKey: headers.xProductId]
        case .postCardTokenData(_, let headers, _),
             .postCardData(_, let headers, _):
            return [MLCardFormAddCardService.HeadersKeys.contentType.getKey: headers.contentType]
        case .getWebPayInitInscription(_, let headers):
            return [MLCardFormWebPayService.HeadersKeys.contentType.getKey: headers.contentType,
                    MLCardFormWebPayService.HeadersKeys.xpublic.getKey: headers.xpublic]
        case .postWebPayFinishInscription(_, let headers, _):
            return [MLCardFormWebPayService.HeadersKeys.contentType.getKey: headers.contentType,
                    MLCardFormWebPayService.HeadersKeys.xpublic.getKey: headers.xpublic]
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
        case .getCardData(let queryParams, _):
            var urlQueryItems = [
                URLQueryItem(name: MLCardFormBinService.QueryKeys.bin.getKey, value: queryParams.bin),
                URLQueryItem(name: MLCardFormBinService.QueryKeys.siteId.getKey, value: queryParams.siteId),
                URLQueryItem(name: MLCardFormBinService.QueryKeys.platform.getKey, value: queryParams.platform),
                URLQueryItem(name: MLCardFormBinService.QueryKeys.odr.getKey, value: String(queryParams.odr))
            ]
            if let excludedPaymentTypes = queryParams.excludedPaymentTypes {
                urlQueryItems.append(URLQueryItem(name: MLCardFormBinService.QueryKeys.excludedPaymentTypes.getKey, value: excludedPaymentTypes))
            }
            return urlQueryItems
        case.postCardTokenData(let queryParams, _, _):
            var urlQueryItems:[URLQueryItem] = []
            if let accessToken = queryParams.accessToken {
                urlQueryItems.append(URLQueryItem(name: MLCardFormAddCardService.QueryKeys.accessToken.getKey, value: accessToken))
            } else if let publicKey = queryParams.publicKey {
                urlQueryItems.append(URLQueryItem(name: MLCardFormAddCardService.QueryKeys.publicKey.getKey, value: publicKey))
            }
            return urlQueryItems
        case .postCardData(let queryParams, _, _):
            let urlQueryItems = [
                URLQueryItem(name: MLCardFormAddCardService.QueryKeys.accessToken.getKey, value: queryParams.accessToken),
            ]
            return urlQueryItems
        case .getWebPayInitInscription(let queryParams, _),
             .postWebPayFinishInscription(let queryParams, _, _):
            let urlQueryItems = [
                URLQueryItem(name: MLCardFormAddCardService.QueryKeys.accessToken.getKey, value: queryParams.accessToken),
            ]
            return urlQueryItems
        }
    }

    var method: String {
        switch self {
        case .getCardData,
             .getWebPayInitInscription:
            return "GET"
        case .postCardTokenData,
             .postCardData,
             .postWebPayFinishInscription:
            return "POST"
        }
    }

    var body: Data? {
        switch self {
        case .postCardTokenData(_, _, let body):
            return encode(body)
        case .postCardData(_, _, let body):
            return encode(body)
        case .postWebPayFinishInscription(_, _, let body):
            return encode(body)
        default:
            return nil
        }
    }
}

// MARK: Encoding
private extension MLCardFormApiRouter {
    func encode<T: Codable>(_ body: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = try? encoder.encode(body)
        return body
    }
}
