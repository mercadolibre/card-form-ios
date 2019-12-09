//
//  MLCardFormStorageManager.swift
//  MLCardForm
//
//  Created by Juan sebastian Sanzone on 11/4/19.
//

import Foundation

struct MLCardFormStorageManager {
    static func getContext() -> UserDefaults {
        return UserDefaults.standard
    }
}

extension MLCardFormStorageManager {
    struct save {
        static func field(key: String, text: String) {
            let context = MLCardFormStorageManager.getContext()
            context.set(text, forKey: key)
            context.synchronize()
        }
    }
    
    struct get {
        static func field(key: String) -> String? {
            let context = MLCardFormStorageManager.getContext()
            if let str = context.object(forKey: key) as? String {
                return str
            }
            return nil
        }
    }
}
