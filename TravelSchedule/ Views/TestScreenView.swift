//
//  TestErrorScreensView.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import SwiftUI

struct TestScreenView: View {
    @State private var showServerError = false
    @State private var showNoInternet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Тест ошибок")
                .font(.title)
                .padding()
            
            Button("Ошибка сервера") {
                showServerError = true
            }
            .buttonStyle(.bordered)
            
            Button("Отсутствие интернета") {
                showNoInternet = true
            }
            .buttonStyle(.bordered)
        }
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView(onTabSelected: { _ in })
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NoInternetView(onTabSelected: { _ in })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("LightGrayYP"))
    }
    
}

#Preview {
    TestScreenView()
}
