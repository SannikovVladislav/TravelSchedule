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
            
            Text("Темная тема")
                .font(.system(size: 17))
                .foregroundColor(Color(.blackDayYP))
            Toggle("", isOn: .constant(false))
                .labelsHidden()
                .tint(Color(.blueYP))
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.whiteDayYP))
    }
}

#Preview {
    SettingsScreenView()
}
