//
//  MLCardFormExtraValidation.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 28/04/2020.
//

import Foundation

struct MLCardFormExtraValidation: Codable {
    let name: String
    let values: [String]
    let errorMessage: String
}
