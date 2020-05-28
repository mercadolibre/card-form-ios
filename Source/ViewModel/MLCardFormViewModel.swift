//
//  MLCardFormViewModel.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 31/10/2019.
//

import Foundation
import MLCardDrawer

final class MLCardFormViewModel {
    var cardUIHandler: CardUI = DefaultCardUIHandler()
    var cardDataHandler: CardData = DefaultCardDataHandler()
    var cardFormFields: [[MLCardFormField]]?
    lazy var tempTextField: MLCardFormField = {
        let textField = MLCardFormField(fieldProperty:CardNumberFormFieldProperty())
        textField.render()
        textField.alpha = 0
        return textField
    }()
    
    var storedCardName: String? {
        get {
            return MLCardFormStorageManager.get.field(key: MLCardFormFields.name.rawValue)
        }
        set(value) {
            MLCardFormStorageManager.save.field(key: MLCardFormFields.name.rawValue, text: value ?? "")
        }
    }
    var storedIDType: String? {
        get {
            return MLCardFormStorageManager.get.field(key: MLCardFormFields.identificationTypesPicker.rawValue)
        }
        set(value) {
            MLCardFormStorageManager.save.field(key: MLCardFormFields.identificationTypesPicker.rawValue, text: value ?? "")
        }
    }
    var storedIDNumber: String? {
        get {
            return MLCardFormStorageManager.get.field(key: MLCardFormFields.identificationTypeNumber.rawValue)
        }
        set(value) {
            MLCardFormStorageManager.save.field(key: MLCardFormFields.identificationTypeNumber.rawValue, text: value ?? "")
        }
    }
    var updateProgressWithCompletion: Bool = false
    var issuerWasSelected: Bool = false

    var measuredKeyboardSize: CGRect = CGRect.zero

    private let serviceManager: MLCardFormServiceManager = MLCardFormServiceManager()
    var lastFetchedBinNumber: String = ""
    private var binData: MLCardFormBinData?

    weak var viewModelDelegate: MLCardFormViewModelProtocol?

    private var builder: MLCardFormBuilder?
    
    func updateWithBuilder(_ builder: MLCardFormBuilder) {
        self.builder = builder
        serviceManager.addCardService.update(publicKey: builder.publicKey, privateKey: builder.privateKey)
        serviceManager.binService.update(siteId: builder.siteId, excludedPaymentTypes: builder.excludedPaymentTypes, flowId: builder.flowId)
    }
    
    func setupDefaultCardFormFields(notifierProtocol: MLCardFormFieldNotifierProtocol?) {
        cardFormFields = [
            [MLCardFormField(fieldProperty:CardNumberFormFieldProperty())],
            [MLCardFormField(fieldProperty:CardNameFormFieldProperty(cardNameValue: storedCardName))],
            [MLCardFormField(fieldProperty:CardExpirationFormFieldProperty()),
             MLCardFormField(fieldProperty:CardSecurityCodeFormFieldProperty())],
            [MLCardFormField(fieldProperty:IDTypeFormFieldProperty()),
             MLCardFormField(fieldProperty:IDNumberFormFieldProperty())],
        ]
        setupAndRenderCardFormFields(cardFormFields: cardFormFields, notifierProtocol: notifierProtocol)
    }

