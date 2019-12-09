//
//  MLCardFormLocalizatorManager.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 12/3/19.
//

import Foundation

class MLCardFormLocalizatorManager {
    static let shared = MLCardFormLocalizatorManager()
    private var language: String = "es-AR"
}

// MARK: Getters/ Setters
extension MLCardFormLocalizatorManager {
    func setLanguage(_ language: String) {
        self.language = language
    }

    func getLanguage() -> String {
        return language
    }
}

// MARK: Privates
private extension MLCardFormLocalizatorManager {
    func getCustomLanguagePath() -> String? {
        let typeExtension: String = "lproj"
        let bundle = Bundle(for: MLCardFormLocalizatorManager.self)
        let currentLanguage = getLanguage()
        if let path = bundle.path(forResource: currentLanguage, ofType: typeExtension) {
              return path
        } else if let language = currentLanguage.components(separatedBy: "-").first, let path = bundle.path(forResource: language, ofType: typeExtension) {
              return path
        }
        return nil
    }
}

// MARK: Localizator extension.
internal extension String {
    var localized: String {
        guard let customLanguagePath = MLCardFormLocalizatorManager.shared.getCustomLanguagePath() else {
            return noLocalizedDefault
        }
        if let languageBundle = Bundle(path: customLanguagePath) {
            return languageBundle.localizedString(forKey: self, value: "", table: nil)
        }
        return noLocalizedDefault
    }

    var noLocalizedDefault: String {
        #if DEBUG
            return "(**\(self)**)"
        #else
            return self
        #endif
    }
}
