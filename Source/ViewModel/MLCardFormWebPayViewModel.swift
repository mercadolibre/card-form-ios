//
//  MLCardFormWebPayViewModel.swift
//  MLCardForm
//
//  Created by Eric Ertl on 27/10/2020.
//

import Foundation

final class MLCardFormWebPayViewModel {
    private let serviceManager: MLCardFormServiceManager = MLCardFormServiceManager()
    
    private var builder: MLCardFormBuilder?
    private var finishInscriptionData: MLCardFormWebPayFinishInscriptionData?
    
    func updateWithBuilder(_ builder: MLCardFormBuilder) {
        self.builder = builder
        serviceManager.webPayService.update(publicKey: builder.publicKey, privateKey: builder.privateKey)
        serviceManager.addCardService.update(publicKey: builder.publicKey, privateKey: builder.privateKey)
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
        serviceManager.webPayService.initInscription(completion: { (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            switch result {
            case .success(let initInscriptionData):
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success")
                completion?(.success(initInscriptionData))
            case .failure(let error):
                //let errorMessage = error.localizedDescription
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "bin_number", "save_card_token": errorMessage])
                completion?(.failure(error))
            }
        })
    }
    
    func finishInscription(token: String, completion: ((Result<Void, Error>) -> ())? = nil) {
        let inscriptionData = MLCardFormFinishInscriptionBody(token: token)
        serviceManager.webPayService.finishInscription(inscriptionData: inscriptionData, completion: { [weak self] (result: Result<MLCardFormWebPayFinishInscriptionData, Error>) in
            switch result {
            case .success(let inscriptionData):
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success")
                self?.finishInscriptionData = inscriptionData
                self?.addCard(completion: { (result: Result<String, Error>) in
                    switch result {
                    case .success(_):
                        completion?(.success(Void()))
                    case .failure(let error):
                        //let errorMessage = error.localizedDescription
                        //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "bin_number", "save_card_token": errorMessage])
                        completion?(.failure(error))
                    }
                })
            case .failure(let error):
                //let errorMessage = error.localizedDescription
                //MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "bin_number", "save_card_token": errorMessage])
                completion?(.failure(error))
            }
        })
    }
    
    func addCard(completion: ((Result<String, Error>) -> ())? = nil) {
        guard let tokenizationData = getTokenizationData(), let addCardData = getAddCardData() else {
            completion?(.failure(NSError(domain: "MLCardForm", code: 0, userInfo: nil) as Error))
            return
        }
        serviceManager.webPayService.addCardToken(tokenizationData: tokenizationData, completion: { [weak self] (result: Result<MLCardFormTokenizationCardData, Error>) in
            switch result {
            case .success(let tokenCardData):
                // tokenCardData will be used to save card
                self?.serviceManager.addCardService.saveCard(tokenId: tokenCardData.id, addCardData: addCardData, completion: { (result: Result<MLCardFormAddCardData, Error>) in
                    switch result {
                    case .success(let addCardData):
//                        MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success")
                        completion?(.success(addCardData.getId()))
                    case .failure(let error):
                        if case MLCardFormAddCardServiceError.missingPrivateKey = error {
                            completion?(.success(""))
                        } else {
//                            let errorMessage = error.localizedDescription
//                            MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "save_card_data", "error_message": errorMessage])
                            completion?(.failure(error))
                        }
                    }
                })
            case .failure(let error):
                //let errorMessage = error.localizedDescription
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
        let bodyData = "TBK_TOKEN=\(inscriptionData.tbkToken)"
        myRequest.httpBody = bodyData.data(using: .utf8)
        return myRequest
    }
    
    func getToken(request: URLRequest) -> String? {
        let REDIRECT_HOST = "www.comercio.cl"
        let REDIRECT_PATH = "/return_inscription"
        if let host = request.url?.host,
           let path = request.url?.path,
           let httpBody = request.httpBody,
           host == REDIRECT_HOST,
           path == REDIRECT_PATH {
            let stringBody = String(decoding: httpBody, as: UTF8.self)
            let bodyParams = stringBody.components(separatedBy: "&").map( { $0.components(separatedBy: "=") }).reduce(into: [String:String]()) { dict, pair in
                if pair.count == 2 {
                    dict[pair[0]] = pair[1]
                }
            }
            if let key = bodyParams.keys.first(where: { $0.uppercased().contains("TBK_TOKEN") }),
               let result = bodyParams[key] {
                NSLog("Obtained access token")
                return result
            }
        }
        return nil
    }
}

// MARK: Privates.
private extension MLCardFormWebPayViewModel {
    func getTokenizationData() -> MLCardFormWebPayTokenizationBody? {
        let username = "test user"
        let expirationMonth = 12
        let expirationYear = 2030
        
        guard let tbkUser = finishInscriptionData?.tbkUser,
              let cardNumber = finishInscriptionData?.cardNumber.replacingOccurrences(of: "X", with: ""),
              let bin = finishInscriptionData?.bin,
              let cardNumberLength = finishInscriptionData?.cardNumberLength else {
            return nil
        }
        let count = cardNumberLength - (bin.count + cardNumber.count)
        let stringPadding = String(repeating: "X", count: count)
        let truncCardNumber = "\(bin)\(stringPadding)\(cardNumber)"
        
        let tempIdentification = MLCardFormIdentification(type: "RUT", number: "76110613-9")

        let cardHolder = MLCardFormCardHolder(name: username, identification: tempIdentification)
        return MLCardFormWebPayTokenizationBody(cardNumberId: tbkUser, truncCardNumber: truncCardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, cardholder: cardHolder, device: MLCardFormDevice())
    }

    func getAddCardData() -> MLCardFormAddCardService.AddCardBody? {
        let addCardPaymentMethod = MLCardFormAddCardPaymentMethod(id: "redcompra", paymentTypeId: "debit_card", name: "")
        let addCardIssuer = MLCardFormAddCardIssuer(id: 1048)
        return MLCardFormAddCardService.AddCardBody(paymentMethod: addCardPaymentMethod, issuer: addCardIssuer)
    }
}
