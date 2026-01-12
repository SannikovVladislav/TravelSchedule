//
//  CarriersViewModel.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import Foundation
import SwiftUI
import OpenAPIURLSession
import Combine

struct TripInfo: Identifiable {
    let id = UUID()
    let carrier: CarrierInfo
    let departureTime: String
    let arrivalTime: String
    let duration: String
    let date: String
    let hasTransfers: Bool
    let transferInfo: String?
    let sortDate: Date
}

struct CarrierInfo {
    let title: String
    let logo: String?
    let code: Int?
}

@MainActor
class CarriersViewModel: ObservableObject {
    @Published var trips: [TripInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let searchService: SearchService
    private let apikey = "50889f83-e54c-4e2e-b9b9-7d5fe468a025"
    private var currentFilters: FilterOptions?
    private var onServerError: (() -> Void)?
    private var onNoInternet: (() -> Void)?
    
    init() {
        guard let serverURL = URL(string: "https://api.rasp.yandex.net") else {
            fatalError("Некорректный URL сервера")
        }
        let client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
        self.searchService = SearchService(client: client)
    }
    
    func setErrorCallbacks(onServerError: @escaping () -> Void, onNoInternet: @escaping () -> Void) {
        self.onServerError = onServerError
        self.onNoInternet = onNoInternet
    }
    
    func loadTrips(from: String, to: String, fromStation: String, toStation: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let transfers: Bool?
            if let filters = currentFilters, let showTransfers = filters.showTransfers {
                transfers = (showTransfers == .yes)
            } else {
                transfers = nil
            }
            
            let segments = try await searchService.getSegments(
                apikey: apikey,
                from: from,
                to: to,
                format: "json",
                lang: "ru_RU",
                transport_types: "train",
                limit: 1000,
                transfers: transfers
            )
            
            await processSegments(segments)
        } catch {
            if error.localizedDescription.contains("network") ||
               error.localizedDescription.contains("internet") ||
               error.localizedDescription.contains("offline") {
                onNoInternet?()
            } else {
                onServerError?()
            }
        }
        
        isLoading = false
    }
    
    func setFilters(_ filters: FilterOptions?) {
        currentFilters = filters
    }
    
    private func processSegments(_ segments: Segments) async {
        guard let segmentsArray = segments.segments else {
            errorMessage = "Рейсы не найдены"
            return
        }
        
        var allTrips: [TripInfo] = []
        
        let regularTrips = segmentsArray.compactMap { segment -> TripInfo? in
            return createTripInfo(from: segment, hasTransfers: false)
        }
        allTrips.append(contentsOf: regularTrips)
        
        if let intervalSegments = segments.interval_segments {
            let intervalTrips = intervalSegments.compactMap { intervalSegment -> TripInfo? in
                return createTripInfoFromInterval(intervalSegment)
            }
            allTrips.append(contentsOf: intervalTrips)
        }
        
        trips = allTrips
        
        if let filters = currentFilters {
            trips = applyFilters(trips, filters: filters)
        }
        
        trips = trips.sorted { trip1, trip2 in
            trip1.sortDate < trip2.sortDate
        }
    }
    
    private func formatTime(_ timeString: String) -> String {
        let parts = timeString.contains(" ") ? timeString.components(separatedBy: " ") : ["", timeString]
        let timeComponent = parts.last ?? timeString
        let timeParts = timeComponent.components(separatedBy: ":")
        guard timeParts.count >= 2 else { return timeComponent }
        return "\(timeParts[0]):\(timeParts[1])"
    }
    
    private func formatDuration(_ durationSeconds: Int) -> String {
        let hours = durationSeconds / 3600
        let word = pluralizeHours(hours)
        return "\(hours) \(word)"
    }

    private func pluralizeHours(_ value: Int) -> String {
        let v = value % 100
        if v >= 11 && v <= 14 { return "часов" }
        switch v % 10 {
        case 1: return "час"
        case 2,3,4: return "часа"
        default: return "часов"
        }
    }
    
    private func formatDate(_ timeString: String) -> String {
        let dateComponent: String
        
        if timeString.contains(" ") {
            dateComponent = timeString.components(separatedBy: " ").first ?? ""
        }
        else if timeString.contains("T") {
            dateComponent = timeString.components(separatedBy: "T").first ?? ""
        }
        else {
            let now = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: now)
            let month = calendar.component(.month, from: now)
            let monthName = getMonthName(month)
            return "\(day) \(monthName)"
        }
        
