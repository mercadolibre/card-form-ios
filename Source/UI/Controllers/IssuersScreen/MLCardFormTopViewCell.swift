//
//  MLCardFormTopViewCell.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 27/11/2019.
//

import Foundation

final class MLCardFormTopViewCell: UITableViewCell {

    static let cellIdentifier = "TopViewCell"
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
        setupLabel()
        UIAccessibility.post(notification: .layoutChanged, argument: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearLabelText()
    }
}

// MARK: Setup cell
extension MLCardFormTopViewCell {
    func setupCell() {
        titleLabel.text = "¿Quién emitió tu tarjeta?".localized
    }
}

// MARK: Privates
private extension MLCardFormTopViewCell {
    func setupLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UI.Colors.labelColor
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: UI.FontSize.L_FONT)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UI.Margin.M_MARGIN),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UI.Margin.M_MARGIN),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func clearLabelText() {
        titleLabel.text = ""
    }
}
