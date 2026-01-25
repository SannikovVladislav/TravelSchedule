//
//  StoriesPlayerView.swift
//  TravelSchedule
//
//  Created by Владислав on 25.01.2026.
//
import SwiftUI
import Combine

struct StoriesPlayerView: View {
    @ObservedObject var viewModel: StoriesViewModel
    let startIndex: Int
    let onClose: () -> Void
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 0.05, on: .main, in: .common)
    @State private var cancellable: Cancellable?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                if let name = currentImageName, !name.isEmpty {
                    Image(name)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                } else {
                    Color(.grayYP).ignoresSafeArea()
                }
            }
            .overlay(overlayTexts, alignment: .bottom)
            
            VStack(spacing: 26) {
                StoriesProgressBar(numberOfSections: viewModel.items.count, progress: viewModel.progress)
                    .padding(.init(top: 28, leading: 12, bottom: 0, trailing: 12))
                    .frame(height: 6)
                HStack {
                    Spacer()
                    StoriesCloseButton(action: { onClose(); viewModel.stop() })
                }
                .padding(.trailing, 12)
            }
            .padding(.top, 0)
        }
        .onAppear {
            viewModel.start(from: startIndex)
            timer = Timer.publish(every: 0.05, on: .main, in: .common)
            cancellable = timer.connect()
        }
        .onDisappear { cancellable?.cancel() }
        .onReceive(timer) { _ in if viewModel.tick() { onClose(); viewModel.stop() } }
        .overlay(
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.advanceToPrevStory() }
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.advanceToNextStory() }
            }
            .padding(.top, 140)
            .ignoresSafeArea()
        )
    }
    
    private var currentImageName: String? { viewModel.items[viewModel.currentIndex].imageName }
    
    private var overlayTexts: some View {
        let item = viewModel.items[viewModel.currentIndex]
        return VStack(alignment: .leading, spacing: 10) {
            Text(item.title)
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            Text(item.description)
                .font(.system(size: 20))
                .lineLimit(3)
                .foregroundColor(.white)
        }
        .padding(.init(top: 0, leading: 16, bottom: 40, trailing: 16))
    }
}


