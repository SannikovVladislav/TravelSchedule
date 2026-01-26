//
//  UserAgreementView.swift
//  TravelSchedule
//
//  Created by Владислав on 21.01.2026.
//
import SwiftUI

struct UserAgreementView: View {
    let onBack: () -> Void
    @State private var isLoading = true
    @State private var didFail = false
    @State private var reloadId = UUID()
    private let agreementURL: URL
    
    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
        self.agreementURL = URL(string: "https://yandex.ru/legal/practicum_offer/ru/")!
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Color(.whiteDayYP).frame(height: 12).ignoresSafeArea(edges: .top)
                
                ZStack {
                    Text("Пользовательское соглашение")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(.blackDayYP))
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(.blackDayYP))
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 12)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(Color(.whiteDayYP))
            
            ZStack {
                WebView(url: agreementURL, isLoading: $isLoading, didFail: $didFail)
                    .id(reloadId)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(.blackDayYP))
                }
                
                if didFail {
                    VStack(spacing: 12) {
                        Text("Не удалось загрузить документ")
                            .font(.system(size: 15))
                            .foregroundColor(Color(.blackDayYP))
                        Button(action: { reloadId = UUID(); isLoading = true; didFail = false }) {
                            Text("Повторить")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color(.whiteDayYP))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color(.blueYP))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .background(Color(.whiteDayYP))
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    UserAgreementView(onBack: {})
}
