//
//  UIViewController+StatusBar.swift
//  Pods
//
//  Created by Juan sebastian Sanzone on 12/13/19.
//

import UIKit

internal extension UIViewController {
    func getStatusBarHeight() -> CGFloat {
        var topDeltaMargin: CGFloat = 20
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topSafeAreaInset = window?.safeAreaInsets.top
            if let topDeltaInset = topSafeAreaInset, topDeltaInset > 0 {
                topDeltaMargin = topDeltaInset
            }
        }
        return topDeltaMargin
    }

    func addStatusBarBackground(color: UIColor?) {
        let statusView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: getStatusBarHeight()))
        statusView.translatesAutoresizingMaskIntoConstraints = true
        statusView.backgroundColor = color
        view.addSubview(statusView)
    }
}


