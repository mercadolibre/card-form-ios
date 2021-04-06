//
//  MLOtherTexts.swift
//  MLCardForm
//
//  Created by Matheus Leandro Martins on 06/04/21.
//

import Foundation

struct MLOtherTexts: Codable {
    let cardFormTitle: String
    
    enum CodingKeys: String, CodingKey {
        case cardFormTitle
    }
}
