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
    internal var flowId: String?
    internal var acceptThirdPartyCard: Bool?
    internal var activateCard: Bool?
    internal var productId: String?
    internal var platform: String?

    weak var delegate: MLCardFormInternetConnectionProtocol?
    
    func update(publicKey: String?,
                privateKey: String?,
                flowId: String?,
                acceptThirdPartyCard: Bool?,
                activateCard: Bool?,
                productId: String? = nil,
                platform: String? = nil) {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.flowId = flowId
        self.acceptThirdPartyCard = acceptThirdPartyCard
        self.activateCard = activateCard
        self.productId = productId
        self.platform =  platform
    }
    
    func getFlowId() -> String {
        return flowId ?? "MLCardForm"
    }
    
    func getProductId() -> String? {
        return productId
    }
    
    func getPlatform() -> String? {
        return platform
    }
}

// MARK: QueryParams
extension MLCardFormAddCardServiceBase {
    enum QueryKeys {
        case publicKey
        case accessToken
        case acceptThirdPartyCard
        case activateCard
        
        var getKey: String {
            switch self {
            case .publicKey: return "public_key"
            case .accessToken: return "access_token"
            case .acceptThirdPartyCard: return "acceptThirdPartyCard"
            case .activateCard: return "activateCard"
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
