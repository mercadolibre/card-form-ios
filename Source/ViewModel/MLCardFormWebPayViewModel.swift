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
    private var initInscriptionData: MLCardFormWebPayInscriptionData?
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
        serviceManager.webPayService.initInscription(completion: { [weak self] (result: Result<MLCardFormWebPayInscriptionData, Error>) in
            switch result {
            case .success(let initInscriptionData):
                self?.initInscriptionData = initInscriptionData
                completion?(.success(initInscriptionData))
            case .failure(let error):
                self?.trackError(step: "init_inscription", message: error.localizedDescription)
                completion?(.failure(error))
            }
        })
    }
    
    func finishInscription(token: String, completion: ((Result<Void, Error>) -> ())? = nil) {
        let inscriptionData = MLCardFormFinishInscriptionBody(token: token)
        serviceManager.webPayService.finishInscription(inscriptionData: inscriptionData, completion: { [weak self] (result: Result<MLCardFormWebPayFinishInscriptionData, Error>) in
            switch result {
            case .success(let inscriptionData):
                self?.finishInscriptionData = inscriptionData
                self?.addCard(completion: { (result: Result<String, Error>) in
                    switch result {
                    case .success(_):
                        completion?(.success(Void()))
                    case .failure(let error):
                        completion?(.failure(error))
                    }
                })
            case .failure(let error):
                self?.trackError(step: "finish_inscription", message: error.localizedDescription)
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
                self?.serviceManager.addCardService.saveCard(tokenId: tokenCardData.id, addCardData: addCardData, completion: { [weak self] (result: Result<MLCardFormAddCardData, Error>) in
                    switch result {
                    case .success(let addCardData):
                        self?.trackSuccess()
                        completion?(.success(addCardData.getId()))
                    case .failure(let error):
                        if case MLCardFormAddCardServiceError.missingPrivateKey = error {
                            completion?(.success(""))
                        } else {
                            self?.trackError(step: "save_card_data", message: error.localizedDescription)
                            completion?(.failure(error))
                        }
                    }
                })
            case .failure(let error):
                self?.trackError(step: "save_card_token", message: error.localizedDescription)
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
        guard let urlString = initInscriptionData?.redirectUrl,
              let url = NSURL(string: urlString) else {
            return nil
        }
        
        let REDIRECT_HOST = url.host
        let REDIRECT_PATH = url.path
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
        let cardHolderName = "\(initInscriptionData?.user.firstName ?? "") \(initInscriptionData?.user.lastName ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        guard let identificationType = initInscriptionData?.user.identifier.type,
              let identificationNumber = initInscriptionData?.user.identifier.number,
              let expirationMonth = finishInscriptionData?.card.expirationMonth,
              let expirationYear = finishInscriptionData?.card.expirationYear,
              let cardNumberId = finishInscriptionData?.card.id,
              let cardNumber = finishInscriptionData?.card.number.replacingOccurrences(of: "X", with: ""),
              let bin = finishInscriptionData?.card.firstSixDigits,
              let cardNumberLength = finishInscriptionData?.card.length else {
            return nil
        }
        let count = cardNumberLength - (bin.count + cardNumber.count)
        let stringPadding = String(repeating: "X", count: count)
        let truncCardNumber = "\(bin)\(stringPadding)\(cardNumber)"
        
        let tempIdentification = MLCardFormIdentification(type: identificationType, number: identificationNumber)

        let cardHolder = MLCardFormCardHolder(name: cardHolderName, identification: tempIdentification)
        return MLCardFormWebPayTokenizationBody(cardNumberId: cardNumberId, truncCardNumber: truncCardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, cardholder: cardHolder, device: MLCardFormDevice())
    }

    func getAddCardData() -> MLCardFormAddCardService.AddCardBody? {
        guard let paymentMethodId = finishInscriptionData?.card.paymentMethod.id,
              let paymentTypeId = finishInscriptionData?.card.paymentMethod.paymentTypeId,
              let name = finishInscriptionData?.card.paymentMethod.name,
              let issuerId = finishInscriptionData?.card.issuer.id else {
            return nil
        }
        
        let addCardPaymentMethod = MLCardFormAddCardPaymentMethod(id: paymentMethodId, paymentTypeId: paymentTypeId, name: name)
        let addCardIssuer = MLCardFormAddCardIssuer(id: issuerId)
        return MLCardFormAddCardService.AddCardBody(paymentMethod: addCardPaymentMethod, issuer: addCardIssuer)
    }
}

// MARK: Privates.
private extension MLCardFormWebPayViewModel {
    func trackError(step: String, message: String) {
        MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": step, "error_message": message])
    }
    
    func trackSuccess() {
        let bin = finishInscriptionData?.card.firstSixDigits ?? ""
        let issuer = finishInscriptionData?.card.issuer.id ?? 0
        let paymentMethodId = finishInscriptionData?.card.paymentMethod.id ?? ""
        let paymentTypeId = finishInscriptionData?.card.paymentMethod.paymentTypeId ?? ""
        MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success",
                                                    properties: ["bin": bin,
                                                                 "issuer": issuer,
                                                                 "payment_method_id": paymentMethodId,
                                                                 "payment_type_id": paymentTypeId])
    }
}
