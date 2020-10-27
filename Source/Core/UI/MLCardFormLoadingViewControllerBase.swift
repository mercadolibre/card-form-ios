//
//  MLCardFormLoadingViewControllerBase.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import UIKit

internal class MLCardFormLoadingViewControllerBase: UIViewController {
    private var isShowing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    internal func setupUI() {
        view.backgroundColor = .clear
        setupOverlay()
    }

    private func setupOverlay() {
        let overlay = UIView(frame: view.frame)
        overlay.backgroundColor = #colorLiteral(red: 0.1555326879, green: 0.1569747925, blue: 0.1605674028, alpha: 0.75)
        view.addSubview(overlay)
    }
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
