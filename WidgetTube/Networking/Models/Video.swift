//
//  Video.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Foundation

struct VideoResponse: Codable {
    let kind: String
    let etag: String
    let nextPageToken: String?
    let prevPageToken: String?
    let pageInfo: PageInfo
    let items: [Video]

    struct PageInfo: Codable {
        let totalResults: Int?
        let resultsPerPage: Int
    }
}

struct Video: Codable, Hashable {
    let contentDetails: ContentDetails
    let etag: String
    let id: String
    let kind: String
    let snippet: Snippet
    let player: Player

    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    struct ContentDetails: Codable {
        let duration: String
        let dimension: String
        let definition: String
        let caption: String
    }

    struct Snippet: Codable {
        let channelId: String
        let description: String
        let publishedAt: String
        let thumbnails: [ThumbnailQuality: Thumbnail]
        let title: String
        let channelTitle: String
        let tags: [String]?
        let categoryId: String
        let liveBroadcastContent: String
    }

    struct Player: Codable {
        let embedHtml: String
        let embedWidth: Int?
        let embedHeight: Int?
    }
}
