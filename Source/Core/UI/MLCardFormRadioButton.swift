//
//  MLCardFormRadioButton.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 12/12/2019.
//

import Foundation
import MLUI

final class MLCardFormRadioButton: UIView {

    private let radioButtonSize: CGFloat = 16

    public init() {
        super.init(frame: .zero)
        render()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Privates
private extension MLCardFormRadioButton {
    func render() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: radioButtonSize),
            widthAnchor.constraint(equalToConstant: radioButtonSize)
        ])
        backgroundColor = .white
        layer.cornerRadius = radioButtonSize/2
        layer.borderWidth = 2

        let innerCircle = buildRadioButtonInnerCircle()
        addSubview(innerCircle)
        NSLayoutConstraint.activate([
            innerCircle.topAnchor.constraint(equalTo: topAnchor, constant: UI.Margin.S_MARGIN),
            innerCircle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: UI.Margin.S_MARGIN),
            innerCircle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -UI.Margin.S_MARGIN),
            innerCircle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -UI.Margin.S_MARGIN)
        ])
    }

    func buildRadioButtonInnerCircle() -> UIView {
        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.layer.cornerRadius = radioButtonSize/4
        innerCircle.backgroundColor = MLStyleSheetManager.styleSheet.secondaryColor
        innerCircle.alpha = 0
        return innerCircle
    }
}

// MARK: RadioButton ON/Off
extension MLCardFormRadioButton {
    func setup(radioButtonOn: Bool) {
        if radioButtonOn {
            let circle = subviews.first
            guard let innerCircle = circle else { return }
            innerCircle.alpha = 1
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.layer.borderColor = MLStyleSheetManager.styleSheet.secondaryColor.cgColor
                innerCircle.alpha = 1
            })
        } else {
            subviews.first?.alpha = 0
            layer.borderColor = UI.Colors.confirmButtonColor.cgColor
        }
    }
}
