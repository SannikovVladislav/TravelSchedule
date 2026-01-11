//
//  SessionManager.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import Foundation
import SwiftUI
import Combine

class SessionManager: ObservableObject {
    @Published var fromCity: String? = nil
    @Published var fromStation: String? = nil
    @Published var toCity: String? = nil
    @Published var toStation: String? = nil
    
    func clearSession() {
        fromCity = nil
        fromStation = nil
        toCity = nil
        toStation = nil
    }
    
    func hasValidRoute() -> Bool {
        return fromCity != nil && fromStation != nil && toCity != nil && toStation != nil
    }
}
