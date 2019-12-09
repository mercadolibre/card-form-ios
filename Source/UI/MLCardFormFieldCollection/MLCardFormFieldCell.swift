//
//  MLCardFormFieldCell.swift
//  MLCardForm
//
//  Created by Eric Ertl on 01/11/2019.
//

import Foundation

class MLCardFormFieldCell: UICollectionViewCell {

    static let cellIdentifier: String = "cell"
    private let cardFormFieldInset: CGFloat = 10

    var cardFormFields: [MLCardFormField]? {
        didSet {
            guard let cardFormFields = cardFormFields, 1...2 ~= cardFormFields.count else { return }
            
            removeConstraintsAndSubviews()
            
            if let formField = cardFormFields.first {
                contentView.addSubview(formField)
                var cardFormFieldConstraints = [
                    formField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: cardFormFieldInset),
                    formField.topAnchor.constraint(equalTo: contentView.topAnchor),
                    formField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                ]
                if cardFormFields.count == 1 {
                    cardFormFieldConstraints.append(formField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cardFormFieldInset))
                } else {
                    if let widthMultiplier = formField.property.inputConstraintWidthMultiplier() {
                        cardFormFieldConstraints.append(formField.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: widthMultiplier, constant: 1))
                    }
                }
                NSLayoutConstraint.activate(cardFormFieldConstraints)
            }

            if cardFormFields.count == 2,
                let formField = cardFormFields.last,
                let firstFormField = contentView.subviews.first as? MLCardFormField {
                contentView.addSubview(formField)
                var cardFormFieldConstraints = [formField.leadingAnchor.constraint(equalTo: firstFormField.trailingAnchor, constant: cardFormFieldInset),
                    formField.topAnchor.constraint(equalTo: contentView.topAnchor),
                    formField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    formField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cardFormFieldInset)
                ]
                if firstFormField.property.inputConstraintWidthMultiplier() == nil {
                    cardFormFieldConstraints.append(formField.widthAnchor.constraint(equalTo: firstFormField.widthAnchor))
                }
                NSLayoutConstraint.activate(cardFormFieldConstraints)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func removeConstraintsAndSubviews() {
        self.constraints.forEach {
            $0.isActive = false
            removeConstraint($0)
        }
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
