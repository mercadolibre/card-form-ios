//
//  MLCardFormApiRouter.swift
//  CardForm
//
//  Created by Juan sebastian Sanzone on 10/30/19.
//  Copyright © 2019 JS. All rights reserved.
//

import Foundation

enum MLCardFormApiRouter {

    case postCardBinData(MLCardFormBinService.KeyParam, MLCardFormBinService.Headers, MLCardFormAddCardBinBody)
    case postCardTokenData(MLCardFormAddCardService.KeyParam, MLCardFormAddCardService.Headers, MLCardFormTokenizationBody)
    case postCardData(MLCardFormAddCardService.AddCardParams, MLCardFormAddCardService.Headers, MLCardFormAddCardBody)
    
    var scheme: String {
        return "https"
    }

    var host: String {
        switch self {
        case .postCardTokenData, .postCardData, .postCardBinData:
            return "api.mercadopago.com"
        }
    }

    var path: String {
        switch self {
        case .postCardTokenData:
            return "/v1/card_tokens"
        case .postCardData,
             .postCardBinData:
            return "/production/px_mobile/v1/card"
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .postCardTokenData(_, let headers, _), .postCardData(_, let headers, _):
            return [MLCardFormAddCardService.HeadersKeys.contentType.getKey: headers.contentType]
        case .postCardBinData(_, let headers, _):
            return [MLCardFormBinService.HeadersKeys.contentType.getKey: headers.contentType]
        }
    }

    var parameters: [URLQueryItem] {
        switch self {
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
        case .postCardBinData(let queryParams, _, _):
            let urlQueryItems = [
                URLQueryItem(name: MLCardFormBinService.QueryKeys.accessToken.getKey, value: queryParams.accessToken),
            ]
            return urlQueryItems
        }
    }

    var method: String {
        switch self {
        case .postCardTokenData,
             .postCardBinData,
             .postCardData:
            return "POST"
        }
    }

    var body: Data? {
        switch self {
        case .postCardTokenData(_, _, let tokenizationBody):
            return encode(tokenizationBody)
        case .postCardData(_, _, let addCardBody):
            return encode(addCardBody)
        case .postCardBinData(_, _, let addCardBinBody):
            return encode(addCardBinBody)
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
