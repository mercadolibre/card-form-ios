//
//  MLCardFormIdentificationType.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 28/10/2019.
//

import Foundation

struct MLCardFormIdentificationType: Codable {
    let id: String
    let name: String
    let type: String
    let mask: String?
    let minLength: Int
    let maxLength: Int
}
