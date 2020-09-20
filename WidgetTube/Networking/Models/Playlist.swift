//
//  Playlist.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Foundation

struct PlaylistResponse: Codable {
    let kind: String
    let etag: String
    let nextPageToken: String?
    let prevPageToken: String?
    let pageInfo: PageInfo
    let items: [Playlist]

    struct PageInfo: Codable {
        let totalResults: Int?
        let resultsPerPage: Int
    }
}

struct Playlist: Codable, Hashable {
    let contentDetails: ContentDetails
    let etag: String
    let id: String
    let kind: String
    let snippet: Snippet

    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    struct ContentDetails: Codable {
        let itemCount: Int
    }

    struct Snippet: Codable {
        let channelId: String
        let description: String
        let publishedAt: String
        let thumbnails: [ThumbnailQuality: Thumbnail]
        let title: String
        let channelTitle: String
        let tags: [String]?
    }
}
