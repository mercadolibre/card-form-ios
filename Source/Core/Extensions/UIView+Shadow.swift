//
//  UIView+Shadow.swift
//
//  Created by Juan sebastian Sanzone on 11/26/19.
//

import UIKit

internal extension UIView {
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.4)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 5.0
        self.layer.masksToBounds = false
    }
}
