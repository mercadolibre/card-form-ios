//
//  MLCardFormUserDataProtocol.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 08/11/2019.
//

import Foundation

protocol MLCardFormUserDataProtocol: NSObjectProtocol {
    func getName() -> String
    func getNumber() -> String
    func getSecurityCode() -> String
    func getExpiration() -> String
    func getIdentificationType() -> String?
    func getIdentificationTypeNumber() -> String?
}
