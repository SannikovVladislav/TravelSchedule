//
//  StoriesViewModel.swift
//  TravelSchedule
//
//  Created by Владислав on 25.01.2026.
//
@preconcurrency import SwiftUI
import Combine

struct StoryItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

@MainActor
final class StoriesViewModel: ObservableObject {
    @Published private(set) var items: [StoryItem] = []
    @Published var progress: CGFloat = 0
    @Published var isPlaying: Bool = false
    @Published private(set) var viewedIndices: Set<Int> = []
    @AppStorage("storiesViewedIndices") private var viewedStorage: String = ""
    
    private var timer: Timer.TimerPublisher = Timer.publish(every: 0.05, on: .main, in: .common)
    private var cancellable: Cancellable?
    private let tickInterval: TimeInterval = 0.05
    private var lastIndex: Int = 0
    private var elapsedInCurrentStory: TimeInterval = 0
    private var resetObserver: NSObjectProtocol?
    
    private let secondsPerStory: TimeInterval = 5
    
    init() {
        items = [
            StoryItem(imageName: "story1", title: "Первая история", description: "Красивая девушка"),
            StoryItem(imageName: "story2", title: "Вторая история", description: "Еще красивая девушка"),
            StoryItem(imageName: "story3", title: "Третья история", description: "Компания приятных людей"),
            StoryItem(imageName: "", title: "Четвертая история", description: "Обещаем Вам, что здесь что-нибудь появится, но позже"),
            StoryItem(imageName: "", title: "Пятая история", description: "Обещаем Вам, что здесь что-нибудь появится, но позже"),
        ]
        loadViewedFromStorage()
        lastIndex = 0
        elapsedInCurrentStory = 0

        resetObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("storiesViewedReset"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.viewedIndices.removeAll()
                self.saveViewedToStorage()
            }
        }
    }
    
    func start(from index: Int) {
        let count = max(1, items.count)
        progress = CGFloat(index) / CGFloat(count)
        play()
        lastIndex = index
        elapsedInCurrentStory = 0
    }
    
    func play() {
        guard !isPlaying else { return }
        isPlaying = true
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
        cancellable = timer.connect()
    }
    
    func pause() {
        isPlaying = false
        cancellable?.cancel()
    }
    
    func stop() {
        pause()
        progress = 0
    }
    
    func tick() -> Bool {
        guard isPlaying else { return false }
        let perTick = 1.0 / CGFloat(items.count) / CGFloat(secondsPerStory / tickInterval)
        let idxBefore = currentIndex

        if currentIndex == lastIndex {
            elapsedInCurrentStory += tickInterval
        } else {
            lastIndex = currentIndex
            elapsedInCurrentStory = 0
        }
        if elapsedInCurrentStory >= 0.5 && !viewedIndices.contains(currentIndex) {
            viewedIndices.insert(currentIndex)
            saveViewedToStorage()
        }

        var next = progress + perTick
        let boundary = (CGFloat(idxBefore) + 1.0) / CGFloat(items.count)
        if next >= boundary {
            if idxBefore >= items.count - 1 {
                isPlaying = false
                progress = 1
                return true
            }
            next = boundary
            lastIndex = idxBefore + 1
            elapsedInCurrentStory = 0
        }
        progress = next
        return false
    }
    
    func advanceToNextStory() {
        let count = max(1, items.count)
        let idx = currentIndex
        if idx >= count - 1 {
            progress = 1
        } else {
            progress = CGFloat(idx + 1) / CGFloat(count)
        }
        lastIndex = currentIndex
        elapsedInCurrentStory = 0
    }

    func advanceToPrevStory() {
        let count = max(1, items.count)
        let idx = currentIndex
        if idx <= 0 {
            progress = 0
        } else {
            progress = CGFloat(idx - 1) / CGFloat(count)
        }
        lastIndex = currentIndex
        elapsedInCurrentStory = 0
    }

    func isViewed(_ index: Int) -> Bool { viewedIndices.contains(index) }
    
    private func loadViewedFromStorage() {
        let parts = viewedStorage.split(separator: ",").compactMap { Int($0) }
        viewedIndices = Set(parts)
    }
    
    private func saveViewedToStorage() {
        viewedStorage = viewedIndices.sorted().map(String.init).joined(separator: ",")
    }
    
    var currentIndex: Int {
        let idx = Int(progress * CGFloat(items.count))
        return min(max(0, idx), max(0, items.count - 1))
    }

    deinit {
        if let resetObserver { NotificationCenter.default.removeObserver(resetObserver) }
    }
}
