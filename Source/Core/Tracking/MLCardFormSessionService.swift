//
//  MLCardFormSessionService.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

final class MLCardFormSessionService {
    private var sessionId: String
    
    init(_ currentSessionId: String = MLCardFormSessionService.getUUID()) {
        sessionId = currentSessionId
    }
    
    func getSessionId() -> String {
        return sessionId
    }
    
    func startNewSession() {
        sessionId = MLCardFormSessionService.getUUID()
    }
}

// MARK: Private functions.
private extension MLCardFormSessionService {
    static func getUUID() -> String {
        return UUID().uuidString.lowercased()
    }
}
