//
//  MLCardFormField+Selectors.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//

import Foundation

extension MLCardFormField {
    @objc func doBack() {
        bottomLine.backgroundColor = bottomLineDefaultColor
        notifierProtocol?.shouldBack(from: self)
    }

    @objc func doNext() {
        if isValid() {
            bottomLine.backgroundColor = bottomLineDefaultColor
            notifierProtocol?.shouldNext(from: self)
        } else {
            notifierProtocol?.invalidInput(from: self)
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        updateTextField(textField)
    }
}
