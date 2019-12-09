//
//  UITextField+MaxLenght.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//

import Foundation

// Max lenght support.
private var associationKeyMaxLength: Int = 0

internal extension UITextField {
    var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &associationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &associationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }

    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }

        let selection = selectedTextRange
        let indexEndOfText = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        let substring = prospectiveText[..<indexEndOfText]
        text = String(substring)

        selectedTextRange = selection
    }
}
