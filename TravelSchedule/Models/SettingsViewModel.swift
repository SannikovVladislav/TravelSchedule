//
//  SettingsViewModel.swift
//  TravelSchedule
//
//  Created by Владислав on 01.02.2026.
//
import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled = false
    
    func resetStoriesViewed() {
        NotificationCenter.default.post(name: Notification.Name("storiesViewedReset"), object: nil)
    }
}
