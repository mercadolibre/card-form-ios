//
//  MLCardFormLifeCycleDelegate.swift
//  MLCardForm
//
//  Created by Eric Ertl on 29/11/2019.
//

import Foundation

/**
 Implement this protocol in order to keep you informed about important actions in our card form life cycle.
 */
@objc public protocol MLCardFormLifeCycleDelegate: NSObjectProtocol {
    /**
     A new credit card has been added sucesfully.
     */
    @objc func didAddCard(cardID: String)
    
    /**
     A new credit card has been added sucesfully.
     Returns card information
     */
    @objc optional func didAddCardInformation(cardInformation: MLCardFormCardInformation)
    
    /**
     There was an error adding a new credit card.
     */
    @objc func didFailAddCard()
    
    /**
     Begin Edition of a cardFormField
     */
    @objc optional func didBeginEditing(cardFormField: String)
    
    /**
     End Edition of a cardFormField
     */
    @objc optional func didEndEditing(cardFormField: String)
}

extension MLCardFormLifeCycleDelegate {
    
    func didFailAddCard() {
        //this is a empty implementation to allow this method to be optional
    }
    
    func didBeginEditing(cardFormField: String) {
        
    }
    
    func didEndEditing(cardFormField: String) {
        
    }
}
