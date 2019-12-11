//
//  MLCardFormIssuerTableViewCell.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 11/11/2019.
//

import Foundation
import MLUI

final class MLCardFormIssuerTableViewCell: UITableViewCell {

    static let cellIdentifier = "IssuerTableViewCell"
    private let issuerImageView = UIImageView()
    private let issuerImageHeight: CGFloat = 35
    private let deltaWidthRatio: CGFloat = 3.5
    private weak var radioButton: UIView?
    private let radioButtonSize: CGFloat = 16

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellStyle()
        radioButton = setupRadioButton()
        if let radioButton = radioButton {
            setupIssuerImage(rightOf: radioButton)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        setupRadioButton(radioButtonOn: false)
        clearImage()
    }
}

// MARK: Setup cell
extension MLCardFormIssuerTableViewCell {
    func setupCell(with issuerImageUrl: String?, radioButtonOn: Bool) {
        radioButtonOn ? setupRadioButton(radioButtonOn: true) : setupRadioButton(radioButtonOn: false)
        if let imageUrl = issuerImageUrl {
            issuerImageView.setRemoteImage(imageUrl: imageUrl)
        }
    }
}

// MARK: Privates
private extension MLCardFormIssuerTableViewCell {
    func setupCellStyle() {
        backgroundColor = .white
        selectionStyle = .none
    }

    func setupRadioButton() -> UIView {
        let radioButton = UIView()
        radioButton.translatesAutoresizingMaskIntoConstraints = false
        radioButton.isUserInteractionEnabled = false
        contentView.addSubview(radioButton)
        NSLayoutConstraint.activate([
            radioButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            radioButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UI.Margin.M_MARGIN),
            radioButton.heightAnchor.constraint(equalToConstant: radioButtonSize),
            radioButton.widthAnchor.constraint(equalToConstant: radioButtonSize)
        ])
        radioButton.backgroundColor = .white
        radioButton.layer.cornerRadius = radioButtonSize/2
        radioButton.layer.borderWidth = 2

        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        radioButton.addSubview(innerCircle)
        NSLayoutConstraint.activate([
            innerCircle.topAnchor.constraint(equalTo: radioButton.topAnchor, constant: UI.Margin.S_MARGIN),
            innerCircle.leadingAnchor.constraint(equalTo: radioButton.leadingAnchor, constant: UI.Margin.S_MARGIN),
            innerCircle.trailingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: -UI.Margin.S_MARGIN),
            innerCircle.bottomAnchor.constraint(equalTo: radioButton.bottomAnchor, constant: -UI.Margin.S_MARGIN)
        ])
        innerCircle.layer.cornerRadius = radioButtonSize/4
        innerCircle.backgroundColor = MLStyleSheetManager.styleSheet.secondaryColor
        innerCircle.alpha = 0
        return radioButton
    }

    func setupIssuerImage(rightOf radioButton: UIView) {
        issuerImageView.translatesAutoresizingMaskIntoConstraints = false
        issuerImageView.contentMode = .scaleAspectFit
        contentView.addSubview(issuerImageView)
        NSLayoutConstraint.activate([
            issuerImageView.widthAnchor.constraint(equalToConstant: contentView.frame.width / deltaWidthRatio),
            issuerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            issuerImageView.leftAnchor.constraint(equalTo: radioButton.rightAnchor, constant: UI.Margin.M_MARGIN),
            issuerImageView.heightAnchor.constraint(equalToConstant: issuerImageHeight)
        ])
    }

    func clearImage() {
        issuerImageView.image = nil
    }
}

// MARK: RadioButton
extension MLCardFormIssuerTableViewCell {
    func setupRadioButton(radioButtonOn: Bool) {
        if radioButtonOn {
            let circle = radioButton?.subviews.first
            guard let innerCircle = circle else { return }
            innerCircle.alpha = 1
            UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: { [weak self] in
                guard let self = self else { return }
                self.radioButton?.layer.borderColor = MLStyleSheetManager.styleSheet.secondaryColor.cgColor
                innerCircle.alpha = 1
            })
        } else {
            radioButton?.subviews.first?.alpha = 0
            radioButton?.layer.borderColor = UI.Colors.confirmButtonColor.cgColor
        }
    }
}
