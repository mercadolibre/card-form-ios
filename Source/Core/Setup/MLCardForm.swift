//
//  MLCardForm.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

/**
 Main class of this project.
 It takes a `MLCardFormBuilder` object.
 */
@objcMembers
open class MLCardForm: NSObject {
    internal var builder: MLCardFormBuilder
    
    // MARK: Initialization
    
    /**
     Mandatory init. Based on `MLCardFormBuilder`
     - parameter builder: MLCardFormBuilder object.
     */
    public init(builder: MLCardFormBuilder) {
        self.builder = builder
        MLCardFormTracker.sharedInstance.startNewSession()
        MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/init")
    }
}
// MARK: Publics
extension MLCardForm {
    /**
     Setup MLCardForm settings and return main ViewController. Push this ViewController in your navigation stack.
     */
    public func setupController() -> MLCardFormViewController {
        return MLCardFormViewController.setupWithBuilder(builder)
    }
}