    func updateCardFormFields(_ remoteSettings: [MLCardFormFieldSetting]?, notifierProtocol: MLCardFormFieldNotifierProtocol?) {
        if remoteSettings == nil {
            updateOfflineCardFormFields(notifierProtocol: notifierProtocol)
            return
        }
        guard let cardUI = binData?.cardUI, let remoteSettings = remoteSettings else { return }
        cardFormFields = [[MLCardFormField]]()
        if let cardNumberFieldSettings = MLCardFormFieldSetting.createSettingForField(.cardNumber, cardUI: cardUI) {
            let numberField = MLCardFormField(fieldProperty: CardNumberFormFieldProperty(remoteSetting: cardNumberFieldSettings, cardNumberValue: tempTextField.getValue()))
            cardFormFields?.append([numberField])
        }

        if let nameFieldProp = remoteSettings.filter({ $0.name == MLCardFormFields.name.rawValue }).first {
            let nameField = MLCardFormField(fieldProperty: CardNameFormFieldProperty(remoteSetting: nameFieldProp, cardNameValue: storedCardName))
            cardFormFields?.append([nameField])
        }

        if let expirationFieldSetting = remoteSettings.filter({ $0.name == MLCardFormFields.expiration.rawValue}).first,
            let securityFieldSetting = remoteSettings.filter({ $0.name == MLCardFormFields.securityCode.rawValue}).first,
            let mergedSecurityFieldSetting = MLCardFormFieldSetting.createSettingForField(.securityCode, remoteSetting: securityFieldSetting, cardUI: cardUI) {
            cardFormFields?.append([
                MLCardFormField(fieldProperty: CardExpirationFormFieldProperty(remoteSetting: expirationFieldSetting)),
                MLCardFormField(fieldProperty: CardSecurityCodeFormFieldProperty(remoteSetting: mergedSecurityFieldSetting))
                ])
        }

        if let remoteIdTypes = binData?.identificationTypes, remoteIdTypes.count > 0,
            let idNumberSetting = remoteSettings.filter({ $0.name == MLCardFormFields.identificationTypeNumber.rawValue}).first {
            cardFormFields?.append([
                MLCardFormField(fieldProperty: IDTypeFormFieldProperty(identificationTypes: remoteIdTypes, idTypeValue: storedIDType, keyboardHeight: measuredKeyboardSize)),
                MLCardFormField(fieldProperty: IDNumberFormFieldProperty(identificationTypes: remoteIdTypes, idTypeValue: storedIDType, remoteSetting: idNumberSetting, idNumberValue: storedIDNumber))
                ])
        }
        setupAndRenderCardFormFields(cardFormFields: cardFormFields, notifierProtocol: notifierProtocol)
    }
    
    func updateOfflineCardFormFields(notifierProtocol: MLCardFormFieldNotifierProtocol?) {
        if let cardHandlerToUpdate = cardUIHandler as? DefaultCardUIHandler,
            let cardNumberField = getCardFormFieldWithID(MLCardFormFields.cardNumber) {
            
            let cardNumberValue = tempTextField.input.text ?? ""
            var cardNumberLength = cardNumberField.property.minLenght()
            let patternMask = cardNumberField.property.patternMask() ?? ""
            var cardPattern = patternMask.components(separatedBy: " ").map { $0.count }
            
            switch CardState(fromPrefix: cardNumberValue) {
            case .identified(let cardType):
                let cardPatternLength = cardType.segmentGroupings.reduce(0, +)
                cardNumberLength = cardPatternLength
                cardPattern = cardType.segmentGroupings
            default:
                cardNumberLength = cardHandlerToUpdate.cardPattern.reduce(0, +)
                cardPattern = cardHandlerToUpdate.cardPattern
            }
            
            let paymentMethod = MLCardFormPaymentMethod(paymentMethodId: "", paymentTypeId: "", name: "", processingModes: [])
            let cardUI = MLCardFormCardUI(cardNumberLength: cardNumberLength, cardPattern: cardPattern, cardColor: cardHandlerToUpdate.cardBackgroundColor.toHexString(), cardFontColor: cardHandlerToUpdate.cardFontColor.toHexString(), cardFontType: "", securityCodeLocation: "back", securityCodeLength: cardHandlerToUpdate.securityCodePattern, issuerImageUrl: nil, paymentMethodImageUrl: nil, issuerImage: nil, paymentMethodImage: nil, validation: nil, extraValidations: nil)
            
            cardHandlerToUpdate.update(cardUI: cardUI)
            viewModelDelegate?.shouldUpdateCard(cardUI: cardUIHandler, accessibilityData: nil)
            
            binData = MLCardFormBinData(escEnabled: false, enabled: true, errorMessage: nil, paymentMethod: paymentMethod, cardUI: cardUI, additionalSteps: [], issuers: [], fieldsSetting: [], identificationTypes: [])
            if let cardNumberFieldSettings = MLCardFormFieldSetting.createSettingForField(.cardNumber, cardUI: cardUI) {
                cardFormFields = [
                    [MLCardFormField(fieldProperty: CardNumberFormFieldProperty(remoteSetting: cardNumberFieldSettings, cardNumberValue: tempTextField.getValue()))],
                    [MLCardFormField(fieldProperty:CardNameFormFieldProperty(cardNameValue: storedCardName))],
                    [MLCardFormField(fieldProperty:CardExpirationFormFieldProperty()),
                     MLCardFormField(fieldProperty:CardSecurityCodeFormFieldProperty())],
                    [MLCardFormField(fieldProperty:IDTypeFormFieldProperty()),
                     MLCardFormField(fieldProperty:IDNumberFormFieldProperty())],
                ]
                setupAndRenderCardFormFields(cardFormFields: cardFormFields, notifierProtocol: notifierProtocol)
            }
        }
    }
    
