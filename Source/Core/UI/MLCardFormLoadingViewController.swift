//
//  MLCardFormLoadingViewController.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 12/20/19.
//

import UIKit
import MLUI

final class MLCardFormLoadingViewController: UIViewController {
    private var spinnerView: MLSpinner?
    private var isShowing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .clear
        setupOverlay()
        setupSpinner()
    }

    private func setupSpinner() {
        spinnerView = MLSpinner()
        if let spinner = spinnerView {
            spinner.removeFromSuperview()
            view.addSubview(spinner)
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        }
        let color = MLStyleSheetManager.styleSheet.primaryColor
        let spinnerConfig = MLSpinnerConfig(size: .big, primaryColor: color, secondaryColor: color)
        spinnerView?.setUpWith(spinnerConfig)
        spinnerView?.show()
    }

    private func setupOverlay() {
        let overlay = UIView(frame: view.frame)
        overlay.backgroundColor = #colorLiteral(red: 0.1555326879, green: 0.1569747925, blue: 0.1605674028, alpha: 0.75)
        view.addSubview(overlay)
    }
}

// MARK: Publics
extension MLCardFormLoadingViewController {
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
