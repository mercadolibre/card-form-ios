//
//  MLCardFormWebPayLoadingViewController.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import UIKit
import AndesUI

enum MLCardFormWebPayLoadingViewButtonAction {
    case retry
    case cancel
}

enum MLCardFormWebPayLoadingViewType {
    case loading
    case success
    case error
    case noNetworkError
}

enum MLCardFormWebPayLoadingViewDirection {
    case ml_wp
    case wp_ml
}

protocol MLCardFormWebPayLoadingViewDelegate: AnyObject {
    func onWebPayLoadingViewButtonTapped(action: MLCardFormWebPayLoadingViewButtonAction, direction: MLCardFormWebPayLoadingViewDirection)
}

final class MLCardFormWebPayLoadingViewController: MLCardFormLoadingViewControllerBase {
    weak var delegate: MLCardFormWebPayLoadingViewDelegate?
    
    private var viewType: MLCardFormWebPayLoadingViewType = .loading
    private var viewDirection: MLCardFormWebPayLoadingViewDirection = .ml_wp
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let retryButton = AndesButton(text: "", hierarchy: .loud, size: .large)
    private let cancelButton = AndesButton(text: "", hierarchy: .quiet, size: .large)
    private let buttonHeight: CGFloat = 48
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.subviews.forEach { $0.removeFromSuperview() }
        setupTitleLabel()
        setupDescriptionLabel()
        setupButtons()
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
    
    private func setupButtons() {
        retryButton.text = "Intentar nuevamente".localized
        view.addSubview(retryButton)
        retryButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        
        cancelButton.text = "Elegir otro medio".localized
        view.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UI.Margin.L_MARGIN),
            retryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UI.Margin.L_MARGIN),
            retryButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            retryButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -UI.Margin.M_MARGIN),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UI.Margin.L_MARGIN),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UI.Margin.L_MARGIN),
            cancelButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UI.Margin.L_MARGIN)
        ])
    }
    
    @objc func retryAction(sender: AndesButton!) {
        delegate?.onWebPayLoadingViewButtonTapped(action: .retry, direction: viewDirection)
    }
    
    @objc func cancelAction(sender: AndesButton!) {
        delegate?.onWebPayLoadingViewButtonTapped(action: .cancel, direction: viewDirection)
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
        case .error, .noNetworkError:
            return (viewDirection == .ml_wp) ? "Los sentimos. Por favor intenta nuevamente o elige otro medio de pago.".localized : "Los sentimos. Por favor intenta nuevamente o elige otro medio de pago.".localized
        }
    }
}

// MARK: Publics
extension MLCardFormWebPayLoadingViewController {
    func setType(type: MLCardFormWebPayLoadingViewType) {
        viewType = type
        updateTextLabels()
    }
    
    func setDirection(direction: MLCardFormWebPayLoadingViewDirection) {
        viewDirection = direction
        updateTextLabels()
    }
    
    private func updateTextLabels() {
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
