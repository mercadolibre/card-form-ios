//
//  MLCardFormESCDefault.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//  Refactor by bgarelli, 10/25/2022

import MLESCManager

/// Default PX implementation of ESC for public distribution.
struct MLCardFormESCDefault: MLCardFormESCProtocol {
    func saveESC(using config: MLCardFormESCConfig, with cardInfo: CardInfo) -> Bool {
        guard config.enabled else {
            return false
        }
        let escManager = MLESCManager(sessionId: config.getSessionId())
        escManager.setFlow(flow: config.getFlowId())
        let (esc, firstFour, lastSix) = cardInfo
        return escManager.saveESC(esc: esc, firstSixDigits: firstFour, lastFourDigits: lastSix)
    }
}
