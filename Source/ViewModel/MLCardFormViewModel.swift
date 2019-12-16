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
    
    private var trackingConfiguration: MLCardFormTrackerConfiguration?
    var measuredKeyboardSize: CGRect = CGRect.zero
    
    private var binService: MLCardFormBinService = MLCardFormBinService()
    var lastFetchedBinNumber: String = ""
    private var binData: MLCardFormBinData?
    private var addCardData: MLCardFormAddCardData?
    private let addCardService: MLCardFormAddCardService = MLCardFormAddCardService()

    weak var viewModelDelegate: MLCardFormViewModelProtocol?

    private var builder: MLCardFormBuilder?
    
    func updateWithBuilder(_ builder: MLCardFormBuilder) {
        self.builder = builder
        trackingConfiguration = builder.trackingConfiguration
        addCardService.update(publicKey: builder.publicKey, privateKey: builder.privateKey)
        binService.update(siteId: builder.siteId, excludedPaymentTypes: builder.excludedPaymentTypes, flowId: builder.flowId)
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
        cardFormFields?.forEach{ $0.forEach{
            $0.notifierProtocol = notifierProtocol
            $0.render()
        }}
    }

    func updateCardFormFields(_ remoteSettings: [MLCardFormFieldSetting], notifierProtocol: MLCardFormFieldNotifierProtocol?) {
        cardFormFields = [[MLCardFormField]]()
        guard let cardUI = binData?.cardUI else { return }

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
            let expirationField = getCardFormFieldWithID(MLCardFormFields.expiration.rawValue),
            expirationField.isValid() == false {
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
        if let numberCardFormField = getCardFormFieldWithID(MLCardFormFields.identificationTypeNumber.rawValue) {
            numberCardFormField.clearValue()
            numberCardFormField.property.setValue(value: value)
            numberCardFormField.updateInput()
        }
    }
    
    func saveDataForReuse() {
        if let cardNameFieldSetting = getCardFormFieldWithID(MLCardFormFields.name.rawValue) {
            storedCardName = cardNameFieldSetting.getValue()
        }
        if let idTypeFieldSetting = getCardFormFieldWithID(MLCardFormFields.identificationTypesPicker.rawValue) {
            storedIDType = idTypeFieldSetting.getValue()
        }
        if let idNumberFieldSetting = getCardFormFieldWithID(MLCardFormFields.identificationTypeNumber.rawValue) {
            storedIDNumber = idNumberFieldSetting.getValue()
        }
    }
    
    func getCardFormFieldWithID(_ fieldId: String) -> MLCardFormField? {
        return cardFormFields?.flatMap{$0}.first(where: { $0.property.fieldId() == fieldId })
    }

    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.height <= 568
    }

    func updateCardIssuerImage(imageURL: String) {
        if let cardUI = binData?.cardUI,
            let cardHandlerToUpdate = cardUIHandler as? DefaultCardUIHandler {
            let cardUI = MLCardFormCardUI.copyCardUIWithIssuerImage(cardUI, issuerImageUrl: imageURL)
            cardHandlerToUpdate.update(cardUI: cardUI)
            viewModelDelegate?.shouldUpdateCard(cardUI: cardUIHandler)
        }
    }

    func getNavigationBarCustomColor() -> (backgroundColor: UIColor?, textColor: UIColor?) {
        return (builder?.navigationCustomBackgroundColor, builder?.navigationCustomTextColor)
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
            binData = MLCardFormBinData.copyCardFormBinDataWithIssuer(data, issuer: issuer)
        }
    }
    
    func getPaymentMethodTypeId() -> String? {
        return binData?.paymentMethod.paymentTypeId
    }
}

// MARK: Services
extension MLCardFormViewModel {
    func getCardData(binNumber: String, completion: ((Result<String, Error>) -> ())? = nil) {
        binService.getCardData(binNumber: binNumber, completion: { [weak self] (result: Result<MLCardFormBinData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let cardFormBinData):
                self.lastFetchedBinNumber = binNumber
                self.binData = cardFormBinData
                self.updateHandlers()
                completion?(.success(binNumber))
            case .failure(let error):
                completion?(.failure(error))
            }
        })
    }

    func addCard(completion: ((Result<String, Error>) -> ())? = nil) {
        guard let tokenizationData = getTokenizationData(), let addCardData = getAddCardData() else {
            completion?(.failure(NSError(domain: "MLCardForm", code: 0, userInfo: nil) as Error))
            return
        }
        addCardService.addCard(tokenizationData: tokenizationData, addCardData: addCardData, completion: { [weak self] (result: Result<MLCardFormAddCardData, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let addCardData):
                self.addCardData = addCardData
                completion?(.success(addCardData.getId()))
            case .failure(let error):
                if case MLCardFormAddCardServiceError.missingPrivateKey = error {
                    completion?(.success(""))
                } else {
                    completion?(.failure(error))
                }
            }
        })
    }
}

// MARK: Privates.
private extension MLCardFormViewModel {
    func updateHandlers() {
        if let cardHandlerToUpdate = cardUIHandler as? DefaultCardUIHandler  {
            cardHandlerToUpdate.update(cardUI: binData?.cardUI)
            viewModelDelegate?.shouldUpdateCard(cardUI: cardUIHandler)
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
        guard let idTypeFieldSetting = getCardFormFieldWithID(MLCardFormFields.identificationTypesPicker.rawValue),
            let type = idTypeFieldSetting.getPickerValue(),
            let idNumberFieldSetting = getCardFormFieldWithID(MLCardFormFields.identificationTypeNumber.rawValue),
            let number = idNumberFieldSetting.getUnmaskedValue() else {
            return nil
        }
        return MLCardFormIdentification(type: type, number: number)
    }
}

