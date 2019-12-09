//
//  MLCardFormAddCardData.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 15/11/2019.
//

import Foundation

struct MLCardFormAddCardData: Codable {
    private let id: String
    private let userId: Int
    private let status: String
    private let siteId: String
    private let expirationMonth: Int
    private let expirationYear: Int
    private let paymentMethod: MLCardFormAddCardPaymentMethod
    private let dateCreated: String
    private let dateLastUpdated: String
    private let dateLastTimeUsed: String
    private let markedAsValidCard: Bool
    private let issuer: MLCardFormAddCardIssuer
    
    func getId() -> String {
        return id
    }
}
