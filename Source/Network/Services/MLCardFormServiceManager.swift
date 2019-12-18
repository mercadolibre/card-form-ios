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
    private var reachability: Reachability?
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

// MARK: Reachability
private extension MLCardFormServiceManager {
    func reachabilityChanged(_ isReachable: Bool) {
        hasInternet = isReachable
    }

    func addReachabilityObserver() {
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to add reachability observer")
        }

        reachability?.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(true)
        }

        reachability?.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false)
        }

        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    func removeReachabilityObserver() {
        reachability?.stopNotifier()
        reachability = nil
    }
}

// MARK: MLCardFormInternetConnectionProtocol
extension MLCardFormServiceManager: MLCardFormInternetConnectionProtocol {
    func hasInternetConnection() -> Bool {
        return hasInternet
    }
}