    func setupAndRenderCardFormFields(cardFormFields: [[MLCardFormField]]?, notifierProtocol: MLCardFormFieldNotifierProtocol?) {
        cardFormFields?.forEach{ $0.forEach{
            $0.notifierProtocol = notifierProtocol
            $0.render()
        }}
    }
    
    func getProgressFromField(_ cardFormField: MLCardFormField) -> Float {
        if updateProgressWithCompletion {
            let cardFields = cardFormFields?.flatMap{$0}
            let steps: Float = Float(cardFields?.count ?? 0) + 1.0 // Add an extra step for initial progress
            var progress: Float = 0.0
            let stepTotalProgress: Float = 100.0 / steps
            progress += stepTotalProgress // Add initial progress
            cardFields?.forEach {
                let inputCharsCount = Float($0.getValue()?.count ?? 0)
                var maxLenght: Float = 0.0
                if let maskPattern = $0.property.patternMask() {
                    maxLenght = Float(maskPattern.count)
                    let stepProgress = inputCharsCount / maxLenght
                    progress += stepProgress * stepTotalProgress
                } else {
                    if inputCharsCount > maxLenght {
                        progress += stepTotalProgress
                    }
                }
            }
            return progress / 100
        } else {
            // Set progress by current step
            let steps: Float = Float(cardFormFields?.count ?? 0)
            var progress: Float = 0.0
            let stepTotalProgress: Float = 100.0 / steps
            if let indexOfField = cardFormFields?.firstIndex(where: { $0.contains(where: { $0.property.fieldId() == cardFormField.property.fieldId() }) }) {
                progress += Float(indexOfField + 1) * stepTotalProgress
            }
            
            return progress / 100
        }
    }
    
    func groupIndexOfCardFormField(_ cardFormField: MLCardFormField) -> Int? {
        let fieldId = cardFormField.property.fieldId()
        let index = cardFormFields?.firstIndex(where: {
            $0.first(where: {
                $0.property.fieldId() == fieldId
            }) != nil
        })
        
        return index
    }
    
    func focusCardFormFieldWithOffset(cardFormField: MLCardFormField, offset: Int) {
        let flattenedCardFormFields = cardFormFields?.flatMap{ $0 }
        guard let unwrappedCardFormFields = flattenedCardFormFields else { return }
        let fieldId = cardFormField.property.fieldId()
        let index = unwrappedCardFormFields.firstIndex(where: { $0.property.fieldId() == fieldId }) ?? 0
        let indexWithOffset = min(max(index + offset, 0), unwrappedCardFormFields.count - 1)
        
        if let field = flattenedCardFormFields?[indexWithOffset] {
            if field.property.shouldShowPickerInput() {
                focusCardFormFieldWithOffset(cardFormField: field, offset: offset)
            } else {
                //debugPrint("Setting focus on \(field.property.fieldId()) from \(cardFormField.property.fieldId())")
                field.doFocus()
            }
        }
    }
    
