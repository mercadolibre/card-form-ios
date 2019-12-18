//
//  MLCardFormServiceManager.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 18/12/2019.
//

import Foundation

final class MLCardFormServiceManager: NSObject {
    let binService: MLCardFormBinService = MLCardFormBinService()
    let addCardService: MLCardFormAddCardService = MLCardFormAddCardService()
    private var hasInternet: Bool = true

    public override init() {
        super.init()
        addReachabilityObserver()
        binService.delegate = self
        addCardService.delegate = self
    }

    deinit {
        removeReachabilityObserver()
    }
}

// MARK: ReachabilityObserverProtocol
extension MLCardFormServiceManager: ReachabilityObserverProtocol {
    func reachabilityChanged(_ isReachable: Bool) {
        hasInternet = isReachable
    }
}

// MARK: MLCardFormInternetConnectionProtocol
extension MLCardFormServiceManager: MLCardFormInternetConnectionProtocol {
    func hasInternetConnection() -> Bool {
        return hasInternet
    }
}
