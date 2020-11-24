//
//  MLCardFormWebPayViewController.swift
//  MLCardForm
//
//  Created by Eric Ertl on 21/10/2020.
//

import Foundation
import WebKit

open class MLCardFormWebPayViewController: MLCardFormBaseViewController {
    // Loading
    private let loadingVC = MLCardFormWebPayLoadingViewController()
    // MARK: Constants
    internal let viewModel: MLCardFormWebPayViewModel = MLCardFormWebPayViewModel()
    // MARK: Private Vars
    private var urlWebpay: String?
    private weak var lifeCycleDelegate: MLCardFormLifeCycleDelegate?
    
    lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        //webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
        //trackScreen()
    }
    
    /// :nodoc
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initInscription()
    }
    
    open func dismissLoadingAndPop(completion: (() -> Void)? = nil) {
        hideProgress(completion: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            if let completion = completion { completion() }
        })
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

//// MARK: WKWebView methods.
///** :nodoc: */
//extension MLCardFormWebPayViewController: WKUIDelegate {
//}

// MARK: WKWebView methods.
/** :nodoc: */
extension MLCardFormWebPayViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        if let token = viewModel.getToken(request: navigationAction.request) {
            NSLog("Obtained access token")
            // Cancel navigation - this isn't a real URL
            decisionHandler(.cancel)
            finishInscription(token: token)
            return
        }
        // Default: allow navigation
        decisionHandler(.allow)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString,
           url == urlWebpay {
            hideProgress()
        }
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
}

// MARK:  Privates.
private extension MLCardFormWebPayViewController {
    func initInscription() {
        showProgress(direction: .ml_wp)
        urlWebpay = nil
        viewModel.initInscription { [weak self] (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let inscriptionData):
                // open webview
                if let request = self.viewModel.buildRequest(inscriptionData: inscriptionData) {
                    self.urlWebpay = inscriptionData.urlWebpay
                    DispatchQueue.main.async { [weak self] in
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
    
    func finishInscription(token: String) {
        showProgress(direction: .wp_ml)
        viewModel.finishInscription(token: token, completion: { [weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(_):
                // Notify listener
                self.lifeCycleDelegate?.didAddCard(cardID: "")
            case .failure(let error):
                // Notify listener
                self.lifeCycleDelegate?.didFailAddCard()
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
        })
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
        //viewModel.viewModelDelegate = self
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(webView)
            
        NSLayoutConstraint.activate([webView.topAnchor.constraint(equalTo: view.topAnchor),
                                     webView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     webView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
}

// MARK: Progress methods.
private extension MLCardFormWebPayViewController {
    func showProgress(direction: MLCardFormWebPayLoadingViewDirection) {
        loadingVC.setDirection(direction: direction)
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
                finishInscription(token: "")
            }
        case .cancel:
            dismissLoadingAndPop()
        }
    }
}
