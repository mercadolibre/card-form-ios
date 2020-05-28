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
    private weak var radioButton: MLCardFormRadioButton?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellStyle()
        setupRadioButton()
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
        clearAccessibilityLabel()
    }
}

// MARK: Setup cell
extension MLCardFormIssuerTableViewCell {
    func setupCell(with issuer: MLCardFormIssuer, radioButtonOn: Bool) {
        radioButtonOn ? setupRadioButton(radioButtonOn: true) : setupRadioButton(radioButtonOn: false)
        if let imageUrl = issuer.imageUrl {
            issuerImageView.setRemoteImage(imageUrl: imageUrl)
        }
        accessibilityLabel = issuer.name
    }
}

// MARK: Privates
private extension MLCardFormIssuerTableViewCell {
    func setupCellStyle() {
        backgroundColor = .white
        selectionStyle = .none
    }

    func setupRadioButton() {
        let button = MLCardFormRadioButton()
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UI.Margin.M_MARGIN)
        ])
        radioButton = button
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

    func clearAccessibilityLabel() {
        accessibilityLabel = ""
    }
}

// MARK: RadioButton ON/OFF
extension MLCardFormIssuerTableViewCell {
    func setupRadioButton(radioButtonOn: Bool) {
        radioButton?.setup(radioButtonOn: radioButtonOn)
    }
}
