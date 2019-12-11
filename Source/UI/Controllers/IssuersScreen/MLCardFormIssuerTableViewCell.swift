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
    private var radioButton = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellStyle()
        self.radioButton = setupRadioButton()
        setupIssuerImage(rightOf: radioButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearImage()
        radioButton.subviews.first?.alpha = 0
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
        let button = UIView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            button.heightAnchor.constraint(equalToConstant: 16),
            button.widthAnchor.constraint(equalToConstant: 16)
        ])
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 2

        let innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(innerCircle)
        NSLayoutConstraint.activate([
            innerCircle.topAnchor.constraint(equalTo: button.topAnchor, constant: 4),
            innerCircle.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 4),
            innerCircle.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4),
            innerCircle.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -4)
        ])
        innerCircle.layer.cornerRadius = 4
        innerCircle.backgroundColor = MLStyleSheetManager.styleSheet.secondaryColor
        innerCircle.alpha = 0
        return button
    }

    func setupIssuerImage(rightOf radioButton: UIView) {
        issuerImageView.translatesAutoresizingMaskIntoConstraints = false
        issuerImageView.contentMode = .scaleAspectFit
        contentView.addSubview(issuerImageView)
        NSLayoutConstraint.activate([
            issuerImageView.widthAnchor.constraint(equalToConstant: contentView.frame.width / deltaWidthRatio),
            issuerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            issuerImageView.leftAnchor.constraint(equalTo: radioButton.rightAnchor, constant: UI.Margin.S_MARGIN),
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
            let minCircle = radioButton.subviews.first
            guard let minorCircle = minCircle else { return }
            minorCircle.alpha = 1
            UIView.animate(withDuration: 2.5, animations: {
                self.radioButton.layer.borderColor = MLStyleSheetManager.styleSheet.secondaryColor.cgColor
                minorCircle.alpha = 1
            })
        } else {
            radioButton.subviews.first?.alpha = 0
            radioButton.layer.borderColor = UIColor.gray.cgColor
        }
    }
}
