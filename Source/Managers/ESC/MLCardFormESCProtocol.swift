//
//  MLCardFormESCProtocol.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/12/2019.
//  Refactor by bgarelli, 10/25/2022

public typealias CardInfo = (firstSixDigits: String, lastFourDigits: String, esc: String)

/// ESC functionality contract
public protocol MLCardFormESCProtocol {
    @discardableResult func saveESC(using config: MLCardFormESCConfig, with cardInfo: CardInfo) -> Bool
}
