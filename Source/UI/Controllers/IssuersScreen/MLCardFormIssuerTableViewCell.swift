//
//  MLCardFormIssuerTableViewCell.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 11/11/2019.
//

import Foundation

final class MLCardFormIssuerTableViewCell: UITableViewCell {

    static let cellIdentifier = "IssuerTableViewCell"
    private let issuerImageView = UIImageView()
    private let issuerImageHeight: CGFloat = 35
    private let deltaWidthRatio: CGFloat = 3.5

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        backgroundColor = .white
        setupIssuerImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearImage()
    }
}

// MARK: Setup cell
extension MLCardFormIssuerTableViewCell {
    func setupCell(with issuerImageUrl: String?) {
        if let imageUrl = issuerImageUrl {
            issuerImageView.setRemoteImage(imageUrl: imageUrl)
        }
    }
}

// MARK: Privates
private extension MLCardFormIssuerTableViewCell {
    func setupIssuerImage() {
        issuerImageView.translatesAutoresizingMaskIntoConstraints = false
        issuerImageView.contentMode = .scaleAspectFit
        contentView.addSubview(issuerImageView)
        NSLayoutConstraint.activate([
            issuerImageView.widthAnchor.constraint(equalToConstant: contentView.frame.width / deltaWidthRatio),
            issuerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            issuerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UI.Margin.S_MARGIN),
            issuerImageView.heightAnchor.constraint(equalToConstant: issuerImageHeight)
        ])
    }

    func clearImage() {
        issuerImageView.image = nil
    }
}
