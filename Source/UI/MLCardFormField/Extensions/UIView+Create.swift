//
//  UIView+Create.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//  Copyright © 2019 Juan Sebastian Sanzone. All rights reserved.
//

import UIKit

internal extension UIView {
    static func createView(_ backgroundColor: UIColor? = nil) -> UIView {
        let targetView = UIView()
        targetView.backgroundColor = backgroundColor
        targetView.translatesAutoresizingMaskIntoConstraints = false
        return targetView
    }
}
