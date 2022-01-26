//
//  MLCardFormGAModel.swift
//  MLCardForm
//
//  Created by Yxzandra Carolina Cordero Giron on 25-01-22.
//

import Foundation

@objc public class MLCardFormGAModel: NSObject {
    public var action: String? = nil
    public var screen: String? = nil
    public var category: String = ""
    public var label: String? = nil
    public var value: String? = nil
    public var customDimensions: [String: Any] = [:]
}
