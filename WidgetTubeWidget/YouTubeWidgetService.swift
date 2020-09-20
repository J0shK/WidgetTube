//
//  YouTubeService.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import AlamofireImage
import Combine

struct ItemWithImage: Hashable {
    let item: YTPlaylistItem
    var image: UIImage?
}

class YouTubeService {
    private let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 4,
        imageCache: AutoPurgingImageCache()
    )

    var itemsWithImages: AnyPublisher<[ItemWithImage], Error> {
        return Current
            .api
            .request(YouTubeRequest.subscriptions(nextPageToken: nil))
            .decodeJSON(type: YTSubscriptionResponse.self)
            .flatMap({ Current.api.request(YouTubeRequest.channel(channelId: $0.items[0].snippet.resourceId.channelId)) })
            .decodeJSON(type: YTChannelResponse.self)
            .flatMap({ Current.api.request(YouTubeRequest.playlistItems(playlistId: $0.items[0].contentDetails.relatedPlaylists.uploads, nextPageToken: nil)) })
            .decodeJSON(type: YTPlaylistItemResponse.self)
            .map { return $0.items }
            .flatMap(getImages)
            .eraseToAnyPublisher()
    }

    private func getImages(for items: [YTPlaylistItem]) -> AnyPublisher<[ItemWithImage], Never> {
        let array = items.map { imageDownloader.image(for: $0.snippet.thumbnails[.default]!.url, with: $0.id) }
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
            var finalItems = [ItemWithImage]()
            for result in results {
                if let item = items.first(where: { $0.id == result.0 }) {
                    finalItems.append(ItemWithImage(item: item, image: result.1))
                }
            }
            return finalItems
        }.eraseToAnyPublisher()
    }
}
