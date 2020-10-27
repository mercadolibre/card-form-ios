//
//  MLCardFormLoadingViewController.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 12/20/19.
//

import UIKit
import MLUI

final class MLCardFormLoadingViewController: MLCardFormLoadingViewControllerBase {
    private var spinnerView: MLSpinner?

    override func setupUI() {
        super.setupUI()
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
}
