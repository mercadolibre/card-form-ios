//
//  MLCardFormField+TextFieldDelegate.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//

import Foundation

// MARK: Textfield delegate.
extension MLCardFormField: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let customMask = customMask {
            textField.text = customMask.formatStringWithRange(range: range, string: string)
            setBottomLineColorAndShowHelp()
            updateTextField(textField)
            return false
        }
        // If field has no mask and string is lowercase, make letters uppercase
        if let textFieldText = textField.text as NSString?, string.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil {
            textField.text = textFieldText.replacingCharacters(in: range, with: string.uppercased())
            setBottomLineColorAndShowHelp()
            return false
        }
        setBottomLineColorAndShowHelp()
        return true
    }

    func updateTextField(_ textField: UITextField) {
        guard let inputCharsCount = textField.text?.count else { return }
        var sendValue: String? = textField.text
        if let customMask = customMask {
            sendValue = customMask.cleanText
        }
        notifierProtocol?.didChangeValue(newValue: sendValue, from: self)
        if property.shouldShowTick() {
            input.rightViewMode = .never
        }
        if inputCharsCount >= maxLenght {
            if isValid() {
                if property.shouldShowTick() {
                    input.rightViewMode = .always
                }
                if property.shouldChangeFocusOnMaxLength() {
                    bottomLine.backgroundColor = bottomLineDefaultColor
                    notifierProtocol?.shouldNext(from: self)
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        notifierProtocol?.didBeginEditing(from: self)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if !String.isNullOrEmpty(input.text) {
            notifierProtocol?.didTapClear(from: self)
        }
        if let customMask = customMask {
            _ = customMask.formatString(string: "")
        }
        return true
    }
}

extension MLCardFormField {
    func setBottomLineColorAndShowHelp(_ backgroundColor: UIColor? = nil) {
        bottomLine.backgroundColor = backgroundColor ?? highlightColor
        showHelpLabel()
    }
}
