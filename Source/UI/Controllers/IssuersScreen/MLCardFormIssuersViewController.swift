//
//  MLCardFormIssuersViewController.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 12/11/2019.
//

import Foundation
import UIKit
import MLUI

final class MLCardFormIssuersViewController: UIViewController {

    private let issuersData: [MLCardFormIssuer]?
    private let issuersTableView = UITableView()
    weak var delegate: IssuerSelectedProtocol?
    private var selectedIssuer: MLCardFormIssuer?
    private let confirmButtonHeight: CGFloat = 48
    private let shadowViewHeight: CGFloat = 40
    private let bottomViewHeight: CGFloat = 96

    public init(viewModel: MLCardFormViewModel) {
        issuersData = viewModel.getIssuers()
        super.init(nibName: nil, bundle: nil)
        let bottomView = setupBottomView()
        setupIssuersTableView(aboveOf: bottomView)
        setupShadowViews(aboveOf: bottomView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Privates
private extension MLCardFormIssuersViewController {
    func setupBottomView() -> UIView {
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        NSLayoutConstraint.activate([
             bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             bottomView.heightAnchor.constraint(equalToConstant: bottomViewHeight)
        ])

        let confirmButton = UIButton()
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.backgroundColor = UI.Colors.confirmButtonColor
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = UIFont.ml_semiboldSystemFont(ofSize: UI.FontSize.XM_FONT)
        confirmButton.setTitleColor(UI.Colors.confirmButtonTitleColor, for: .normal)
        confirmButton.titleLabel?.textAlignment = .center
        confirmButton.layer.cornerRadius = 6
        view.addSubview(confirmButton)
        NSLayoutConstraint.activate([
            confirmButton.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor),
            confirmButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: UI.Margin.L_MARGIN),
            confirmButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -UI.Margin.L_MARGIN),
            confirmButton.heightAnchor.constraint(equalToConstant: confirmButtonHeight)
        ])
        confirmButton.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        confirmButton.addGestureRecognizer(tapGesture)
        return bottomView
    }

    func setupIssuersTableView(aboveOf bottomView: UIView) {
        issuersTableView.translatesAutoresizingMaskIntoConstraints = false
        issuersTableView.backgroundColor = .white
        issuersTableView.delegate = self
        issuersTableView.dataSource = self
        issuersTableView.tableFooterView = UIView()
        issuersTableView.register(MLCardFormIssuerTableViewCell.self, forCellReuseIdentifier: MLCardFormIssuerTableViewCell.cellIdentifier)
        issuersTableView.register(MLCardFormTopViewCell.self, forCellReuseIdentifier: MLCardFormTopViewCell.cellIdentifier)
        issuersTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 22, right: 0)
        view.addSubview(issuersTableView)
        NSLayoutConstraint.activate([
            issuersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            issuersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            issuersTableView.topAnchor.constraint(equalTo: view.topAnchor),
            issuersTableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
        ])
    }

    func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = MLStyleSheetManager.styleSheet.secondaryColor
        let closeItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = closeItem
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    func setupShadowViews(aboveOf bottomView: UIView) {
        let topShadowView = UIImageView(image: UIImage(named: "gradient_top", in: Bundle(for: MLCardFormIssuersViewController.self), compatibleWith: nil))
        topShadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topShadowView)
        NSLayoutConstraint.activate([
            topShadowView.topAnchor.constraint(equalTo: view.topAnchor, constant: -1),
            topShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topShadowView.heightAnchor.constraint(equalToConstant: shadowViewHeight)
        ])
        let bottomShadowView = UIImageView(image: UIImage(named: "gradient_bottom", in: Bundle(for: MLCardFormIssuersViewController.self), compatibleWith: nil))
        bottomShadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomShadowView)
        NSLayoutConstraint.activate([
            bottomShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomShadowView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            bottomShadowView.heightAnchor.constraint(equalToConstant: shadowViewHeight)
        ])
    }

    @objc func close() {
        delegate?.userDidCancel(controller: self)
    }

    @objc func didTap() {
        if let selectedIssuer = selectedIssuer {
            delegate?.userDidSelectIssuer(issuer: selectedIssuer, controller: self)
        }
    }
}

// MARK: TableView delegates
extension MLCardFormIssuersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : issuersData?.count ?? 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let topCell = issuersTableView.dequeueReusableCell(withIdentifier: MLCardFormTopViewCell.cellIdentifier, for: indexPath) as? MLCardFormTopViewCell {
                topCell.setupCell()
                return topCell
            }
        } else {
            if let rowCell = issuersTableView.dequeueReusableCell(withIdentifier: MLCardFormIssuerTableViewCell.cellIdentifier, for: indexPath) as? MLCardFormIssuerTableViewCell, let currentIssuer = issuersData?[indexPath.row] {
                let radioButtonOn = selectedIssuer?.id == currentIssuer.id ? true : false
                rowCell.setupCell(with: currentIssuer.imageUrl, radioButtonOn: radioButtonOn)
                return rowCell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0,
            let currentIssuer = issuersData?[indexPath.row] {
            if let issuersCell = tableView.cellForRow(at: indexPath) as? MLCardFormIssuerTableViewCell {
                setOffAllRadioButtons()
                issuersCell.setupRadioButton(radioButtonOn: true)
                selectedIssuer = currentIssuer
            }
        }
    }
}

extension MLCardFormIssuersViewController {
    func setOffAllRadioButtons() {
        if let issuers = issuersData?.count {
            for issuer in 0...issuers-1 {
                let cell = issuersTableView.cellForRow(at: IndexPath(item: issuer, section: 1)) as? MLCardFormIssuerTableViewCell
                cell?.setupRadioButton(radioButtonOn: false)
            }
        }
    }
}
