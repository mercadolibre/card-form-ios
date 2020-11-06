//
//  MLCardFormLoadingViewControllerBase.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import UIKit

internal class MLCardFormLoadingViewControllerBase: UIViewController {
    private var isShowing: Bool = false
}

// MARK: Publics
extension MLCardFormLoadingViewControllerBase {
    func showFrom(_ vc: UIViewController) {
        if !isShowing {
            modalPresentationStyle = .overCurrentContext
            modalTransitionStyle = .crossDissolve
            isShowing = true
            vc.present(self, animated: true, completion: nil)
        }
    }

    func hide(completion: (() -> Void)? = nil) {
        isShowing = false
        dismiss(animated: true, completion: completion)
    }
}
