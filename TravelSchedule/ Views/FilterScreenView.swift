//
//  FilterScreenView.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import SwiftUI

struct FilterScreenView: View {
    @StateObject private var viewModel = FilterViewModel()
    let onBack: () -> Void
    let onApply: (FilterOptions) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Color(.whiteDayYP).frame(height: 12).ignoresSafeArea(edges: .top)
                
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(.blackDayYP))
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.top, 8)
                
            }
            .background(Color(.whiteDayYP))
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Время отправления")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.blackDayYP))
                        
                        VStack(spacing: 12) {
                            ForEach(TimeSlot.allCases, id: \.self) { timeSlot in
                                TimeSlotRow(
                                    timeSlot: timeSlot,
                                    isSelected: viewModel.timeSlots.contains(timeSlot)
                                ) {
                                    if viewModel.timeSlots.contains(timeSlot) {
                                        viewModel.timeSlots.remove(timeSlot)
                                    } else {
                                        viewModel.timeSlots.insert(timeSlot)
                                    }
                                    viewModel.updateSelection()
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Показывать варианты с пересадками")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(.blackDayYP))
                        
                        VStack(spacing: 12) {
                            ForEach(TransferOption.allCases, id: \.self) { option in
                                TransferOptionRow(
                                    option: option,
                                    isSelected: viewModel.showTransfers == option
                                ) {
                                    viewModel.showTransfers = (viewModel.showTransfers == option) ? nil : option
                                    viewModel.updateSelection()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            
            if viewModel.hasAnySelection {
                VStack {
                    Button(action: {
                        onApply(viewModel.getFilterOptions())
                    }) {
                        Text("Применить")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(Color(.whiteYP))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(Color(.blueYP))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .background(Color(.whiteDayYP))
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct TimeSlotRow: View {
    let timeSlot: TimeSlot
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(timeSlot.rawValue)
                    .font(.system(size: 17))
                    .foregroundColor(Color(.blackDayYP))
                
                Spacer()
                
                ZStack {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(.whiteDayYP))
                    }
                }
                .frame(width: 24, height: 24)
                .background(isSelected ? Color(.blackDayYP) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(.blackDayYP), lineWidth: 1)
                )
            }
            .padding(.vertical, 12)
        }
    }
}

struct TransferOptionRow: View {
    let option: TransferOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(option.rawValue)
                    .font(.system(size: 17))
                    .foregroundColor(Color(.blackDayYP))
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color(.blackDayYP), lineWidth: 1)
                        .frame(width: 20, height: 20)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(.blackDayYP))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    FilterScreenView(
        onBack: {},
        onApply: { _ in }
    )
}
