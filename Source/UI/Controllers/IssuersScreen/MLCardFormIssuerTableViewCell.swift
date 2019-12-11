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
    private weak var innerCircle: UIView?

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
        innerCircle?.removeFromSuperview()
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
            radioButton.layer.borderColor = MLStyleSheetManager.styleSheet.secondaryColor.cgColor
            let circle = UIView(frame: radioButton.frame)
            circle.layer.cornerRadius = 8
            innerCircle = circle
            addSubview(circle)
            UIView.animate(withDuration: 0.2, animations: {
                circle.frame = CGRect(x: self.radioButton.frame.origin.x + 4, y: self.radioButton.frame.origin.y + 4, width: 8, height: 8)
                circle.backgroundColor = MLStyleSheetManager.styleSheet.secondaryColor
                circle.layer.cornerRadius = 4
            })
        } else {
            innerCircle?.removeFromSuperview()
            radioButton.layer.borderColor = UIColor.gray.cgColor
        }
    }
}

