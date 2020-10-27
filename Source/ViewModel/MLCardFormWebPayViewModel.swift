//
//  MLCardFormWebPayViewModel.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import Foundation

final class MLCardFormWebPayViewModel {
    private let serviceManager: MLCardFormServiceManager = MLCardFormServiceManager()
    
    //weak var viewModelDelegate: MLCardFormViewModelProtocol?

    private var builder: MLCardFormBuilder?
    
    func updateWithBuilder(_ builder: MLCardFormBuilder) {
        self.builder = builder
    }

    func getNavigationBarCustomColor() -> (backgroundColor: UIColor?, textColor: UIColor?) {
        return (builder?.navigationCustomBackgroundColor, builder?.navigationCustomTextColor)
    }
    
    func shouldConfigureNavigationBar() -> Bool {
        return builder?.shouldConfigureNavigation ?? true
    }

    func shouldAddStatusBarBackground() -> Bool {
        return builder?.addStatusBarBackground ?? true
    }

    func shouldAnimateOnLoad() -> Bool {
        return builder?.animateOnLoad ?? false
    }
}

// MARK: Services
extension MLCardFormWebPayViewModel {
    func initInscription(completion: ((Result<MLCardFormWebPayInscriptionData, Error>) -> ())? = nil) {
        guard let initInscriptionData = getInitInscriptionData() else {
            completion?(.failure(NSError(domain: "MLCardForm", code: 0, userInfo: nil) as Error))
            return
        }
        serviceManager.webPayService.initInscription(inscriptionData: initInscriptionData, completion: { (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            switch result {
            case .success(let initInscriptionData):
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success")
                completion?(.success(initInscriptionData))
            case .failure(let error):
                let errorMessage = error.localizedDescription
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "bin_number", "save_card_token": errorMessage])
                completion?(.failure(error))
            }
        })
    }
    
    func buildRequest(inscriptionData: MLCardFormWebPayInscriptionData) -> URLRequest? {
        var myRequest = URLRequest(url: URL(string: inscriptionData.urlWebpay)!)
        myRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        myRequest.httpMethod = "POST"
        let bodyData = "TBK_TOKEN=\(inscriptionData.token)"
        myRequest.httpBody = bodyData.data(using: .utf8)
        return myRequest
    }
}

// MARK: Privates.
private extension MLCardFormWebPayViewModel {
    func getInitInscriptionData() -> MLCardFormWebPayService.InitInscriptionBody? {
        return MLCardFormWebPayService.InitInscriptionBody(username: "chaca", email: "chaca@gmail.com", responseUrl: "https://www.comercio.cl/return_inscription")
    }
}
