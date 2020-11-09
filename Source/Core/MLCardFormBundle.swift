//
//  MLCardFormBundle.swift
//  MLCardForm
//
//  Created by Eric Ertl on 06/11/2020.
//

import Foundation

internal class MLCardFormBundle {
    static func bundle() -> Bundle {
        let bundle = Bundle(for: MLCardFormBundle.self)
        if let path = bundle.path(forResource: "MLCardFormResources", ofType: "bundle"),
            let resourcesBundle = Bundle(path: path) {
            return resourcesBundle
        }
        return bundle
    }
}