    func isCardNumberFieldAndIsMissingCardData(cardFormField: MLCardFormField) -> (isCardNumberMissingCardData: Bool, currentBin: String?) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()) else { return (false, nil) }
        if fieldId == MLCardFormFields.cardNumber,
            cardFormField.property.isValid(value: cardFormField.getValue()),
            let currentBin = cardFormField.getValue()?.replacingOccurrences(of: " ", with: "").prefix(6),
            currentBin != lastFetchedBinNumber {
            return (true, String(currentBin))
        }
        
        return (false, nil)
    }

    func isSecurityCodeFieldAndIsMissingExpiration(cardFormField: MLCardFormField) -> Bool {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()) else { return false }
        if fieldId == MLCardFormFields.securityCode,
            let cardFormField = getCardFormFieldWithID(MLCardFormFields.expiration),
            cardFormField.isValid() == false {
            return true
        }
        return false
    }
    
    func isLastField(cardFormField: MLCardFormField) -> Bool {
        var isLastField = false
        
        let cardFields = cardFormFields?.flatMap{$0}
        if let lastCardFormField = cardFields?.last, lastCardFormField.property.fieldId() == cardFormField.property.fieldId() {
            isLastField = true
        }
        return isLastField
    }
    
    func updateIDNumberFieldValue(value: String) {
        if let cardFormField = getCardFormFieldWithID(MLCardFormFields.identificationTypeNumber) {
            cardFormField.clearValue()
            cardFormField.property.setValue(value: value)
            cardFormField.updateInput()
        }
    }
    
    func saveDataForReuse() {
        if let cardFormField = getCardFormFieldWithID(MLCardFormFields.name),
            let value = cardFormField.getValue() {
            storedCardName = value
        }
        if let cardFormField = getCardFormFieldWithID(MLCardFormFields.identificationTypesPicker),
            let value = cardFormField.getValue() {
            storedIDType = value
        }
        if let cardFormField = getCardFormFieldWithID(MLCardFormFields.identificationTypeNumber),
            let value = cardFormField.getValue() {
            storedIDNumber = value
        }
    }
    
    func getCardFormFieldWithID(_ fieldId: MLCardFormFields) -> MLCardFormField? {
        return getCardFormFieldWithID(fieldId.rawValue)
    }
    
    func getCardFormFieldWithID(_ fieldId: String) -> MLCardFormField? {
        return cardFormFields?.flatMap{$0}.first(where: { $0.property.fieldId() == fieldId })
    }

    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.height <= 568
    }

    func updateCardIssuerImage(imageURL: String, name: String) {
        if let cardUI = binData?.cardUI,
            let cardHandlerToUpdate = cardUIHandler as? DefaultCardUIHandler {
            cardHandlerToUpdate.update(cardUI: cardUI.changeIssuerImageUrl(issuerImageUrl: imageURL))
            viewModelDelegate?.shouldUpdateCard(cardUI: cardUIHandler, accessibilityData: AccessibilityData(paymentMethodId: binData?.paymentMethod.paymentMethodId ?? "", issuer: name))
        }
    }

    func getNavigationBarCustomColor() -> (backgroundColor: UIColor?, textColor: UIColor?) {
        return (builder?.navigationCustomBackgroundColor, builder?.navigationCustomTextColor)
    }
    
    func shouldAddStatusBarBackground() -> Bool {
        return builder?.addStatusBarBackground ?? true
    }

    func shouldAnimateOnLoad() -> Bool {
        return builder?.animateOnLoad ?? false
    }
}

// MARK: IssuersScreen
extension MLCardFormViewModel {
    func getIssuers() -> [MLCardFormIssuer]? {
        return binData?.filteredIssuers
    }

    func shouldShowIssuersScreen() -> Bool {
        if issuerWasSelected {
            return false
        }
        guard let data = binData, data.additionalSteps.filter({ $0 == "issuers" }).count > 0 else { return false }
        return true
    }

    func setIssuer(issuer: MLCardFormIssuer) {
        issuerWasSelected = true
        if let data = binData {
            binData = data.changeIssuer(issuer: issuer)
        }
    }
    
    func getPaymentMethodTypeId() -> String? {
        return binData?.paymentMethod.paymentTypeId
    }
}

