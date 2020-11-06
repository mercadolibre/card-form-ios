//
//  MLCardFormWebPayLoadingViewController.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import UIKit

final class MLCardFormWebPayLoadingViewController: MLCardFormLoadingViewControllerBase {
    private var viewType: MLCardFormWebPayLoadingViewType = .loading
    private var viewDirection: MLCardFormWebPayLoadingViewDirection = .ml_wp
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.subviews.forEach { $0.removeFromSuperview() }
        setupTitleLabel()
        setupDescriptionLabel()
    }
    
    private func setupTitleLabel() {
        setupLabel(label: titleLabel)
        titleLabel.text = getTitleText()
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: UI.FontSize.L_FONT)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupDescriptionLabel() {
        setupLabel(label: descriptionLabel)
        descriptionLabel.text = getDescriptionText()
        descriptionLabel.font = UIFont.ml_semiboldSystemFont(ofSize: UI.FontSize.S_FONT)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }
    
    private func setupLabel(label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UI.Colors.labelColor
    }
    
    private func getTitleText() -> String {
        switch viewType {
        case .loading:
            return (viewDirection == .ml_wp) ? "Te estamos llevando al sitio de Webpay".localized : "Estamos procesando la informacion".localized
        case .success:
            return (viewDirection == .ml_wp) ? "Te estamos llevando al sitio de Webpay".localized : "¡Agregaste una nueva tarjeta!".localized
        case .error:
            return (viewDirection == .ml_wp) ? "Ocurrió un error con Webpay".localized : "Ocurrió un error procesando la informacion".localized
        case .noNetworkError:
            return "Revisa tu conexión a internet.".localized
        }
    }
    
    private func getDescriptionText() -> String {
        switch viewType {
        case .loading:
            return (viewDirection == .ml_wp) ? "En tu proxima compra podrás pagar usando la misma tarjeta sin tener que volver a cargarla.".localized : "Te estamos llevando de vuelta a Mercado Pago".localized
        case .success:
            return (viewDirection == .ml_wp) ? "En tu proxima compra podrás pagar usando la misma tarjeta sin tener que volver a cargarla.".localized : "Te estamos llevando de vuelta a Mercado Pago".localized
        case .error, .noNetworkError::
            return (viewDirection == .ml_wp) ? "Los sentimos. Por favor intenta nuevamente o elige otro medio de pago.".localized : "Los sentimos. Por favor intenta nuevamente o elige otro medio de pago.".localized
        }
    }
}

// MARK: Publics
extension MLCardFormWebPayLoadingViewController {
    enum MLCardFormWebPayLoadingViewType: Error {
        case loading
        case success
        case error
        case noNetworkError
    }
    
    enum MLCardFormWebPayLoadingViewDirection: Error {
        case ml_wp
        case wp_ml
    }
    
    func setType(type: MLCardFormWebPayLoadingViewType) {
        viewType = type
        setTitleText()
        setDescriptionText()
    }
    
    func setTitleText(_ text: String? = nil) {
        guard let text = text else {
            titleLabel.text = getTitleText()
            return
        }
        titleLabel.text = text
    }
    
    func setDescriptionText(_ text: String? = nil) {
        guard let text = text else {
            descriptionLabel.text = getDescriptionText()
            return
        }
        descriptionLabel.text = text
    }
}
