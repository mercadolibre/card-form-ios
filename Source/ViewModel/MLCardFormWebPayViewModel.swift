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
    private var finishInscriptionData: MLCardFormWebPayFinishInscriptionData?
    
    func updateWithBuilder(_ builder: MLCardFormBuilder) {
        self.builder = builder
        serviceManager.webPayService.update(publicKey: builder.publicKey, privateKey: builder.privateKey)
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
    
    func finishInscription(token: String, completion: ((Result<MLCardFormWebPayFinishInscriptionData, Error>) -> ())? = nil) {
        guard let inscriptionData = getFinishInscriptionData(token: token) else {
            completion?(.failure(NSError(domain: "MLCardForm", code: 0, userInfo: nil) as Error))
            return
        }
        serviceManager.webPayService.finishInscription(inscriptionData: inscriptionData, completion: { [weak self] (result: Result<MLCardFormWebPayFinishInscriptionData, Error>) in
            switch result {
            case .success(let inscriptionData):
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success")
                self?.finishInscriptionData = inscriptionData
                completion?(.success(inscriptionData))
            case .failure(let error):
                let errorMessage = error.localizedDescription
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "bin_number", "save_card_token": errorMessage])
                completion?(.failure(error))
            }
        })
    }
    
    func addCard(completion: ((Result<String, Error>) -> ())? = nil) {
        //guard let tokenizationData = getTokenizationData(), let addCardData = getAddCardData() else {
        guard let tokenizationData = getTokenizationData() else {
            completion?(.failure(NSError(domain: "MLCardForm", code: 0, userInfo: nil) as Error))
            return
        }
        serviceManager.webPayService.addCardToken(tokenizationData: tokenizationData, completion: { [weak self] (result: Result<MLCardFormTokenizationCardData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let tokenCardData):
//                if let esc = tokenCardData.esc {
//                    MLCardFormConfiguratorManager.escProtocol.saveESC(config: MLCardFormConfiguratorManager.escConfig, firstSixDigits: tokenCardData.firstSixDigits, lastFourDigits: tokenCardData.lastFourDigits, esc: esc)
//                }
                completion?(.success(""))
            case .failure(let error):
                let errorMessage = error.localizedDescription
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "bin_number", "save_card_token": errorMessage])
                completion?(.failure(error))
            }
        })
    }
}

// MARK: Helpers
extension MLCardFormWebPayViewModel {
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
        guard let username = builder?.webPayUsername,
              let email = builder?.webPayEmail else {
            return nil
        }
        return MLCardFormWebPayService.InitInscriptionBody(username: username, email: email, responseUrl: "https://www.comercio.cl/return_inscription")
    }
    
    func getFinishInscriptionData(token: String) -> MLCardFormWebPayService.FinishInscriptionBody? {
        return MLCardFormWebPayService.FinishInscriptionBody(token: token)
    }
    
    func getTokenizationData() -> MLCardFormWebPayService.TokenizationBody? {
        guard let username = builder?.webPayUsername else {
            return nil
        }
        let expirationMonth = 12
        let expirationYear = 2030
        
        guard let tbkUser = finishInscriptionData?.tbkUser,
              let cardNumber = finishInscriptionData?.cardNumber,
              let bin = finishInscriptionData?.bin else {
            return nil
        }
        let truncCardNumber = cardNumber.replacingCharacters(in: ...cardNumber.startIndex, with: bin)
        
        let cardHolder = MLCardFormCardHolder(name: username, identification: nil)
        return MLCardFormWebPayService.TokenizationBody(cardNumberId: tbkUser, truncCardNumber: truncCardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, cardholder: cardHolder, device: MLCardFormDevice())
    }

//    func getAddCardData() -> MLCardFormAddCardService.AddCardBody? {
//        guard let paymentMethod = binData?.paymentMethod, let issuer = binData?.issuers.first else { return nil }
//        let addCardPaymentMethod = MLCardFormAddCardPaymentMethod(id: paymentMethod.paymentMethodId, paymentTypeId: paymentMethod.paymentTypeId, name: paymentMethod.name)
//        let addCardIssuer = MLCardFormAddCardIssuer(id: issuer.id)
//        return MLCardFormAddCardService.AddCardBody(paymentMethod: addCardPaymentMethod, issuer: addCardIssuer)
//    }
}
