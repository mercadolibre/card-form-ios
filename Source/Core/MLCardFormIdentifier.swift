//
//  MLCardFormIdentifier.swift
//  MLCardForm
//
//  Created by Eric Ertl on 03/12/2020.
//

import Foundation

struct MLCardFormIdentifier {
    private let meliName: String = "mercadolibre"
    private let mpName: String = "mercadopago"

    private func getAppName() -> String {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else { return "" }
        return appName.lowercased()
    }
}

// MARK: Public methods.
extension MLCardFormIdentifier {
    func isMeli() -> Bool {
        return getAppName().contains(meliName)
    }

    func isMp() -> Bool {
        return getAppName().contains(mpName)
    }
}