        let dateParts = dateComponent.components(separatedBy: "-")
        guard dateParts.count == 3,
              let day = Int(dateParts[2]),
              let month = Int(dateParts[1]) else {
            let now = Date()
            let calendar = Calendar.current
            let dayVal = calendar.component(.day, from: now)
            let monthVal = calendar.component(.month, from: now)
            let monthName = getMonthName(monthVal)
            return "\(dayVal) \(monthName)"
        }
        
        let monthName = getMonthName(month)
        return "\(day) \(monthName)"
    }
    
    private func getMonthName(_ month: Int) -> String {
        let months = ["", "января", "февраля", "марта", "апреля", "мая", "июня",
                     "июля", "августа", "сентября", "октября", "ноября", "декабря"]
        return months[safe: month] ?? ""
    }
    
    private func parseDate(_ timeString: String) -> Date {
        let formatter = ISO8601DateFormatter()
        
        if let date = formatter.date(from: timeString) {
            return date
        }
        
        let modifiedString = timeString.replacingOccurrences(of: " ", with: "T")
        if let date = formatter.date(from: modifiedString) {
            return date
        }
        
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        if let date = formatter.date(from: timeString) {
            return date
        }
        
        return Date()
    }
    
    private func applyFilters(_ trips: [TripInfo], filters: FilterOptions) -> [TripInfo] {
        var filteredTrips = trips
        
        if !filters.timeSlots.isEmpty {
            filteredTrips = filteredTrips.filter { trip in
                let hour = getHourFromTime(trip.departureTime)
                return filters.timeSlots.contains { timeSlot in
                    switch timeSlot {
                    case .morning: return hour >= 6 && hour < 12
                    case .day: return hour >= 12 && hour < 18
                    case .evening: return hour >= 18 && hour < 24
                    case .night: return hour >= 0 && hour < 6
                    }
                }
            }
        }
        
        
        return filteredTrips
    }
    
    private func getHourFromTime(_ timeString: String) -> Int {
        let components = timeString.components(separatedBy: ":")
        guard components.count >= 2,
              let hour = Int(components[0]) else {
            return 0
        }
        return hour
    }
    
    private func createTripInfo(from segment: Components.Schemas.Segment, hasTransfers: Bool) -> TripInfo? {
        guard let departure = segment.departure,
              let arrival = segment.arrival,
              let duration = segment.duration,
              let thread = segment.thread,
              let carrier = thread.carrier else {
            return nil
        }
        
        let departureTime = formatTime(departure)
        let arrivalTime = formatTime(arrival)
        let durationText = formatDuration(duration)
        
        let carrierTitle = (carrier.title ?? "Неизвестный перевозчик").components(separatedBy: "/").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? (carrier.title ?? "Неизвестный перевозчик")
        
        let carrierInfo = CarrierInfo(
            title: carrierTitle,
            logo: carrier.logo,
            code: carrier.code
        )
        
        let date = formatDate(departure)
        let sortDate = parseDate(departure)
        
        let transferInfo = hasTransfers ? "С пересадками" : nil
        
        return TripInfo(
            carrier: carrierInfo,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            duration: durationText,
            date: date,
            hasTransfers: hasTransfers,
            transferInfo: transferInfo,
            sortDate: sortDate
        )
    }
    
    private func createTripInfoFromInterval(_ intervalSegment: Components.Schemas.Segments.interval_segmentsPayloadPayload) -> TripInfo? {
        guard let departure = intervalSegment.from?.title, // Используем from как departure
              let arrival = intervalSegment.to?.title, // Используем to как arrival
              let duration = intervalSegment.duration,
              let thread = intervalSegment.thread,
              let carrier = thread.carrier else {
            return nil
        }
        
        let departureTime = formatTime(departure)
        let arrivalTime = formatTime(arrival)
        let durationText = formatDuration(duration)
        
        let carrierTitle = (carrier.title ?? "Неизвестный перевозчик").components(separatedBy: "/").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? (carrier.title ?? "Неизвестный перевозчик")
        
        let carrierInfo = CarrierInfo(
            title: carrierTitle,
            logo: carrier.logo,
            code: carrier.code
        )
        
        let hasTransfers = intervalSegment.has_transfers ?? false
        let transferInfo = hasTransfers ? "С пересадками" : nil
        
        let now = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: now)
        let month = calendar.component(.month, from: now)
        let monthName = getMonthName(month)
        let date = "\(day) \(monthName)"
        
        return TripInfo(
            carrier: carrierInfo,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            duration: durationText,
            date: date,
            hasTransfers: hasTransfers,
            transferInfo: transferInfo,
            sortDate: now
        )
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