// MARK: Services
extension MLCardFormViewModel {
    func getCardData(binNumber: String, completion: ((Result<String, Error>) -> ())? = nil) {
        serviceManager.binService.getCardData(binNumber: binNumber, completion: { [weak self] (result: Result<MLCardFormBinData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let cardFormBinData):
                MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/bin_number/recognized")
                self.lastFetchedBinNumber = binNumber
                self.binData = cardFormBinData
                self.updateHandlers()
                completion?(.success(binNumber))
            case .failure(let error):
                var path = "/card_form/error"
                let errorMessage = error.localizedDescription
                var properties: [String: Any] = ["error_step": "bin_number", "error_message": errorMessage]
                switch error {
                case NetworkLayerError.statusCode(status: let status, message: _):
                    if status == 400 {
                        path = "/card_form/bin_number/unknown"
                        properties = ["bin_number": binNumber.prefix(6)]
                    }
                default:
                    break
                }
                MLCardFormTracker.sharedInstance.trackEvent(path: path, properties: properties)
                self.viewModelDelegate?.shouldUpdateFields(remoteSettings: nil)
                completion?(.failure(error))
            }
        })
    }

    func addCard(completion: ((Result<String, Error>) -> ())? = nil) {
        guard let tokenizationData = getTokenizationData(), let addCardData = getAddCardData() else {
            completion?(.failure(NSError(domain: "MLCardForm", code: 0, userInfo: nil) as Error))
            return
        }
        serviceManager.addCardService.addCardToken(tokenizationData: tokenizationData, addCardData: addCardData, completion: { [weak self] (result: Result<MLCardFormTokenizationCardData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let tokenCardData):
                if let esc = tokenCardData.esc {
                    MLCardFormConfiguratorManager.escProtocol.saveESC(config: MLCardFormConfiguratorManager.escConfig, firstSixDigits: tokenCardData.firstSixDigits, lastFourDigits: tokenCardData.lastFourDigits, esc: esc)
                }
                self.serviceManager.addCardService.saveCard(tokenId: tokenCardData.id, addCardData: addCardData, completion: { [weak self] (result: Result<MLCardFormAddCardData, Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let addCardData):
                        MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success")
                        self.saveDataForReuse()
                        completion?(.success(addCardData.getId()))
                    case .failure(let error):
                        if case MLCardFormAddCardServiceError.missingPrivateKey = error {
                            completion?(.success(""))
                        } else {
                            let errorMessage = error.localizedDescription
                            MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "save_card_data", "error_message": errorMessage])
                            completion?(.failure(error))
                        }
                    }
                })
            case .failure(let error):
                let errorMessage = error.localizedDescription
                MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/error", properties: ["error_step": "bin_number", "save_card_token": errorMessage])
                completion?(.failure(error))
            }
        })
    }
}

// MARK: Privates.
private extension MLCardFormViewModel {
    func updateHandlers() {
        if let cardHandlerToUpdate = cardUIHandler as? DefaultCardUIHandler  {
            cardHandlerToUpdate.update(cardUI: binData?.cardUI)
            let accessibilityData = AccessibilityData(paymentMethodId: binData?.paymentMethod.paymentMethodId ?? "", issuer: (binData?.issuers.count ?? 0) > 1 ? "" : binData?.issuers.first?.name ?? "")
            viewModelDelegate?.shouldUpdateCard(cardUI: cardUIHandler, accessibilityData: accessibilityData)
            viewModelDelegate?.shouldUpdateAppBarTitle(paymentTypeId: binData?.paymentMethod.paymentTypeId)
        }
        if let fieldSettings = binData?.fieldsSetting {
            viewModelDelegate?.shouldUpdateFields(remoteSettings: fieldSettings)
        }
    }

    func getTokenizationData() -> MLCardFormAddCardService.TokenizationBody? {
        let calendar = Calendar.current
        guard let identification = getIdentification(),
            let expirationDate = calendar.dateFromExpiration(cardDataHandler.expiration) else { return nil }
        let expirationMonth = calendar.component(.month, from: expirationDate)
        let expirationYear = calendar.component(.year, from: expirationDate)
        
        let cardHolder = MLCardFormCardHolder(name: cardDataHandler.name, identification: identification)
        return MLCardFormAddCardService.TokenizationBody(cardNumber: cardDataHandler.number, securityCode: cardDataHandler.securityCode, expirationMonth: expirationMonth, expirationYear: expirationYear, cardholder: cardHolder, device: MLCardFormDevice())
    }

    func getAddCardData() -> MLCardFormAddCardService.AddCardBody? {
        guard let paymentMethod = binData?.paymentMethod, let issuer = binData?.issuers.first else { return nil }
        let addCardPaymentMethod = MLCardFormAddCardPaymentMethod(id: paymentMethod.paymentMethodId, paymentTypeId: paymentMethod.paymentTypeId, name: paymentMethod.name)
        let addCardIssuer = MLCardFormAddCardIssuer(id: issuer.id)
        return MLCardFormAddCardService.AddCardBody(paymentMethod: addCardPaymentMethod, issuer: addCardIssuer)
    }

    func getIdentification() -> MLCardFormIdentification? {
        guard let idTypeCardFormField = getCardFormFieldWithID(MLCardFormFields.identificationTypesPicker),
            let type = idTypeCardFormField.getPickerValue(),
            let idNumberCardFormField = getCardFormFieldWithID(MLCardFormFields.identificationTypeNumber),
            let number = idNumberCardFormField.getUnmaskedValue() else {
            return MLCardFormIdentification(type: "", number: "")
        }
        return MLCardFormIdentification(type: type, number: number)
    }
}

