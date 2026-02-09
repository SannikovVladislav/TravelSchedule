//
//  SettingsScreenView.swift
//  TravelSchedule
//
//  Created by Владислав on 05.01.2026.
//
import SwiftUI

struct SettingsScreenView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showUserAgreement = false
    @AppStorage("storiesViewedIndices") private var storiesViewedIndices = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Темная тема")
                        .font(.system(size: 17))
                        .foregroundColor(Color(.blackDayYP))
                    Spacer()
                    Toggle("", isOn: $viewModel.isDarkModeEnabled)
                        .labelsHidden()
                        .tint(Color(.blueYP))
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                
                Button(action: { showUserAgreement = true }) {
                    HStack(spacing: 12) {
                        Text("Пользовательское соглашение")
                            .font(.system(size: 17))
                            .foregroundColor(Color(.blackDayYP))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(.blackDayYP))
                    }
                    .contentShape(Rectangle())
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
            }
            .background(Color(.whiteDayYP))
            .padding(.top, 8)
            
            Spacer()
            
            VStack(spacing: 6) {
                
                Text("Приложение использует API «Яндекс.Расписания»")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.grayYP))
                Text("Версия 1.0 (beta)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.grayYP))
            }
            .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.whiteDayYP))
        .fullScreenCover(isPresented: $showUserAgreement) {
            UserAgreementView(onBack: { showUserAgreement = false })
        }
    }
}

#Preview {
    SettingsScreenView()
}
