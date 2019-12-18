//
//  MLCardFormESCProtocol.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//

import Foundation

/**
 Use this protocol to implement ESC functionality
 */
/** :nodoc: */
@objc public protocol MLCardFormESCProtocol: NSObjectProtocol {
    @discardableResult func saveESC(config: MLCardFormESCConfig, firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool
}
