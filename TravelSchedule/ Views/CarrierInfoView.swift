//
//  InfoCarrier.swift
//  TravelSchedule
//
//  Created by Владислав on 05.01.2026.
//

import SwiftUI

struct CarrierInfoView: View {
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Color(.whiteDayYP).frame(height: 12)
                    .ignoresSafeArea(edges: .top)
                
                ZStack {
                    Text("Информация о перевозчике")
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
            
            Spacer()
        }
        .background(Color(.whiteDayYP))
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    CarrierInfoView(onBack: {})
}
