//
//  CarrierCardView.swift
//  TravelSchedule
//
//  Created by Владислав on 11.01.2026.
//

import SwiftUI

struct CarrierCardView: View {
    let trip: TripInfo
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        CarrierLogoView(logoURLString: trip.carrier.logo, title: trip.carrier.title)
                            .frame(width: 38, height: 38)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.lightGrayYP))
                            )
                        
                        Text(trip.carrier.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(.blackYP))
                    }
                    
                    if let transferInfo = trip.transferInfo {
                        Text(transferInfo)
                            .font(.system(size: 12))
                            .foregroundColor(Color(.redYP))
                    }
                }
                
                Spacer()
                
                Text(trip.date)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(.blackYP))
            }
            .padding([.top, .horizontal], 20)
            
            HStack {
                Text(trip.departureTime)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(.blackYP))
                
                HStack {
                    Rectangle()
                        .fill(Color(.grayYP))
                        .frame(height: 1)
                    
                    Text(trip.duration)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.blackYP))
                        .padding(.horizontal, 8)
                    
                    Rectangle()
                        .fill(Color(.grayYP))
                        .frame(height: 1)
                }
                
                Text(trip.arrivalTime)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(.blackYP))
                
                if let transferInfo = trip.transferInfo {
                    Text(transferInfo)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(.redYP))
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(.lightGrayYP))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#if canImport(SwiftUI)
private struct CarrierLogoView: View {
    let logoURLString: String?
    let title: String
    
    var body: some View {
        Group {
            if let urlString = logoURLString?.replacingOccurrences(of: "http://", with: "https://"),
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(4)
                    case .failure:
                        monogram
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                monogram
            }
        }
    }
    
    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(.lightGrayYP))
    }
    
    private var monogram: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.lightGrayYP))
            Text(initials(from: title))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.blackYP))
        }
    }
    
    private func initials(from title: String) -> String {
        let parts = title.split(separator: " ")
        let first = parts.first?.first.map { String($0) } ?? ""
        let second = parts.dropFirst().first?.first.map { String($0) } ?? ""
        return (first + second).uppercased()
    }
}
#endif

#Preview {
    CarrierCardView(trip: TripInfo(
        carrier: CarrierInfo(
            title: "РЖД",
            logo: nil,
            code: 1,
            email: nil,
            phone: nil,
            url: nil,
            contacts: nil
        ),
        departureTime: "22:30",
        arrivalTime: "08:15",
        duration: "20 ч",
        date: "14 января",
        hasTransfers: true,
        transferInfo: "С пересадкой в Костроме",
        sortDate: Date()
    ))
    .padding()
    .background(Color(.whiteDayYP))
}
