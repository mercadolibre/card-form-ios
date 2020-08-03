//
//  MLCardFormField
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 10/28/19.
//  Copyright © 2019 Juan Sebastian Sanzone. All rights reserved.
//

import UIKit
import MLUI

final public class MLCardFormField: UIView {
    // MARK: Privates
    private lazy var accesoryBackgroundColor: UIColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    private lazy var labelTextColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.45)
    private lazy var inputTextColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8)
    private lazy var errorColor = MLStyleSheetManager.styleSheet.errorColor
    private lazy var background: UIColor = .white
    private lazy var inputFont = UIFont.ml_regularSystemFont(ofSize: UI.FontSize.M_FONT)
    private lazy var labelFont = UIFont.ml_regularSystemFont(ofSize: UI.FontSize.S_FONT)
    private lazy var labelErrorFont = UIFont.ml_semiboldSystemFont(ofSize: UI.FontSize.S_FONT)

    // MARK: Internals Defs.
    internal lazy var highlightColor: UIColor = MLStyleSheetManager.styleSheet.secondaryColor
    internal lazy var bottomLineDefaultColor: UIColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 0.2)
    internal var maxLenght: Int = 40
    internal var measuredKeyboardSize: CGRect = CGRect.zero

    // MARK: Internals UI
    internal let input = UITextField()
    internal let helpLabel = UILabel()
    internal let titleLabel = UILabel()
    internal let bottomLine = UIView.createView()
    internal var customMask: MLCardFormCustomMask?

    // MARK: Publics
    public var property: MLCardFormFieldPropertyProtocol
    public weak var notifierProtocol: MLCardFormFieldNotifierProtocol?

    // MARK: Init
    public init(fieldProperty: MLCardFormFieldPropertyProtocol) {
        property = fieldProperty
        if let maskPattern = fieldProperty.patternMask() {
            customMask = MLCardFormCustomMask(formattingPattern: maskPattern)
            maxLenght = maskPattern.count
        } else {
            maxLenght = fieldProperty.maxLenght()
        }
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public methods.
extension MLCardFormField {
    @discardableResult
    public func render() -> MLCardFormField {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = background
        setupLabel()
        setupInput()
        setupBottomLine()
        setupHelpLabel()
        return self
    }

    func resignFocus() {
        input.resignFirstResponder()
        bottomLine.backgroundColor = bottomLineDefaultColor
    }

    @discardableResult
    func doFocus() -> MLCardFormField {
        input.becomeFirstResponder()
        bottomLine.backgroundColor = highlightColor
        return self
    }

    public func getValue() -> String? {
        return input.text
    }
    
    func getUnmaskedValue() -> String? {
        var value: String? = getValue()
        if let customMask = customMask {
            value = customMask.cleanText
        }
        return value
    }
    
    func getPickerValue() -> String? {
        var value = getValue()
        if let pickerOptions = property.pickerOptions(),
            let pickerView = input.inputView as? UIPickerView {
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            if selectedRow >= 0 {
                let selectedPickerValue = pickerOptions[selectedRow].value
                if let selectedPickerOption = pickerOptions.first(where: {$0.value == selectedPickerValue}) {
                    value = selectedPickerOption.id
                }
            }
        }
        return value
    }
    
    func clearValue() {
        input.text = ""
        _ = textFieldShouldClear(input)
    }
    
    func updateInput() {
        if let maskPattern = property.patternMask() {
            customMask = MLCardFormCustomMask(formattingPattern: maskPattern)
            maxLenght = maskPattern.count
        } else {
            customMask = nil
            maxLenght = property.maxLenght()
        }
        input.maxLength = maxLenght
        
        if let keyboardType = property.keyboardType() {
            input.keyboardType = keyboardType
        }
    }
}

// MARK: Private methods.
private extension MLCardFormField {
    func setupLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        titleLabel.textColor = labelTextColor
        titleLabel.text = getTitle()
        titleLabel.font = labelFont
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }

    func setupInput() {
        input.translatesAutoresizingMaskIntoConstraints = false
        input.keyboardAppearance = .light
        input.autocorrectionType = UITextAutocorrectionType.no
        input.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        input.accessibilityLabel = titleLabel.text

        if let defaultValue = property.defaultValue()?.uppercased() {
            input.text = defaultValue
            if let customMask = customMask {
                input.text = customMask.formatString(string: defaultValue)
            }
        }
        input.maxLength = maxLenght

        if let keyboardType = property.keyboardType() {
            input.keyboardType = keyboardType
        }
        
        if property.shouldShowKeyboardClearButton() {
            input.clearButtonMode = .whileEditing
        }
        
        if property.shouldShowTick() {
            let tick = UIImage(named: "tick", in: Bundle(for: type(of: self)), compatibleWith: nil)
            input.rightView = UIImageView(image: tick)
            input.rightViewMode = .never
        }

        input.delegate = self
        // If field is a picker hide the caret
        input.tintColor = property.shouldShowPickerInput() ? .clear : highlightColor
        input.textColor = inputTextColor
        input.font = inputFont
        input.autocapitalizationType = .allCharacters

        if property.shouldShowToolBar() {
            setKeyboardToolBar()
        }

        addSubview(input)
        NSLayoutConstraint.activate([
            input.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            input.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            input.heightAnchor.constraint(equalToConstant: 20),
            input.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
        ])

        if property.shouldShowPickerInput(),
            let pickerOptions = property.pickerOptions(),
            let keyboardHeight = property.keyboardHeight(),
            pickerOptions.count > 0 {
            measuredKeyboardSize = keyboardHeight
            setupPickerInputView()
            // If field is a picker and doesn't show tick, show down_arrow
            if !property.shouldShowTick() {
                let arrow_down = UIImage(named: "arrow_down", in: Bundle(for: type(of: self)), compatibleWith: nil)
                input.rightView = UIImageView(image: arrow_down)
                input.rightViewMode = .always
            }
        }
    }

    func setupBottomLine() {
        bottomLine.backgroundColor = bottomLineDefaultColor
        addSubview(bottomLine)
        NSLayoutConstraint.activate([
            bottomLine.topAnchor.constraint(equalTo: input.bottomAnchor, constant: 3),
            bottomLine.leadingAnchor.constraint(equalTo: input.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: input.trailingAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 2),
        ])
    }

    func setupHelpLabel() {
        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(helpLabel)
        showHelpLabel()
        NSLayoutConstraint.activate([
            helpLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            helpLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            helpLabel.topAnchor.constraint(equalTo: bottomLine.bottomAnchor, constant: 6),
            helpLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func setupPickerInputView() {
        let picker = UIPickerView()
        if measuredKeyboardSize != CGRect.zero {
            let inputAccessoryViewHeight = input.inputAccessoryView?.frame.size.height ?? 0
            var pickerFrame = picker.frame
            pickerFrame.size.height = measuredKeyboardSize.size.height - inputAccessoryViewHeight
            picker.frame = pickerFrame
        }
        picker.backgroundColor = .white
        picker.delegate = self
        
        if let pickerOptions = property.pickerOptions(),
            pickerOptions.count > 0 {
            
            var selectedIndex = 0
            if let value = getValue(), !value.isEmpty {
                selectedIndex = pickerOptions.firstIndex(where: {$0.value == value}) ?? 0
            }
            // Set first item as selected by default if text is empty
            picker.selectRow(selectedIndex, inComponent: 0, animated: true)
            // picker didSelectRow is not called if selectRow is called by code
            pickerView(picker, didSelectRow: selectedIndex, inComponent: 0)
        }
        
        input.inputView = picker
    }
}

// MARK: Internal methods.
internal extension MLCardFormField {
    func getTitle() -> String? {
        return property.fieldTitle()
    }

    func showHelpLabel() {
        helpLabel.textColor = labelTextColor
        helpLabel.font = labelFont
        helpLabel.text = property.helpMessage()
    }

    func showErrorLabel() {
        helpLabel.textColor = errorColor
        helpLabel.font = labelErrorFont
        helpLabel.text = property.errorMessage()
        sendAccessibilityMessage(helpLabel.text)
    }

    func isValid() -> Bool {
        guard let value = getValue() else { return false }
        if property.isValid(value: value) {
            showHelpLabel()
            bottomLine.backgroundColor = highlightColor
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            return true
        } else {
            showErrorLabel()
            bottomLine.backgroundColor  = errorColor
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return false
        }
    }

    func checkExtraValidations() {
        guard let value = getValue(), !value.isEmpty else { return }
        if let cardNumberField = property as? CardNumberFormFieldProperty,
            !cardNumberField.isExtraValid(value: value) {
            showErrorLabel()
            bottomLine.backgroundColor = errorColor
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }

    func sendAccessibilityMessage(_ text: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: text)
        }
    }
}
