//
//  MLCardFormWebPayLoadingViewController.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import UIKit
import MLUI
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
    
    private let closeButton = UIButton()
    private let leftImageView = UIImageView()
    private let spinner = MLSpinner()
    private let centerImageView = UIImageView()
    private let rightImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let retryButton = AndesButton(text: "", hierarchy: .loud, size: .large)
    private let cancelButton = AndesButton(text: "", hierarchy: .quiet, size: .large)
    private let iconSize: CGFloat = 48
    private let buttonHeight: CGFloat = 48
    private let isMeli = MLCardFormIdentifier().isMeli()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.subviews.forEach { $0.removeFromSuperview() }
        setupCloseButton()
        setupTitleLabel()
        setupDescriptionLabel()
        setupSpinner()
        setupLoadingIcons()
        setupButtons()
    }
    
    private func setupCloseButton() {
        AndesIconsProvider.loadIcon(name: "andes_ui_close_16", success: { image in
            if let image = image.grayscale() {
                closeButton.setImage(image, for: .normal)
            }
        })
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.imageView?.contentMode = .center
        closeButton.contentVerticalAlignment = .fill
        closeButton.contentHorizontalAlignment = .fill
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: iconSize),
            closeButton.widthAnchor.constraint(equalToConstant: iconSize),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 39),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupSpinner() {
        let color = MLStyleSheetManager.styleSheet.secondaryColor
        let spinnerConfig = MLSpinnerConfig(size: .big, primaryColor: color, secondaryColor: color)
        spinner.setUpWith(spinnerConfig)
    }
    
    private func setupLoadingIcons() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.contentMode = .scaleAspectFit
        centerImageView.contentMode = .center
        rightImageView.contentMode = .scaleAspectFit
        containerView.addSubview(leftImageView)
        containerView.addSubview(centerImageView)
        containerView.addSubview(rightImageView)
        containerView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: iconSize),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            leftImageView.widthAnchor.constraint(equalToConstant: iconSize),
            leftImageView.heightAnchor.constraint(equalToConstant: iconSize),
            leftImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leftImageView.trailingAnchor.constraint(equalTo: centerImageView.leadingAnchor, constant: -22), //-16
            
            centerImageView.widthAnchor.constraint(equalToConstant: iconSize),
            centerImageView.heightAnchor.constraint(equalToConstant: iconSize),
            centerImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            rightImageView.widthAnchor.constraint(equalToConstant: iconSize),
            rightImageView.heightAnchor.constraint(equalToConstant: iconSize),
            rightImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rightImageView.leadingAnchor.constraint(equalTo: centerImageView.trailingAnchor, constant: 22) //16
        ])
        AndesIconsProvider.loadIcon(name: "andes_ui_arrow_right_16", placeItInto: centerImageView)
        let webpayImage = UIImage(named: "webpay", in: MLCardFormBundle.bundle(), compatibleWith: nil)
        rightImageView.image = webpayImage
        
        spinner.show()
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
        
        cancelButton.text = "Volver".localized
        view.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            retryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UI.Margin.L_MARGIN),
            retryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UI.Margin.L_MARGIN),
            retryButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            retryButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -8),
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
    
    private func updateUI() {
        updateImages()
        setTitleText()
        setDescriptionText()
        updateButtons()
    }

    private func updateButtons() {
        switch viewType {
        case .loading,
             .success:
            closeButton.isHidden = true
            retryButton.isHidden = true
            cancelButton.isHidden = true
        case .error,
             .noNetworkError:
            closeButton.isHidden = false
            retryButton.isHidden = false
            cancelButton.isHidden = false
        }
    }
    
    private func getTitleText() -> String {
        switch viewType {
        case .loading,
             .success:
            return (viewDirection == .ml_wp) ? "Te estamos llevando al sitio de Webpay".localized : "Te estamos llevando de vuelta a {0}".localized.replacingOccurrences(of: "{0}", with: (isMeli) ? "Mercado Libre".localized : "Mercado Pago".localized)
        case .error:
            return "Ocurrió un error".localized
        case .noNetworkError:
            return "Revisa tu conexión a internet.".localized
        }
    }
    
    private func getDescriptionText() -> String {
        switch viewType {
        case .loading,
             .success:
            return "En tu próxima compra podrás pagar usando la misma tarjeta sin tener que volver a cargarla.".localized
        case .error:
            return "Lo sentimos, no pudimos cargar tu tarjeta. \nPor favor intenta nuevamente.".localized
        case .noNetworkError:
            return ""
        }
    }
    
    private func updateImages() {
        let logoImage = UIImage(named: isMeli ? "logo_meli" : "logo_mp", in: MLCardFormBundle.bundle(), compatibleWith: nil)
        let webpayImage = UIImage(named: "webpay", in: MLCardFormBundle.bundle(), compatibleWith: nil)
        switch viewDirection {
        case .ml_wp:
            leftImageView.image = logoImage
            rightImageView.image = webpayImage
        case .wp_ml:
            leftImageView.image = webpayImage
            rightImageView.image = logoImage
        }

        switch viewType {
        case .loading:
            spinner.show()
            AndesIconsProvider.loadIcon(name: "andes_ui_arrow_right_16", placeItInto: centerImageView)
        case .success:
            spinner.hide()
            let image = UIImage(named: "success", in: MLCardFormBundle.bundle(), compatibleWith: nil)
            updateCenterImage(image: image)
        case .error,
             .noNetworkError:
            spinner.hide()
            let image = UIImage(named: "error", in: MLCardFormBundle.bundle(), compatibleWith: nil)
            updateCenterImage(image: image)
        }
    }
    
    private func updateCenterImage(image: UIImage?) {
        UIView.transition(with: centerImageView,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            guard let self = self else { return }
                            self.centerImageView.image = image
                          })
    }
}

// MARK: Publics
extension MLCardFormWebPayLoadingViewController {
    func setTypeAndDirection(type: MLCardFormWebPayLoadingViewType, direction: MLCardFormWebPayLoadingViewDirection) {
        viewType = type
        viewDirection = direction
        updateUI()
    }
    
    func setType(type: MLCardFormWebPayLoadingViewType) {
        viewType = type
        updateUI()
    }
    
    func setDirection(direction: MLCardFormWebPayLoadingViewDirection) {
        viewDirection = direction
        updateUI()
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
