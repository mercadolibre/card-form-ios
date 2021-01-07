//
//  MLCardFormWebPayViewController.swift
//  MLCardForm
//
//  Created by Eric Ertl on 21/10/2020.
//

import Foundation
import WebKit

public final class MLCardFormWebPayViewController: MLCardFormBaseViewController {
    // Loading
    private let loadingVC = MLCardFormWebPayLoadingViewController()
    // MARK: Constants
    internal let viewModel: MLCardFormWebPayViewModel = MLCardFormWebPayViewModel()
    // MARK: Private Vars
    private weak var lifeCycleDelegate: MLCardFormLifeCycleDelegate?
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    /// :nodoc
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initInscription()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            trackBackEvent()
        }
    }
    
    public func dismissLoadingAndPop(completion: (() -> Void)? = nil) {
        webView.removeFromSuperview()
        CATransaction.begin()
        navigationController?.popViewController(animated: true)
        CATransaction.setCompletionBlock({ [weak self] in
            self?.hideProgress(completion: {
                if let completion = completion { completion() }
            })
        
        })
        CATransaction.commit()
    }
}

// MARK: Public API.
internal extension MLCardFormWebPayViewController {
    static func setupWithBuilder(_ builder: MLCardFormBuilder) -> MLCardFormWebPayViewController {
        let controller = MLCardFormWebPayViewController()
        controller.lifeCycleDelegate = builder.lifeCycleDelegate
        controller.viewModel.updateWithBuilder(builder)
        return controller
    }
}

// MARK: WKWebView methods.
/** :nodoc: */
extension MLCardFormWebPayViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if viewModel.getToken(request: navigationAction.request) {
            // Cancel navigation - this isn't a real URL
            decisionHandler(.cancel)
            // Clear current webview contents, so they don't show up while dismissing
            clearWebview()
            finishInscription()
            return
        }
        // Default: allow navigation
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let urlString = viewModel.validateURLWebpay(url: webView.url) {
            trackWebviewScreen(url: urlString)
            hideProgress()
        }
    }
}

// MARK:  Privates.
private extension MLCardFormWebPayViewController {
    func initInscription() {
        showProgress(direction: .ml_wp)
        viewModel.initInscription { [weak self] (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let inscriptionData):
                // open webview
                if let request = self.viewModel.buildRequest(inscriptionData: inscriptionData) {
                    DispatchQueue.main.async { [weak self] in
                        self?.loadingVC.setType(type: .success)
                        self?.webView.load(request)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    // Show error to the user
                    var text: String?
                    switch error {
                    case NetworkLayerError.noInternetConnection:
                        text = "Revisa tu conexión a internet.".localized
                        UIAccessibility.post(notification: .announcement, argument: text)
                        self?.loadingVC.setType(type: .noNetworkError)
                    default:
                        text = "Algo salió mal.".localized
                        UIAccessibility.post(notification: .announcement, argument: text)
                        self?.loadingVC.setType(type: .error)
                    }
                }
            }
        }
    }
    
    func finishInscription() {
        showProgress(direction: .wp_ml)
        viewModel.finishInscription{ (result: Result<String, Error>) in
            switch result {
            case .success(let cardID):
                DispatchQueue.main.async { [weak self] in
                    self?.loadingVC.setType(type: .success)
                    // Notify listener
                    self?.lifeCycleDelegate?.didAddCard(cardID: cardID)
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    // Notify listener
                    self?.lifeCycleDelegate?.didFailAddCard()
                    // Show error to the user
                    var text: String?
                    switch error {
                    case NetworkLayerError.noInternetConnection:
                        text = "Revisa tu conexión a internet.".localized
                        UIAccessibility.post(notification: .announcement, argument: text)
                        self?.loadingVC.setType(type: .noNetworkError)
                    default:
                        text = "Algo salió mal.".localized
                        UIAccessibility.post(notification: .announcement, argument: text)
                        self?.loadingVC.setType(type: .error)
                    }
                }
            }
        }
    }
    
    func initialSetup() {
        if viewModel.shouldConfigureNavigationBar() {
            title = "Nueva tarjeta".localized
            let (backgroundNavigationColor, textNavigationColor) = viewModel.getNavigationBarCustomColor()
            super.loadStyles(customNavigationBackgroundColor: backgroundNavigationColor, customNavigationTextColor: textNavigationColor)
            if viewModel.shouldAddStatusBarBackground() {
                addStatusBarBackground(color: backgroundNavigationColor)
            }
        }
        loadingVC.delegate = self
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
            
        NSLayoutConstraint.activate([webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
                                     webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     webView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
    
    func clearWebview() {
        if let url = URL(string:"about:blank") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                self?.webView.load(URLRequest(url: url))
            })
        }
    }
}

// MARK: Progress methods.
private extension MLCardFormWebPayViewController {
    func showProgress(direction: MLCardFormWebPayLoadingViewDirection) {
        loadingVC.setTypeAndDirection(type: .loading, direction: direction)
        loadingVC.showFrom(self)
    }
    
    func hideProgress(completion: (() -> Void)? = nil) {
        loadingVC.hide(completion: completion)
    }
}

extension MLCardFormWebPayViewController: MLCardFormWebPayLoadingViewDelegate {
    func onWebPayLoadingViewButtonTapped(action: MLCardFormWebPayLoadingViewButtonAction, direction: MLCardFormWebPayLoadingViewDirection) {
        switch action {
        case .retry:
            switch direction {
            case .ml_wp:
                initInscription()
            case .wp_ml:
                finishInscription()
            }
        case .cancel:
            dismissLoadingAndPop()
        }
    }
}
