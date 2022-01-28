//
//  MLCardFormWebPayViewController+Tracking.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/11/2020.
//

import Foundation

// MARK: Tracking
extension MLCardFormWebPayViewController {
    func trackBackEvent() {
        MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/back", properties: ["current_step": "web_view"])
    }
    
    func trackWebviewScreen(url: String) {
        MLCardFormTracker.sharedInstance.trackScreen(screenName: "/card_form/web_view", properties: ["url": url])
    }
}
