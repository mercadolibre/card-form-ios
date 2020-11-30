//
//  MLCardFormBinService
//  CardForm
//
//  Created by Esteban Boffa on 10/30/19.
//  Copyright © 2019 EBoffa. All rights reserved.
//

import Foundation

enum MLCardFormBinServiceError: Error {
    case missingPrivateKey
    case missingParameters
}

final class MLCardFormBinService {
    private enum AppIdentifier: String {
        case meli = "ML"
        case mp = "MP"
        case other = "OTHER"
    }
    private let meliName: String = "mercadolibre"
    private let mpName: String = "mercadopago"

    weak var delegate: MLCardFormInternetConnectionProtocol?
    
    private var flowId: String?
    private var extraData: [AnyHashable: Any]?
    private let queue = OperationQueue()
    private var lastBin: String?
    private var lastResponse: MLCardFormBinData?
    private var privateKey: String?
    
    func update(privateKey: String?, flowId: String?, extraData: [AnyHashable: Any]?) {
        self.privateKey = privateKey
        self.extraData = extraData
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
    
    enum QueryKeys {
        case accessToken

        var getKey: String {
            switch self {
            case .accessToken:
                return "access_token"
            }
        }
    }

    struct KeyParam {
        let accessToken: String?
    }
}

// MARK: Public methods.
extension MLCardFormBinService {
    func getCardBinData(binNumber: String, completion: ((Result<MLCardFormBinData, Error>) -> ())? = nil) {
        queue.cancelAllOperations()
        
        guard let privateKey = privateKey else {
            completion?(.failure(MLCardFormBinServiceError.missingPrivateKey))
            return
        }
        
        guard let _ = extraData else {
            debugLog("Missing parameters for requesting bin")
            completion?(.failure(MLCardFormBinServiceError.missingParameters))
            return
        }

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
        
        let queryParams = MLCardFormBinService.KeyParam(accessToken: privateKey)
        let headers = MLCardFormBinService.Headers(contentType: "application/json")
        let operation = BlockOperation(block: {
            NetworkLayer.request(router: MLCardFormApiRouter.postCardBinData(queryParams, headers, self.buildBinRequestBody())) { [weak self] (result: Result<MLCardFormBinData, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let cardFormBinData):
                    MLCardFormConfiguratorManager.updateConfig(escEnabled: cardFormBinData.escEnabled)
                    self.lastBin = cardFormBinData.bin
                    self.lastResponse = cardFormBinData
                case .failure(let error):
                    self.debugLog(error)
                }
                completion?(result)
            }
        })

        operation.name = binNumber
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
    
    func buildBinRequestBody() -> MLCardFormAddCardBinBody {
        return MLCardFormAddCardBinBody(flowId: getFlowId(), extraDataDict: extraData!)
    }
}
