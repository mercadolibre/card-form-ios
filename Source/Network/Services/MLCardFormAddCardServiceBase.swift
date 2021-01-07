//
//  MLCardFormAddCardServiceBase.swift
//  MLCardForm
//
//  Created by Eric Ertl on 28/10/2020.
//

import Foundation

enum MLCardFormAddCardServiceError: Error {
    case missingKeys
    case missingPrivateKey
}

internal class MLCardFormAddCardServiceBase {
    internal var publicKey: String?
    internal var privateKey: String?
    weak var delegate: MLCardFormInternetConnectionProtocol?
    
    func update(publicKey: String?, privateKey: String?) {
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
}

// MARK: QueryParams
extension MLCardFormAddCardServiceBase {
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

    struct AccessTokenParam {
        let accessToken: String
    }
}
