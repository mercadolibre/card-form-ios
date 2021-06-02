//
//  MLCardFormCardInformation.swift
//  Pods
//
//  Created by Romina Pamela Cortazzo on 2/6/21.
//

import Foundation

@objc public class MLCardFormCardInformation: NSObject {
    
    var cardId: String = ""
    var paymentType: String = ""
    var bin: String = ""
    
    init(cardId: String, paymentType: String, bin:String){
        self.cardId = cardId
        self.paymentType = paymentType
        self.bin = bin
    }
    
    override init() {}
    
    public func getCardId() -> String {
        return cardId
    }
    
    public func getBin() -> String {
        return bin
    }
    
    public func getPaymentType() -> String {
        return paymentType
    }
}
