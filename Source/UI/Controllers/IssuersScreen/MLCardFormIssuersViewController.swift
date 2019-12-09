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

    public init(viewModel: MLCardFormViewModel) {
        issuersData = viewModel.getIssuers()
        super.init(nibName: nil, bundle: nil)
        setupIssuersTableView()
        setupShadowViews()
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
    func setupIssuersTableView() {
        issuersTableView.translatesAutoresizingMaskIntoConstraints = false
        issuersTableView.backgroundColor = .white
        issuersTableView.delegate = self
        issuersTableView.dataSource = self
        issuersTableView.tableFooterView = UIView()
        issuersTableView.register(MLCardFormIssuerTableViewCell.self, forCellReuseIdentifier: MLCardFormIssuerTableViewCell.cellIdentifier)
        issuersTableView.register(MLCardFormTopViewCell.self, forCellReuseIdentifier: MLCardFormTopViewCell.cellIdentifier)
        view.addSubview(issuersTableView)
        NSLayoutConstraint.activate([
            issuersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            issuersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            issuersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            issuersTableView.topAnchor.constraint(equalTo: view.topAnchor)
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

    func setupShadowViews() {
        let topShadowView = UIImageView(image: UIImage(named: "gradient_top", in: Bundle(for: MLCardFormIssuersViewController.self), compatibleWith: nil))
        topShadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topShadowView)
        NSLayoutConstraint.activate([
            topShadowView.topAnchor.constraint(equalTo: view.topAnchor, constant: -1),
            topShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topShadowView.heightAnchor.constraint(equalToConstant: 40)
        ])
        let bottomShadowView = UIImageView(image: UIImage(named: "gradient_bottom", in: Bundle(for: MLCardFormIssuersViewController.self), compatibleWith: nil))
        bottomShadowView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomShadowView)
        NSLayoutConstraint.activate([
            bottomShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomShadowView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomShadowView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func close() {
        delegate?.userDidCancel(controller: self)
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
            if let rowCell = issuersTableView.dequeueReusableCell(withIdentifier: MLCardFormIssuerTableViewCell.cellIdentifier, for: indexPath) as? MLCardFormIssuerTableViewCell,
                let currentIssuer = issuersData?[indexPath.row] {
                rowCell.setupCell(with: currentIssuer.imageUrl)
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
            delegate?.userDidSelectIssuer(issuer: currentIssuer, controller: self)
        }
    }
}
