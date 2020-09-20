//
//  YouTubeProvider.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import Combine
import WidgetKit

class YouTubeProvider: IntentTimelineProvider {
    private let service = YouTubeService()
    private var cachedItems = [VideoItem](repeating: .empty, count: 5)
    private var bag = Set<AnyCancellable>()

    init() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            switch result {
            case .success(let infos):
                print("Widget Config family \(infos.map { $0.family })")
            case .failure(let error):
                print("Widget Config error: \(error)")
            }
        }
    }

    func placeholder(in context: Context) -> YouTubeEntry {
        YouTubeEntry(date: Date(), configuration: ConfigurationIntent(), items: cachedItems)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (YouTubeEntry) -> ()) {
        let entry = YouTubeEntry(date: Date(), configuration: configuration, items: cachedItems)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<YouTubeEntry>) -> ()) {
        guard context.family == .systemSmall || context.family == .systemMedium || context.family == .systemLarge else {
            completion(Timeline(entries: [], policy: .never))
            return
        }
        var entries: [YouTubeEntry] = []
        service
            .getAssortment()
            .sink { [weak self] completed in
                if case .failure(let error) = completed {
                    print("Error: \(error)")
                    let cachedItems: [VideoItem] = self?.cachedItems ?? []
                    let videoItems: [VideoItem] = cachedItems.isEmpty ? .init(repeating: .empty, count: 5) : cachedItems
                    let entry = YouTubeEntry(date: Date(), configuration: configuration, items: videoItems, error: error)
                    entries.append(entry)
                }
//                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
                let timeline = Timeline(
                    entries: entries,
                    policy: .atEnd
                )
                completion(timeline)
                print("completed")
            } receiveValue: { [weak self] response in

                let filtered = self?.sortedResponse(response, configuration: configuration) ?? []
                self?.cachedItems = response
                let entry = YouTubeEntry(date: Date(), configuration: configuration, items: filtered)
                entries.append(entry)
            }
            .store(in: &bag)
    }

    private func sortedResponse(_ response: [VideoItem], configuration: ConfigurationIntent) -> [VideoItem] {
        guard let configSubscriptions = configuration.subscriptions else {
            return response
        }
        var matching = [VideoItem]()
        var nonMatching = [VideoItem]()

        for item in response {
            if configSubscriptions.first(where: { $0.identifier == item.channelId }) != nil {
                matching.append(item)
            } else {
                nonMatching.append(item)
            }
        }
        return matching + nonMatching
    }
}
