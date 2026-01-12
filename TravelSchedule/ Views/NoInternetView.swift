//
//  NoInternetView.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import SwiftUI

struct NoInternetView: View {
    let onTabSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Spacer()
                
                Image(.noInternet)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 223, height: 223)
                
                Text("Нет интернета")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.blackDayYP))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.whiteDayYP))
            
            VStack(spacing: 0) {
                Divider()
                    .background(Color(.grayYP))
                
                HStack {
                    Button(action: {
                        onTabSelected(0)
                    }) {
                        VStack(spacing: 4) {
                            Image(.schedule)
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(.blackDayYP))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        onTabSelected(1)
                    }) {
                        VStack(spacing: 4) {
                            Image(.settings)
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(.grayYP))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .background(Color(.whiteDayYP))
            }
        }
        .background(Color(.whiteDayYP))
    }
}

#Preview {
    NoInternetView(onTabSelected: { _ in })
}
