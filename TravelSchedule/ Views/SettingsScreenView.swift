//
//  SettingsScreenView.swift
//  TravelSchedule
//
//  Created by Владислав on 05.01.2026.
//

import SwiftUI

struct SettingsScreenView: View {
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Настройки")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color("BlackDayYP"))
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("WhiteDayYP"))
    }
}

#Preview {
    SettingsScreenView()
}
