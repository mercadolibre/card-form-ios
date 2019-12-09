//
//  String+Additions.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 21/11/2019.
//

import Foundation

internal extension String {

    static func isNullOrEmpty(_ value: String?) -> Bool {
        guard let value = value else { return true }
        return value.isEmpty
    }
}
