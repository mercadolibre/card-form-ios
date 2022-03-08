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
    case postCardTokenData(MLCardFormAddCardService.Headers, MLCardFormTokenizationBody)
    case postCardData(MLCardFormAddCardService.Headers, MLCardFormAddCardBody)
    case getWebPayInitInscription(MLCardFormWebPayService.Headers)
    case postWebPayFinishInscription(MLCardFormWebPayService.Headers, MLCardFormFinishInscriptionBody)
    case getCardDataFromMarketplace(MLCardFormCardInformationMarketplace,
                                    MLCardFormBinService.Headers)

    var scheme: String {
        switch self {
        case .getCardData, .postCardTokenData, .postCardData, .getWebPayInitInscription, .postWebPayFinishInscription, .getCardDataFromMarketplace:
            return "https"
        }
    }

    var host: String {
        switch self {
        case .getCardData, .postCardTokenData, .getWebPayInitInscription, .postWebPayFinishInscription, .postCardData, .getCardDataFromMarketplace:
            return "api.mercadopago.com"
        }
    }

    var path: String {
        switch self {
        case .getCardData: return "/alpha/px_mobile/v1/card"
        case .postCardTokenData: return "/v1/card_tokens"
        case .postCardData: return "/alpha/px_mobile/v1/card"
        case .getWebPayInitInscription: return "/alpha/px_mobile/v1/card_webpay/inscription/init"
        case .postWebPayFinishInscription: return "/alpha/px_mobile/v1/card_webpay/inscription/finish"
        case .getCardDataFromMarketplace: return "/alpha/px_mobile/v1/card/marketplace"
        }
    }

    var headers: [String : String]? {
        switch self {
        case .getCardData(_ , let headers):
            return [MLCardFormBinService.HeadersKeys.userAgent.getKey: headers.userAgent,
                    MLCardFormBinService.HeadersKeys.xDensity.getKey: headers.xDensity,
                    MLCardFormBinService.HeadersKeys.acceptLanguage.getKey: headers.acceptLanguage,
                    MLCardFormBinService.HeadersKeys.xFlowId.getKey: headers.xFlowId,
                    MLCardFormBinService.HeadersKeys.sessionId.getKey: headers.sessionId,
                    MLCardFormBinService.HeadersKeys.accessToken.getKey: headers.accessToken]
        case .getCardDataFromMarketplace(_, let headers):
            return [MLCardFormBinService.HeadersKeys.userAgent.getKey: headers.userAgent,
                    MLCardFormBinService.HeadersKeys.xDensity.getKey: headers.xDensity,
                    MLCardFormBinService.HeadersKeys.acceptLanguage.getKey: headers.acceptLanguage,
                    MLCardFormBinService.HeadersKeys.xProductId.getKey: headers.xFlowId,
                    MLCardFormBinService.HeadersKeys.contentType.getKey: headers.contentType ?? "",
                    MLCardFormBinService.HeadersKeys.sessionId.getKey: headers.sessionId,
                    MLCardFormBinService.HeadersKeys.accessToken.getKey: headers.accessToken]
        case .postCardTokenData(let headers, _),
             .postCardData(let headers, _):
            return [MLCardFormAddCardService.HeadersKeys.contentType.getKey: headers.contentType,
                    MLCardFormBinService.HeadersKeys.xFlowId.getKey: headers.xFlowId,
                    MLCardFormAddCardService.HeadersKeys.sessionId.getKey: headers.sessionId,
                    MLCardFormAddCardService.HeadersKeys.accessToken.getKey: headers.accessToken]
        case .getWebPayInitInscription(let headers):
            return [MLCardFormWebPayService.HeadersKeys.contentType.getKey: headers.contentType,
                    MLCardFormWebPayService.HeadersKeys.xpublic.getKey: headers.xpublic,
                    MLCardFormBinService.HeadersKeys.xFlowId.getKey: headers.xFlowId,
                    MLCardFormBinService.HeadersKeys.sessionId.getKey: headers.sessionId,
                    MLCardFormWebPayService.HeadersKeys.accessToken.getKey: headers.accessToken]
        case .postWebPayFinishInscription(let headers, _):
            return [MLCardFormWebPayService.HeadersKeys.contentType.getKey: headers.contentType,
                    MLCardFormWebPayService.HeadersKeys.xpublic.getKey: headers.xpublic,
                    MLCardFormBinService.HeadersKeys.xFlowId.getKey: headers.xFlowId,
                    MLCardFormBinService.HeadersKeys.sessionId.getKey: headers.sessionId,
                    MLCardFormWebPayService.HeadersKeys.accessToken.getKey: headers.accessToken]
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
                case.postCardTokenData,
                    .postCardData,
                    .getWebPayInitInscription,
                    .postWebPayFinishInscription,
                    .getCardDataFromMarketplace:
                return [];
            }
        }

    var method: String {
        switch self {
        case .getCardData,
             .getWebPayInitInscription:
            return "GET"
        case .postCardTokenData,
             .postCardData,
             .postWebPayFinishInscription,
             .getCardDataFromMarketplace:
            return "POST"
        }
    }

    var body: Data? {
        switch self {
        case .postCardTokenData( _, let body):
            return encode(body)
        case .postCardData( _, let body):
            return encode(body)
        case .postWebPayFinishInscription( _, let body):
            return encode(body)
        case .getCardDataFromMarketplace(let body, _):
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
