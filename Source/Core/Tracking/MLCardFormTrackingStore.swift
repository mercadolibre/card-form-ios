//
//  MLCardFormTrackingStore.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

final class MLCardFormTrackingStore {
    internal static let sharedInstance = MLCardFormTrackingStore()
    private var initDate: Date = Date()
    internal var flowId: String?
    internal var siteId: String?
}

// MARK: Screen time support methods.
extension MLCardFormTrackingStore {
    func initializeInitDate() {
        initDate = Date()
    }
    
    func getSecondsAfterInit() -> Int {
        guard let seconds = Calendar.current.dateComponents([Calendar.Component.second], from: initDate, to: Date()).second else { return 0 }
        return seconds
    }
}

extension MLCardFormTrackingStore {
    func clean() {
        flowId = nil
        siteId = nil
    }
}
