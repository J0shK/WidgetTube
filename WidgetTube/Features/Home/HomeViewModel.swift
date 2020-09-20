//
//  HomeViewModel.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/22/20.
//

import Combine
import Foundation

class HomeViewModel {
    let itemsUpdated = CurrentValueSubject<[MappedVideo], Never>([])
    let error = PassthroughSubject<Error, Never>()
    private var nextPageToken: String?
    private var isLoading = false
    private var isRefreshing = false
    private var bag = Set<AnyCancellable>()

    var items: [MappedVideo] {
        return itemsUpdated.value
    }

    init() {
        let metadata = try? Current.store.metadataStore.load()
        if let nextPageToken = metadata?[.home]?.nextPageToken {
            self.nextPageToken = nextPageToken
        }

        if let lastUpdate = metadata?[.home]?.lastUpdate {
            let timeSince = Date().timeIntervalSince(lastUpdate)
            print("\(timeSince) since last Home update")
            if timeSince < 3600 {
                let mappedVideos: [MappedVideo] = (try? Current.store.load(key: .home)) ?? []
                if !mappedVideos.isEmpty {
                    itemsUpdated.send(mappedVideos)
                    return
                }
            }
        }else{
            print("No update date found")
        }

        getAssortment(firstLoad: true)
    }

    func refresh() {
        bag = Set<AnyCancellable>()
        isLoading = false
        isRefreshing = true
        nextPageToken = nil
        getAssortment()
    }

    func getAssortment(firstLoad: Bool = false) {
        guard !isLoading, nextPageToken != nil || firstLoad || isRefreshing else { return }
        isLoading = true
        getSubscriptions()
            .flatMap(mapChannel)
            .flatMap(mapPlaylistItem)
            .flatMap(mapVideo)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error.send(error)
                    print("Error fetching home subscriptions: \(error)")
                case .finished:
                    break
                }
                self?.isLoading = false
                self?.isRefreshing = false
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                let existing = self.isRefreshing ? [] : self.itemsUpdated.value
                let combined = existing + response
                self.itemsUpdated.send(combined)
                do {
                    try Current.store.save(combined, key: .home, nextPageToken: self.nextPageToken)
                } catch {
                    print("Save error: \(error)")
                }
            }
            .store(in: &bag)
    }

    private func getSubscriptions() -> AnyPublisher<[Subscription], Error> {
        return Current
            .api
            .request(YouTubeRequest.subscriptions(nextPageToken: nextPageToken))
            .decodeJSON(type: SubscriptionResponse.self)
            .map { [weak self] response in
                self?.nextPageToken = response.nextPageToken
                return response.items
            }
            .eraseToAnyPublisher()
    }

    private func mapChannel(to subscriptions: [Subscription]) -> AnyPublisher<[MappedVideo], Error> {
        return Current
            .api
            .request(YouTubeRequest.channel(channelIds: subscriptions.map { $0.snippet.resourceId.channelId } ))
            .decodeJSON(type: ChannelResponse.self)
            .map { response in
                subscriptions.map { subscription in
                    MappedVideo(subscription: subscription, channel: response.items.first { $0.id == subscription.snippet.resourceId.channelId }) }
            }
            .eraseToAnyPublisher()
    }

    private func mapPlaylistItem(for mappedVideo: MappedVideo) -> AnyPublisher<MappedVideo, Error> {
        return Current
            .api
            .request(YouTubeRequest.playlistItems(playlistId: mappedVideo.channel?.contentDetails.relatedPlaylists.uploads ?? "", nextPageToken: nil))
            .decodeJSON(type: PlaylistItemResponse.self)
            .map { MappedVideo(subscription: mappedVideo.subscription, channel: mappedVideo.channel, item: $0.items.first) }
            .eraseToAnyPublisher()
    }

    private func mapPlaylistItem(for mappedVideos: [MappedVideo]) -> AnyPublisher<[MappedVideo], Error> {
        let array = mappedVideos.map(mapPlaylistItem)
        let initial = Just<[MappedVideo]>([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let zipped = array.reduce(into: initial) { result, upstream in
            result = result.zip(upstream) { elements, element in
                elements + [element]
            }
            .eraseToAnyPublisher()
        }

        return zipped.eraseToAnyPublisher()
    }

    private func mapVideo(for mappedVideos: [MappedVideo]) -> AnyPublisher<[MappedVideo], Error> {
        return Current
            .api
            .request(YouTubeRequest.video(videoIds: mappedVideos.compactMap { $0.item?.contentDetails.videoId } ))
            .decodeJSON(type: VideoResponse.self)
            .map { response in
                mappedVideos.map { mappedVideo in
                    MappedVideo(subscription: mappedVideo.subscription, channel: mappedVideo.channel, item: mappedVideo.item, video: response.items.first { $0.id == mappedVideo.item?.contentDetails.videoId })
                }
            }
            .eraseToAnyPublisher()
    }
}
