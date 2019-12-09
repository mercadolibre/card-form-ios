//
//  MLCardFormField+KeyboardToolbar.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//

import Foundation

extension MLCardFormField {
    func setKeyboardToolBar() {
        let backText = property.keyboardBackText()
        let backEnabled = property.keyboardBackEnabled()
        let nextText = property.keyboardNextText()
        
        let toolBar = UIToolbar()
        toolBar.tintColor = highlightColor
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 20.0
        toolBar.items = [UIBarButtonItem]()

        if let backBtnText = backText,
            let item = buildToolbarButton(title: backBtnText, action: #selector(doBack)) {
            toolBar.items?.append(fixedSpace)
            item.isEnabled = backEnabled
            toolBar.items?.append(item)
        }
        if let nextBtnText = nextText,
            let item = buildToolbarButton(title: nextBtnText, action: #selector(doNext)) {
            toolBar.items?.append(flexibleSpace)
            toolBar.items?.append(item)
            toolBar.items?.append(fixedSpace)
        }

        toolBar.sizeToFit()
        // toolBar.clipsToBounds = true // To remove top border of toolbar.
        input.inputAccessoryView = toolBar
    }
    
    func buildToolbarButton(title: String, action: Selector?) -> UIBarButtonItem? {
        guard let font = UIFont.ml_regularSystemFont(ofSize: 14) else { return nil }
        let barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: action)
        let normalAttributes = [NSAttributedString.Key.foregroundColor : highlightColor, NSAttributedString.Key.font : font]
        barButtonItem.setTitleTextAttributes(normalAttributes, for: .normal)
        barButtonItem.setTitleTextAttributes(normalAttributes, for: .highlighted)
        barButtonItem.setTitleTextAttributes(normalAttributes, for: .focused)
        barButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.gray, NSAttributedString.Key.font : font], for: .disabled)
        return barButtonItem
    }
}
