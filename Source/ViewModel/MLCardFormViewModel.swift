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
    
    private let minCardNumberLength = 16
    private let maxCardNumberLength = 20
    
    func updateWithBuilder(_ builder: MLCardFormBuilder) {
        self.builder = builder
        serviceManager.addCardService.update(publicKey: builder.publicKey, privateKey: builder.privateKey, flowId: builder.flowId, acceptThirdPartyCard: builder.acceptThirdPartyCard, activateCard: builder.activateCard)
        serviceManager.binService.update(siteId: builder.siteId, excludedPaymentTypes: builder.excludedPaymentTypes, flowId: builder.flowId, privateKey: builder.privateKey, cardInfoMarketplace: builder.cardInfoMarketplace)
    }
    
    func setupDefaultCardFormFields(notifierProtocol: MLCardFormFieldNotifierProtocol?) {
        cardFormFields = [
            [MLCardFormField(fieldProperty:CardNumberFormFieldProperty())],
            [MLCardFormField(fieldProperty:CardNameFormFieldProperty())],
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
            let numberField = MLCardFormField(
                fieldProperty: CardNumberFormFieldProperty(
                    remoteSetting: cardNumberFieldSettings,
                    cardNumberValue: tempTextField.getValue()
                )
            )
            cardFormFields?.append([numberField])
        }
        
        if let nameFieldProp = remoteSettings.get(.name) {
            let autocomplete = nameFieldProp.autocomplete ?? true
            let nameField = MLCardFormField(
                fieldProperty: CardNameFormFieldProperty(
                    remoteSetting: nameFieldProp,
                    cardNameValue: autocomplete ? storedCardName : nil
                )
            )
            cardFormFields?.append([nameField])
        }
        
        if let expirationFieldSetting = remoteSettings.get(.expiration),
           let securityFieldSetting = remoteSettings.get(.securityCode),
           let mergedSecurityFieldSetting = MLCardFormFieldSetting.createSettingForField(.securityCode, remoteSetting: securityFieldSetting, cardUI: cardUI) {
            cardFormFields?.append([
                MLCardFormField(
                    fieldProperty: CardExpirationFormFieldProperty(
                        remoteSetting: expirationFieldSetting
                    )
                ),
                MLCardFormField(
                    fieldProperty: CardSecurityCodeFormFieldProperty(
                        remoteSetting: mergedSecurityFieldSetting
                    )
                )
            ])
        }
        
        if let remoteIdTypes = binData?.identificationTypes, remoteIdTypes.count > 0,
           let idNumberSetting = remoteSettings.get(.identificationTypeNumber) {
            if idNumberSetting.autocomplete ?? true {
                let storedIDFields = [
                    MLCardFormField(
                        fieldProperty: IDTypeFormFieldProperty(
                            identificationTypes: remoteIdTypes,
                            idTypeValue: storedIDType,
                            keyboardHeight: measuredKeyboardSize
                        )
                    ),
                    MLCardFormField(
                        fieldProperty: IDNumberFormFieldProperty(
                            identificationTypes: remoteIdTypes,
                            idTypeValue: storedIDType,
                            remoteSetting: idNumberSetting,
                            idNumberValue: storedIDNumber
                        )
                    )
                ]
                cardFormFields?.append(storedIDFields)
                
            } else {
                let defaultIDFields = [
                    MLCardFormField(
                        fieldProperty: IDTypeFormFieldProperty(
                            identificationTypes: remoteIdTypes,
                            keyboardHeight: measuredKeyboardSize
                        )
                    ),
                    MLCardFormField(
                        fieldProperty: IDNumberFormFieldProperty(
                            identificationTypes: remoteIdTypes,
                            remoteSetting: idNumberSetting
                        )
                    )
                ]
                cardFormFields?.append(defaultIDFields)
            }
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
            
            binData = MLCardFormBinData(escEnabled: false, enabled: true, errorMessage: nil, paymentMethod: paymentMethod, cardUI: cardUI, additionalSteps: [], issuers: [], fieldsSetting: [], identificationTypes: [], otherTexts: MLOtherTexts(cardFormTitle: ""))
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
            
            if let cardFormField = MLCardFormFields(rawValue: $0.property.fieldId()), cardFormField != .cardNumber {
                $0.setEnableField(false)
            }
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
    
    func groupIndexOfCardFormField(_ cardFormField: MLCardFormField, offSet: Bool) -> Int? {
            let fieldId = cardFormField.property.fieldId()
            guard let index = cardFormFields?.firstIndex(where: {
                $0.first(where: {
                    $0.property.fieldId() == fieldId
                }) != nil
            }) else { return nil }
            
            if fieldId == MLCardFormFields.expiration.rawValue {
                if offSet {
                    return shouldReturnIndex(index: index, isTurnBack: true)
                }
                return index
            }
        
            if fieldId == MLCardFormFields.securityCode.rawValue {
                if !offSet {
                    return shouldReturnIndex(index: index, isTurnBack: false)
                }
                
                return index
            }
        
            return shouldReturnIndex(index: index, isTurnBack: offSet)
        }
    
    func focusCardFormFieldWithOffset(cardFormField: MLCardFormField, offset: Int) -> MLCardFormField {
        var cardFormFieldAux = cardFormField
        let flattenedCardFormFields = cardFormFields?.flatMap{ $0 }
        guard let unwrappedCardFormFields = flattenedCardFormFields else { return cardFormField }
        let fieldId = cardFormField.property.fieldId()
        let index = unwrappedCardFormFields.firstIndex(where: { $0.property.fieldId() == fieldId }) ?? 0
        let indexWithOffset = min(max(index + offset, 0), unwrappedCardFormFields.count - 1)
        
        if let currentCardFormField = MLCardFormFields(rawValue: fieldId),
            currentCardFormField != .identificationTypesPicker {
            cardFormField.setEnableField(false)
        }
        
        if let field = flattenedCardFormFields?[indexWithOffset] {
            field.setEnableField(true)
            
            if field.property.fieldId() == MLCardFormFields.expiration.rawValue {
                let nextOffset = indexWithOffset + 1
                
                if let nextField = flattenedCardFormFields?[nextOffset], nextField.property.fieldId() == MLCardFormFields.securityCode.rawValue {
                    nextField.setEnableField(true)
                }
            } else if field.property.fieldId() == MLCardFormFields.securityCode.rawValue {
                let previousOffset = indexWithOffset - 1
                
                if let nextField = flattenedCardFormFields?[previousOffset], nextField.property.fieldId() == MLCardFormFields.expiration.rawValue {
                    nextField.setEnableField(true)
                }
            }
            
            if field.property.shouldShowPickerInput() {
                cardFormFieldAux = focusCardFormFieldWithOffset(cardFormField: field, offset: offset)
            } else {
                field.doFocus()
                cardFormFieldAux = field
            }
            
        }
        return cardFormFieldAux
    }
    
    func isCardNumberFieldAndIsMissingCardData(cardFormField: MLCardFormField) -> (isCardNumberMissingCardData: Bool, currentBin: String?) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()) else { return (false, nil) }
        if fieldId == MLCardFormFields.cardNumber,
            cardFormField.property.isValid(value: cardFormField.getValue()),
            let currentBin = cardFormField.getValue()?.replacingOccurrences(of: " ", with: "").prefix(8),
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
    
    func shouldConfigureNavigationBar() -> Bool {
        return builder?.shouldConfigureNavigation ?? true
    }

    func shouldAddStatusBarBackground() -> Bool {
        return builder?.addStatusBarBackground ?? true
    }

    func shouldAnimateOnLoad() -> Bool {
        return builder?.animateOnLoad ?? false
    }
    
    func shouldReturnIndex(index: Int, isTurnBack: Bool) -> Int {
        return isTurnBack ? index - 1 : index + 1
    }
    
    func validatePastedTextIfNeeded(
        text: String?,
        cardFormField: MLCardFormField,
        notifierProtocol: MLCardFormFieldNotifierProtocol,
        complete: () -> Void
    ) {
        guard let fieldId = MLCardFormFields(rawValue: cardFormField.property.fieldId()), let currentText = text else { return }
        
        switch fieldId {
        case .cardNumber:
            //formate card number
            var currentNumber = currentText.trimmingCharacters(in: .whitespaces).components(separatedBy: .decimalDigits.inverted).joined()
            currentNumber = String(currentNumber.prefix(maxCardNumberLength))
            
            //update cardFormFields (only card number propertie) if needed
            if currentNumber.count >= minCardNumberLength {
                cardFormFields?[0] = [
                    MLCardFormField(fieldProperty: CardNumberFormFieldProperty(
                        remoteSetting: MLCardFormFieldSetting(
                            name: MLCardFormFields.cardNumber.rawValue,
                            lenght: currentNumber.count,
                            type: "number",
                            title: "Número de tarjeta".localized,
                            mask: String(repeating: "$", count: currentNumber.count),
                            hintMessage: nil,
                            validationPattern: nil,
                            validationMessage: nil,
                            extraValidations: nil,
                            autocomplete: nil
                        ),
                        cardNumberValue: currentNumber
                    ))
                ]
                
                //update values
                tempTextField.input.text = currentNumber
                cardDataHandler.number = currentNumber
                
                //update UI (collection view)
                complete()
                
                //render fields
                setupAndRenderCardFormFields(cardFormFields: cardFormFields, notifierProtocol: notifierProtocol)
            }
        default:
            break
        }
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
                MLCardFormTracker.sharedInstance.trackEvent(
                    path: "/card_form/bin_number/recognized",
                    properties: [
                        MLCardFormTracker.TrackerParams.bin.value: binNumber,
                        MLCardFormTracker.TrackerParams.issuer.value: cardFormBinData.issuers.first?.id ?? 0,
                        MLCardFormTracker.TrackerParams.paymentMethodId.value: cardFormBinData.paymentMethod.paymentMethodId,
                        MLCardFormTracker.TrackerParams.paymentMethodType.value: cardFormBinData.paymentMethod.paymentTypeId
                    ]
                )
                self.lastFetchedBinNumber = binNumber
                self.binData = cardFormBinData
                self.viewModelDelegate?.updateTitle(title: cardFormBinData.otherTexts.cardFormTitle)
                self.updateHandlers()
                completion?(.success(binNumber))
            case .failure(let error):
                self.viewModelDelegate?.shouldUpdateFields(remoteSettings: nil)
                completion?(.failure(error))
            }
        })
    }

    func addCard(completion: ((Result<MLCardFormCardInformation, Error>) -> ())? = nil) {
        guard let tokenizationData = getTokenizationData(), let addCardData = getAddCardData() else {
            completion?(.failure(NSError(domain: "MLCardForm", code: 0, userInfo: nil) as Error))
            return
        }
        serviceManager.addCardService.addCardToken(tokenizationData: tokenizationData, completion: { [weak self] (result: Result<MLCardFormTokenizationCardData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let tokenCardData):
                if let esc = tokenCardData.esc,
                   let firstSixDigits = tokenCardData.firstSixDigits,
                   let lastFourDigits = tokenCardData.lastFourDigits {
                    MLCardFormConfiguratorManager.escProtocol.saveESC(config: MLCardFormConfiguratorManager.escConfig, firstSixDigits: firstSixDigits, lastFourDigits: lastFourDigits, esc: esc)
                }
                self.serviceManager.addCardService.saveCard(tokenId: tokenCardData.id, addCardData: addCardData, completion: { [weak self] (result: Result<MLCardFormAddCardData, Error>) in
                    guard let self = self else { return }
                    switch result {
                    case .success(let addCardData):
                        let bin = tokenCardData.firstSixDigits ?? ""
                        let issuer = self.binData?.issuers.first?.id ?? 0
                        let paymentMethodId = self.binData?.paymentMethod.paymentMethodId ?? ""
                        let paymentTypeId = self.binData?.paymentMethod.paymentTypeId ?? ""
                        MLCardFormTracker.sharedInstance.trackEvent(path: "/card_form/success",
                                                                    properties: [MLCardFormTracker.TrackerParams.bin.value: bin,
                                                                                 MLCardFormTracker.TrackerParams.issuer.value: issuer,
                                                                                 MLCardFormTracker.TrackerParams.paymentMethodId.value: paymentMethodId,
                                                                                 MLCardFormTracker.TrackerParams.paymentMethodType.value: paymentTypeId])
                        self.saveDataForReuse()
                        let lastFourDigits = tokenCardData.lastFourDigits ?? ""
                        var cardInformation = MLCardFormCardInformation(cardId: addCardData.getId(), paymentType: paymentTypeId, bin: bin, lastFourDigits: lastFourDigits)
                        completion?(.success(cardInformation))
                    case .failure(let error):
                        if case
                            MLCardFormAddCardServiceError.missingPrivateKey = error {
                            completion?(.success(MLCardFormCardInformation()))
                        } else {
                            let errorMessage = error.localizedDescription
                            MLCardFormTracker.sharedInstance.trackEvent(
                                path: "/card_form/error",
                                properties: [
                                    MLCardFormTracker.TrackerParams.bin.value: tokenCardData.firstSixDigits ?? "",
                                    MLCardFormTracker.TrackerParams.issuer.value: addCardData.issuer.id,
                                    MLCardFormTracker.TrackerParams.paymentMethodId.value: addCardData.paymentMethod.id,
                                    MLCardFormTracker.TrackerParams.paymentMethodType.value: addCardData.paymentMethod.paymentTypeId,
                                    MLCardFormTracker.TrackerParams.errorStep.value: "save_card_data",
                                    MLCardFormTracker.TrackerParams.errorMessage.value: errorMessage
                                ]
                            )
                            completion?(.failure(error))
                        }
                    }
                })
            case .failure(let error):
                let errorMessage = error.localizedDescription
                MLCardFormTracker.sharedInstance.trackEvent(
                    path: "/card_form/error",
                    properties: [
                        MLCardFormTracker.TrackerParams.bin.value: tokenizationData.cardNumber.prefix(6),
                        MLCardFormTracker.TrackerParams.issuer.value: addCardData.issuer.id,
                        MLCardFormTracker.TrackerParams.paymentMethodId.value: addCardData.paymentMethod.id,
                        MLCardFormTracker.TrackerParams.paymentMethodType.value: addCardData.paymentMethod.paymentTypeId,
                        MLCardFormTracker.TrackerParams.errorStep.value: "save_card_token",
                        MLCardFormTracker.TrackerParams.errorMessage.value: errorMessage
                    ]
                )
                completion?(.failure(error))
            }
        })
    }
}

// MARK: Track events.
extension MLCardFormViewModel {
    func trackValidBinNumber(path: String) {
        let issuer = binData?.issuers.first?.id ?? 0
        let paymentMethodId = binData?.paymentMethod.paymentMethodId ?? ""
        let paymentTypeId = binData?.paymentMethod.paymentTypeId ?? ""
        
        MLCardFormTracker.sharedInstance.trackEvent(
            path: path,
            properties: [
                MLCardFormTracker.TrackerParams.bin.value: lastFetchedBinNumber,
                MLCardFormTracker.TrackerParams.issuer.value: issuer,
                MLCardFormTracker.TrackerParams.paymentMethodId.value: paymentMethodId,
                MLCardFormTracker.TrackerParams.paymentMethodType.value: paymentTypeId
            ]
        )
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

