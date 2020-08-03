//
//  MLCardFormField+UIPickerViewDelegate.swift
//  MLCardForm
//
//  Created by Eric Ertl on 08/11/2019.
//

import Foundation

// MARK: Textfield delegate.
extension MLCardFormField: UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let pickerOptions = property.pickerOptions() {
            return pickerOptions.count
        }
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let pickerOptions = property.pickerOptions() {
            return pickerOptions[row].value
        }
        return ""
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedValue = ""
        if let pickerOptions = property.pickerOptions() {
            selectedValue = pickerOptions[row].value
            UIAccessibility.post(notification: .announcement, argument: pickerOptions[row].value)
        }
        input.text = selectedValue
        updateTextField(input)
    }
}
