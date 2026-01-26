//
//  StoriesComponents.swift
//  TravelSchedule
//
//  Created by Владислав on 25.01.2026.
//
import SwiftUI

struct StoriesCloseButton: View {
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(colorScheme == .light ? Color(.blackDayYP) : Color(.whiteDayYP))
                    .frame(width: 32, height: 32)
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(colorScheme == .light ? Color(.whiteDayYP) : Color(.blackDayYP))
            }
            .shadow(radius: 3)
        }
        .padding(10)
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
}

extension CGFloat {
    static let storiesProgressCornerRadius: CGFloat = 6
    static let storiesProgressHeight: CGFloat = 6
}

struct StoriesProgressBar: View {
    let numberOfSections: Int
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .storiesProgressCornerRadius)
                    .frame(width: geometry.size.width, height: .storiesProgressHeight)
                    .foregroundColor(.white)
                    .opacity(0.25)
                
                RoundedRectangle(cornerRadius: .storiesProgressCornerRadius)
                    .frame(
                        width: min(progress * geometry.size.width, geometry.size.width),
                        height: .storiesProgressHeight
                    )
                    .foregroundColor(Color(.blueYP))
            }
            .mask {
                HStack(spacing: 4) {
                    ForEach(0..<numberOfSections, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: .storiesProgressCornerRadius)
                            .frame(height: .storiesProgressHeight)
                    }
                }
            }
        }
    }
}
