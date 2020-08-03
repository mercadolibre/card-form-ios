//
//  MLCardFormFieldNotifier.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//

import Foundation

public protocol MLCardFormFieldNotifierProtocol: NSObjectProtocol {
    func shouldNext(from: MLCardFormField)
    func shouldBack(from: MLCardFormField)
    func didChangeValue(newValue: String?, from: MLCardFormField)
    func didBeginEditing(from: MLCardFormField)
    func didTapClear(from: MLCardFormField)
    func invalidInput(from: MLCardFormField)
}

extension MLCardFormFieldNotifierProtocol {
    public func shouldNext(from: MLCardFormField) {
        //this is a empty implementation to allow this method to be optional
    }

    public func shouldBack(from: MLCardFormField) {
        //this is a empty implementation to allow this method to be optional
    }

    public func didBeginEditing(from: MLCardFormField) {
        //this is a empty implementation to allow this method to be optional
    }
    
    public func didTapClear(from: MLCardFormField) {
        //this is a empty implementation to allow this method to be optional
    }
    
    public func invalidInput(from: MLCardFormField) {
        //this is a empty implementation to allow this method to be optional
    }
}
