//
//  ReachabilityObserverDelegate.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 11/12/2019.
//

import Foundation
import Reachability

private var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func reachabilityChanged(_ isReachable: Bool)
}

protocol ReachabilityObserverDelegate: class, ReachabilityActionDelegate {
    func addReachabilityObserver()
    func removeReachabilityObserver()
}

// Declaring default implementation of adding/removing observer
extension ReachabilityObserverDelegate {

    /** Subscribe on reachability changing */
    func addReachabilityObserver() {

        do {
            reachability = try Reachability()
        } catch {
            print("Unable to add reachability observer")
        }

        reachability.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(true)
        }

        reachability.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    /** Unsubscribe */
    func removeReachabilityObserver() {
        reachability.stopNotifier()
        reachability = nil
    }
}
