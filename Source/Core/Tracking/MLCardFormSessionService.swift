//
//  MLCardFormSessionService.swift
//  MLCardForm
//
//  Created by Eric Ertl on 26/11/2019.
//

import Foundation

final class MLCardFormSessionService {
    
    static let SESSION_ID_KEY: String = "session_id"
    private var sessionId: String
    
    init(_ currentSessionId: String = MLCardFormSessionService.getUUID()) {
        sessionId = currentSessionId
    }
    
    func getSessionId() -> String {
        return sessionId
    }
    
    func getRequestId() -> String {
        return MLCardFormSessionService.getUUID()
    }
    
    func startNewSession() {
        sessionId = MLCardFormSessionService.getUUID()
    }
    
    func startNewSession(externalSessionId: String) {
        sessionId = externalSessionId
    }
}

// MARK: Private functions.
private extension MLCardFormSessionService {
    static func getUUID() -> String {
        return UUID().uuidString.lowercased()
    }
}
