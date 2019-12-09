//
//  MLCardFormTrackingStore.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

internal final class MLCardFormTrackingStore {
    enum TrackingChoType: String {
        case one_tap
        case traditional
    }
    
    static let sharedInstance = MLCardFormTrackingStore()
    private var initDate: Date = Date()
    private var trackingChoType: TrackingChoType?
    
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

// MARK: Tracking cho type.
extension MLCardFormTrackingStore {
    func getChoType() -> String? {
        return trackingChoType?.rawValue
    }
    
    func setChoType(_ type: TrackingChoType) {
        trackingChoType = type
    }
    
    func cleanChoType() {
        trackingChoType = nil
    }
}
