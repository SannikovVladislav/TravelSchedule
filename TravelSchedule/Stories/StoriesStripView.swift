//
//  StoriesStripView.swift
//  TravelSchedule
//
//  Created by Владислав on 25.01.2026.
//
import SwiftUI

struct StoriesStripView: View {
    @ObservedObject var viewModel: StoriesViewModel
    let onOpen: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                    Button(action: { onOpen(index) }) {
                        ZStack(alignment: .bottomLeading) {
                            Group {
                                if item.imageName.isEmpty {
                                    Color(.grayYP)
                                } else {
                                    Image(item.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .opacity(viewModel.isViewed(index) ? 0.5 : 1.0)
                                }
                            }
                            .frame(width: 92, height: 140)
                            .clipped()
                            
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.45)]),
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .frame(height: 40)
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            
                            Text(item.title)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .padding(.horizontal, 8)
                                .padding(.bottom, 8)
                        }
                        .frame(width: 92, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    viewModel.isViewed(index) ? Color.clear : Color(.blueYP),
                                    lineWidth: 3
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 12)
    }
}


