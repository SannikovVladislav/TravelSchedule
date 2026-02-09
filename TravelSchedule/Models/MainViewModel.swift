//
//  MainViewModel.swift
//  TravelSchedule
//
//  Created by Владислав on 07.02.2026.
//
import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published private(set) var didPrefetchDirectory: Bool = false

    func prefetchDirectory(
        apikey: String,
        onServerError: @escaping () -> Void,
        onNoInternet: @escaping () -> Void
    ) async {
        guard didPrefetchDirectory == false else { return }
        didPrefetchDirectory = true
        do {
            _ = try await ApiClient.shared.fetchAllCities(apikey: apikey)
        } catch {
            if error.localizedDescription.contains("network") ||
               error.localizedDescription.contains("internet") ||
               error.localizedDescription.contains("offline") {
                onNoInternet()
            } else {
                onServerError()
            }
        }
    }
}
