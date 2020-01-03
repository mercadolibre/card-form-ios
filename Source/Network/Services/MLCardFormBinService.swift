//
//  MLCardFormBinService
//  CardForm
//
//  Created by Esteban Boffa on 10/30/19.
//  Copyright © 2019 EBoffa. All rights reserved.
//

import Foundation

final class MLCardFormBinService {
    private enum AppIdentifier: String {
        case meli = "ML"
        case mp = "MP"
        case other = "OTHER"
    }
    private let meliName: String = "mercadolibre"
    private let mpName: String = "mercadopago"

    weak var delegate: MLCardFormInternetConnectionProtocol?
    
    private var siteId: String?
    private var flowId: String?
    private var excludedPaymentTypes: [String]?
    private let queue = OperationQueue()
    private var lastBin: String?
    private var lastResponse: MLCardFormBinData?
    
    func update(siteId: String?, excludedPaymentTypes: [String]?, flowId: String?) {
        self.siteId = siteId
        self.excludedPaymentTypes = excludedPaymentTypes
        self.flowId = flowId
    }
    
    private func getAppName() -> String {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else { return "" }
        return appName.lowercased()
    }
    
    private func getPlatform() -> String {
        let appName = getAppName()
        if appName.contains(meliName) {
            return AppIdentifier.meli.rawValue
        } else if appName.contains(mpName) {
            return AppIdentifier.mp.rawValue
        }
        return AppIdentifier.other.rawValue
    }
}

// MARK: Headers & Query Params
extension MLCardFormBinService {
    enum HeadersKeys {
        case userAgent
        case xDensity
        case acceptLanguage
        case xProductId

        var getKey: String {
            switch self {
            case .userAgent:
                return "user-agent"
            case .xDensity:
                return "x-density"
            case .acceptLanguage:
                return "accept-language"
            case .xProductId:
                return "x-product-id"
            }
        }
    }

    struct Headers {
        let userAgent: String
        let xDensity: String
        let acceptLanguage: String
        let xProductId: String
    }

    enum QueryKeys {
        case bin
        case siteId
        case platform
        case excludedPaymentTypes

        var getKey: String {
            switch self {
            case .bin:
                return "bin"
            case .siteId:
                return "site_id"
            case .platform:
                return "platform"
            case .excludedPaymentTypes:
                return "excluded_payment_types"
            }
        }
    }

    struct QueryParams {
        let bin: String
        let siteId: String
        let platform: String
        let excludedPaymentTypes: String?
    }
}

// MARK: Public methods.
extension MLCardFormBinService {
    func getCardData(binNumber: String, completion: ((Result<MLCardFormBinData, Error>) -> ())? = nil) {
        guard let siteId = siteId,
            let excludedPaymentTypes = excludedPaymentTypes?.joined(separator: ",") else { return }
        queue.cancelAllOperations()

        if let lastResponse = lastResponse, let lastBin = lastBin, lastBin == binNumber {
            debugLog("Bin data From memory cache")
            completion?(.success(lastResponse))
            return
        }

        if let internetConnection = delegate?.hasInternetConnection(), !internetConnection {
            completion?(.failure(NetworkLayerError.noInternetConnection))
            return
        }

        debugLog("Bin data New call: Operation -> \(binNumber)")
        let queryParams = MLCardFormBinService.QueryParams(bin: binNumber, siteId: siteId, platform: getPlatform(), excludedPaymentTypes: excludedPaymentTypes)
        let headers = MLCardFormBinService.Headers(userAgent: "PX/iOS/4.3.4", xDensity: "xxxhdpi", acceptLanguage: MLCardFormLocalizatorManager.shared.getLanguage(), xProductId: getFlowId())
        let operation = BlockOperation(block: {
            NetworkLayer.request(router: MLCardFormApiRouter.getCardData(queryParams, headers)) { [weak self] (result: Result<MLCardFormBinData, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let cardFormBinData):
                    MLCardFormConfiguratorManager.updateConfig(escEnabled: cardFormBinData.escEnabled)
                    self.lastBin = queryParams.bin
                    self.lastResponse = cardFormBinData
                case .failure(let error):
                    self.debugLog(error)
                }
                completion?(result)
            }
        })

        operation.name = queryParams.bin
        operation.completionBlock = { [weak self] in
            if let name = operation.name {
                self?.debugLog("Operation is completed -> \(name)")
            }
        }
        queue.addOperation(operation)
    }
}

// MARK: Privates
private extension MLCardFormBinService {
    func getFlowId() -> String {
        return flowId ?? "MLCardForm"
    }

    func debugLog(_ message: Any) {
        #if DEBUG
        if let messageStr = message as? String {
            print("MLCardFormBinService: \(messageStr)")
        } else {
            print(message)
        }
        #endif
    }
}
