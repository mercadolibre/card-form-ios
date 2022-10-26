//
//  MLCardFormTrackerDelegate.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//  Refactor by bgarelli, 10/25/2022

/// Protocol to stay notified about our tracking screens/events.
public protocol MLCardFormTrackerDelegate {
    /**
     This method is called when a new screen is shown to the user and tracked by our Checkout.
     - parameter screenName: Screenname Melidata catalog.
     - parameter extraParams: Extra data.
     */
    func trackScreen(screenName: String, extraParams: [String: Any]?)
    
    /**
     This method is called when a new event is occurred to the user and tracked by our Checkout.
     - parameter screenName: Event name.
     - parameter extraParams: Extra data.
     */
    func trackEvent(screenName: String?, extraParams: [String: Any]?)

}
