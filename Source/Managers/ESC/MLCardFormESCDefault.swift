//
//  MLCardFormESCDefault.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//

import Foundation

/**
 Default PX implementation of ESC for public distribution.
 */
final class MLCardFormESCDefault: NSObject, MLCardFormESCProtocol {
    func saveESC(config: MLCardFormESCConfig, firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool {
        return false
    }
}
