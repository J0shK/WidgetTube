//
//  YouTubeService.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import AlamofireImage
import Combine

class YouTubeService {
    private let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )

    func getAssortment() -> AnyPublisher<[VideoItem], Error> {
        var staleData = false
        if let metadata = try? Current.store.metadataStore.load(), let lastUpdate = metadata[.home]?.lastUpdate {
            let timeSince = Date().timeIntervalSince(lastUpdate)
            print("\(timeSince) since last Widget update")
            staleData = timeSince > 3600
        }else{
            print("No update date found")
        }

        let request: AnyPublisher<[MappedVideo], Error>
        let mappedVideos: [MappedVideo] = (try? Current.store.load(key: .home)) ?? []
        if !mappedVideos.isEmpty && !staleData {
            request = Just(mappedVideos)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            request = getSubscriptions()
                .flatMap(mapChannel)
                .flatMap(mapPlaylistItems)
                .eraseToAnyPublisher()
        }

        return request
            .flatMap(mapImages)
            .share()
            .eraseToAnyPublisher()
    }

    private func getSubscriptions() -> AnyPublisher<[Subscription], Error> {
        return Current
            .api
            .request(YouTubeRequest.subscriptions(nextPageToken: nil))
            .decodeJSON(type: SubscriptionResponse.self)
            .map { $0.items }
            .eraseToAnyPublisher()
    }

    private func mapChannel(to subscriptions: [Subscription]) -> AnyPublisher<[MappedVideo], Error> {
        return Current
            .api
            .request(YouTubeRequest.channel(channelIds: subscriptions.map { $0.snippet.resourceId.channelId }))
            .decodeJSON(type: ChannelResponse.self)
            .map { response in
                var array = [MappedVideo]()
                for subscription in subscriptions {
                    array.append(MappedVideo(subscription: subscription, channel: response.items.first { $0.id == subscription.snippet.resourceId.channelId }))
                }
                return array
            }
            .eraseToAnyPublisher()
    }

    private func mapPlaylistItems(for mappedVideo: MappedVideo) -> AnyPublisher<MappedVideo, Error> {
        return Current
            .api
            .request(YouTubeRequest.playlistItems(playlistId: mappedVideo.channel?.contentDetails.relatedPlaylists.uploads ?? "", nextPageToken: nil))
            .decodeJSON(type: PlaylistItemResponse.self)
            .map { MappedVideo(subscription: mappedVideo.subscription, channel: mappedVideo.channel, item: $0.items.first) }
            .eraseToAnyPublisher()
    }

    private func mapPlaylistItems(for mappedVideos: [MappedVideo]) -> AnyPublisher<[MappedVideo], Error> {
        let array = mappedVideos.map(mapPlaylistItems)
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

    private func mapImages(to mappedVideos: [MappedVideo]) -> AnyPublisher<[VideoItem], Never> {
        let array = mappedVideos.compactMap { $0.item }.map { imageDownloader.image(for: $0.snippet.thumbnails[.default]!.url, with: $0.id) }
        let initial = Just<[(String, UIImage?)]>([])
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()

        let zipped = array.reduce(into: initial) { result, upstream in
            result = result.zip(upstream) { elements, element in
                elements + [element]
            }
            .eraseToAnyPublisher()
        }

        return zipped.map { results in
            var finalItems = [VideoItem]()
            for result in results {
                if let item = mappedVideos.first(where: { $0.item?.id == result.0 })?.item {
                    let videoItem = VideoItem(
                        id: item.snippet.resourceId.videoId,
                        title: item.snippet.title,
                        channelId: item.snippet.channelId,
                        channelTitle: item.snippet.channelTitle,
                        image: result.1 ?? .placeholder)
                    finalItems.append(videoItem)
                }
            }
            return finalItems
        }.eraseToAnyPublisher()
    }
}
