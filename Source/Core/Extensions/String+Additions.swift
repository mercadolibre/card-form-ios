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
    
    /// Remove characters from given set from the string. Looks for characters
    /// from set in the whole string, not only its beginning and end.
    ///
    /// - Parameter set: Character set, with characters we want to remove
    /// - Returns: New String with characters from given set removed
    func removingCharactersInSet(_ set: CharacterSet) -> String {
        let stringParts = self.components(separatedBy: set)
        let notEmptyStringParts = stringParts.filter { text in
            text.isEmpty == false
        }
        let result = notEmptyStringParts.joined(separator: "")
        return result
    }
    
    
    /// Remove whitespace and newlines characters from the string. Looks for
    /// characters from set in the whole string, not only its beginning and end.
    ///
    /// - Returns: New String with whitespace and newline characters removed
    func removingWhitespaceAndNewlines() -> String {
        return self.removingCharactersInSet(CharacterSet.whitespacesAndNewlines)
    }
}
