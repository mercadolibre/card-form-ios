//
//  MLCardFormFieldNotifier.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//

import Foundation

protocol MLCardFormFieldNotifierProtocol: NSObjectProtocol {
    func shouldNext(from: MLCardFormField)
    func shouldBack(from: MLCardFormField)
    func didChangeValue(newValue: String?, from: MLCardFormField)
    func didBeginEditing(from: MLCardFormField)
    func didTapClear(from: MLCardFormField)
    func invalidInput(from: MLCardFormField)
}

extension MLCardFormFieldNotifierProtocol {
    func didBeginEditing(from: MLCardFormField) {
        //this is a empty implementation to allow this method to be optional
    }
}
