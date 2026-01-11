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
                
                Image("NoInternet")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 223, height: 223)
                
                Text("Нет интернета")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color("BlackDayYP"))
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("WhiteDayYP"))
            
            VStack(spacing: 0) {
                Divider()
                    .background(Color("GrayYP"))
                
                HStack {
                    Button(action: {
                        onTabSelected(0)
                    }) {
                        VStack(spacing: 4) {
                            Image("Schedule")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("BlackDayYP"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        onTabSelected(1)
                    }) {
                        VStack(spacing: 4) {
                            Image("Settings")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color("GrayYP"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 8)
                .background(Color("WhiteDayYP"))
            }
        }
        .background(Color("WhiteDayYP"))
    }
}

#Preview {
    NoInternetView(onTabSelected: { _ in })
}
