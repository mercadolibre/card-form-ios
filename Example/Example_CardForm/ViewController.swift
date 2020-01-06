//
//  ViewController.swift
//  Example_CardForm
//
//  Created by Esteban Adrian Boffa on 22/10/2019.
//  Copyright © 2019 MercadoLibre. All rights reserved.
//

import UIKit
import MLCardForm
import MLUI

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    @IBAction func nuevaTarjetaTouchUpInside(_ sender: UIButton) {
        openCardForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "MLCardForm"
    }

    private func setupView() {
        view.backgroundColor = .white
        navigationItem.backBarButtonItem?.title = ""
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = MLStyleSheetManager.styleSheet.primaryColor
        navigationController?.navigationBar.tintColor = MLStyleSheetManager.styleSheet.blackColor
    }
}

extension ViewController: MLCardFormLifeCycleDelegate {
    func didAddCard(cardID: String) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    func didFailAddCard() {
        // Error adding card
    }
}

// Tracking
extension ViewController: MLCardFormTrackerDelegate {
    func trackScreen(screenName: String, extraParams: [String : Any]?) {
        // Track screen
    }
    
    func trackEvent(screenName: String?, extraParams: [String : Any]?) {
        // Track event
    }
}

// ESC
extension ViewController: MLCardFormESCProtocol {
    func saveESC(config: MLCardFormESCConfig, firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool {
        return false
    }
}

private extension ViewController {
    func openCardForm() {
        title = ""
        let publicKey = ""
        let builder = MLCardFormBuilder(publicKey: publicKey, siteId: "MLA", flowId: "MLCardForm-TestApp", lifeCycleDelegate: self)
        builder.setLanguage("pt")
        builder.setExcludedPaymentTypes(["ticket"])

        MLCardFormConfiguratorManager.with(esc: self, tracking: self)
        
        let cardFormVC = MLCardForm(builder: builder).setupController()
        navigationController?.pushViewController(cardFormVC, animated: true)
    }
}
