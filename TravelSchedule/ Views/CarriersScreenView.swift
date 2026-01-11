//
//  CarriersScreenView.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import SwiftUI

struct CarriersScreenView: View {
    let fromCity: String
    let fromStation: String
    let toCity: String
    let toStation: String
    let onBack: () -> Void
    let onServerError: (() -> Void)?
    let onNoInternet: (() -> Void)?
    
    @StateObject private var viewModel = CarriersViewModel()
    @State private var showFilter = false
    @State private var currentFilters: FilterOptions?
    @State private var showCarrierInfo = false
    @State private var showServerError = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Color("WhiteDayYP").frame(height: 12).ignoresSafeArea(edges: .top)
                
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("BlackDayYP"))
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.top, 8)
                
                HStack(alignment: .center, spacing: 8) {
                    Text("\(fromCity) (\(fromStation))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("BlackDayYP"))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("GrayYP"))
                    Text("\(toCity) (\(toStation))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("BlackDayYP"))
                }
                .padding(.bottom, 16)
            }
            .background(Color("WhiteDayYP"))
            
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("BlueYP")))
                        .scaleEffect(1.5)
                    
                    Text("Загрузка рейсов...")
                        .font(.system(size: 17))
                        .foregroundColor(Color("GrayYP"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WhiteDayYP"))
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(Color("RedYP"))
                    
                    Text("Ошибка")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("BlackDayYP"))
                    
                    Text(errorMessage)
                        .font(.system(size: 16))
                        .foregroundColor(Color("GrayYP"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button("Попробовать снова") {
                        Task {
                            await loadTrips()
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("BlueYP"))
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("WhiteDayYP"))
            } else if viewModel.trips.isEmpty {
                ZStack(alignment: .bottom) {
                    VStack {
                        Spacer()
                        Text("Вариантов нет")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("BlackDayYP"))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("WhiteDayYP"))
                    
                    VStack {
                        Button(action: { showFilter = true }) {
                            Text("Уточнить время")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color("WhiteYP"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color("BlueYP"))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            } else {
                ZStack(alignment: .bottom) {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.trips) { trip in
                                CarrierCardView(trip: trip)
                                    .onTapGesture {
                                        showCarrierInfo = true
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                    .background(Color("WhiteDayYP"))
                    
                    VStack {
                        Button(action: {
                            showFilter = true
                        }) {
                            Text("Уточнить время")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color("WhiteYP"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color("BlueYP"))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
                .background(Color("WhiteDayYP"))
            }
        }
        .navigationDestination(isPresented: $showFilter) {
            FilterScreenView(
                onBack: { showFilter = false },
                onApply: { filters in
                    currentFilters = filters
                    viewModel.setFilters(filters)
                    showFilter = false
                    Task { await loadTrips() }
                }
            )
        }
        .navigationDestination(isPresented: $showCarrierInfo) {
            CarrierInfoView(onBack: { showCarrierInfo = false })
        }
        .onAppear {
            viewModel.setErrorCallbacks(
                onServerError: {
                    showServerError = true
                },
                onNoInternet: {
                    onNoInternet?()
                }
            )
            
            Task { await loadTrips() }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView(onTabSelected: { _ in })
        }
        .background(Color("WhiteDayYP"))
    }
    
    private func loadTrips() async {
        do {
            let directoryService = DirectoryService(apikey: Constants.apiKey)
            
            let fromStations = try await directoryService.fetchStations(inCityTitle: fromCity)
            let toStations = try await directoryService.fetchStations(inCityTitle: toCity)
            
            let fromCode = fromStations.first { $0.title == fromStation }?.yandexCode
            let toCode = toStations.first { $0.title == toStation }?.yandexCode
            
            guard let fromCode = fromCode, let toCode = toCode else {
                await MainActor.run {
                    viewModel.errorMessage = "Не удалось найти коды станций"
                }
                return
            }
            await viewModel.loadTrips(
                from: fromCode,
                to: toCode,
                fromStation: fromStation,
                toStation: toStation
            )
        } catch {
            
            await MainActor.run {
                if error.localizedDescription.contains("network") ||
                    error.localizedDescription.contains("internet") ||
                    error.localizedDescription.contains("offline") {
                    onNoInternet?()
                } else {
                    viewModel.errorMessage = "Ошибка сервера"
                }
            }
        }
    }
}

#Preview {
    CarriersScreenView(
        fromCity: "Москва",
        fromStation: "Ярославский вокзал",
        toCity: "Санкт-Петербург",
        toStation: "Балтийский вокзал",
        onBack: {},
        onServerError: nil,
        onNoInternet: nil
    )
}
