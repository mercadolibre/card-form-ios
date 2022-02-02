//
//  MLCardFormIssuerTableViewCell.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 11/11/2019.
//

import Foundation
import MLUI
import UIKit

final class MLCardFormIssuerTableViewCell: UITableViewCell {

    static let cellIdentifier = "IssuerTableViewCell"
    private let issuerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let issuerImageHeight: CGFloat = 35
    private let deltaWidthRatio: CGFloat = 3.5
    private weak var radioButton: MLCardFormRadioButton?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellStyle()
        setupRadioButton()
        if let radioButton = radioButton {
            setupIssuerImage(rightOf: radioButton)
            setupLabel(rightOf: radioButton)
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
        checkHasImage(issuer: issuer)
        accessibilityLabel = issuer.name
    }
    
    private func setupImageView(image: UIImage) {
        issuerImageView.image = image
        titleLabel.isHidden = true
        issuerImageView.isHidden = false
    }
    
    private func setupPlaceholder(title: String) {
        titleLabel.text = title
        issuerImageView.isHidden = true
        titleLabel.isHidden = false
    }
    
    private func checkHasImage(issuer: MLCardFormIssuer) {
        guard let imageURL = issuer.imageUrl else {
            setupPlaceholder(title: issuer.name)
            return
        }
        
        guard let url = URL.init(string: imageURL) else {
            setupPlaceholder(title: issuer.name)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: url)
                    DispatchQueue.main.async {
                        if let image = UIImage(data: data) {
                            self.setupImageView(image: image)
                        } else {
                            self.setupPlaceholder(title: issuer.name)
                        }
                    }
            } catch {
                DispatchQueue.main.async {
                    self.setupPlaceholder(title: issuer.name)
                }
            }
        }
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
    
    func setupLabel(rightOf radioButton: UIView) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UI.Colors.labelColor
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: UI.FontSize.XM_FONT)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width / deltaWidthRatio),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: radioButton.rightAnchor, constant: UI.Margin.M_MARGIN),
            titleLabel.heightAnchor.constraint(equalToConstant: issuerImageHeight)
        ])
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
