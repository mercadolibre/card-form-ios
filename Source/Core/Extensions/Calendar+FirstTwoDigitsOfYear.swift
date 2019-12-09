//
//  Calendar+FirstTwoDigitsOfYear.swift
//  MLCardForm
//
//  Created by Esteban Adrian Boffa on 21/11/2019.
//

import Foundation

internal extension Calendar {
    func firstTwoDigitsOfYear() -> String {
        let date = Date()
        let year = self.component(.year, from: date)
        return String(year/100)
    }
    
    func dateFromExpiration(_ value: String?) -> Date? {
        guard let value = value, value.count == 5 else { return nil }
        
        var fixedValue = value
        let firstTwoDigits = Calendar.current.firstTwoDigitsOfYear()
        fixedValue.insert(contentsOf: firstTwoDigits, at: fixedValue.index(fixedValue.startIndex, offsetBy: 3))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/yyyy"
        return dateFormatter.date(from: fixedValue)
    }
}
