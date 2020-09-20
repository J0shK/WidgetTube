//
//  Channel.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Foundation

struct ChannelResponse: Codable {
    let kind: String
    let etag: String
    let nextPageToken: String?
    let prevPageToken: String?
    let pageInfo: PageInfo
    let items: [Channel]

    struct PageInfo: Codable {
        let totalResults: Int?
        let resultsPerPage: Int
    }
}

struct Channel: Codable, Hashable {
    let contentDetails: ContentDetails
    let etag: String
    let id: String
    let kind: String
    let snippet: Snippet

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    struct ContentDetails: Codable {
        let relatedPlaylists: RelatedPlaylists

        struct RelatedPlaylists: Codable {
            let likes: String
            let favorites: String
            let uploads: String
        }
    }

    struct Snippet: Codable {
        let customUrl: String?
        let description: String
        let publishedAt: String
        let thumbnails: [ThumbnailQuality: Thumbnail]
        let title: String
    }
}
