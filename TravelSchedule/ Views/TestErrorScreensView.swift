//
//  TestErrorScreensView.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import SwiftUI

struct TestErrorScreensView: View {
    @State private var showServerError = false
    @State private var showNoInternet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Тест экранов ошибок")
                .font(.title)
                .padding()
            
            Button("Показать ошибку сервера") {
                showServerError = true
            }
            .buttonStyle(.borderedProminent)
            
            Button("Показать отсутствие интернета") {
                showNoInternet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView(onTabSelected: { _ in })
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NoInternetView(onTabSelected: { _ in })
        }
    }
}

#Preview {
    TestErrorScreensView()
}
