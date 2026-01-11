//
//  FilterViewModel.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//
import Foundation
import SwiftUI
import Combine

// MARK: - Модель для фильтров
struct FilterOptions {
    var timeSlots: Set<TimeSlot> = []
    var showTransfers: TransferOption?
}

enum TimeSlot: String, CaseIterable {
    case morning = "Утро 06:00 - 12:00"
    case day = "День 12:00 - 18:00"
    case evening = "Вечер 18:00 - 00:00"
    case night = "Ночь 00:00 - 06:00"
}

enum TransferOption: String, CaseIterable {
    case yes = "Да"
    case no = "Нет"
}

@MainActor
class FilterViewModel: ObservableObject {
    @Published var timeSlots: Set<TimeSlot> = []
    @Published var showTransfers: TransferOption?
    @Published var hasAnySelection: Bool = false
    
    func updateSelection() {
        hasAnySelection = !timeSlots.isEmpty || showTransfers != nil
    }
    
    func getFilterOptions() -> FilterOptions {
        return FilterOptions(
            timeSlots: timeSlots,
            showTransfers: showTransfers
        )
    }
    
    func applyFilters() {
        // TODO: Применить фильтры к результатам
    }
}

