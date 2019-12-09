//
//  MLCardFormIssuerSelectedProtocol.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 02/12/2019.
//

import Foundation

protocol IssuerSelectedProtocol: NSObjectProtocol {
    func userDidSelectIssuer(issuer: MLCardFormIssuer, controller: UIViewController)
    func userDidCancel(controller: UIViewController)
}
