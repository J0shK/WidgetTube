//
//  Subscription.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Foundation

struct SubscriptionResponse: Codable {
    let kind: String
    let etag: String
    let nextPageToken: String?
    let prevPageToken: String?
    let pageInfo: PageInfo
    let items: [Subscription]

    struct PageInfo: Codable {
        let totalResults: Int
        let resultsPerPage: Int
    }
}

struct Subscription: Codable, Hashable {
    let contentDetails: ContentDetails
    let etag: String
    let id: String
    let kind: String
    let snippet: Snippet

    static func == (lhs: Subscription, rhs: Subscription) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    struct ContentDetails: Codable {
        let activityType: ActivityType
        let newItemCount: Int
        let totalItemCount: Int

        enum ActivityType: String, Codable {
            case all, uploads
        }
    }

    struct Snippet: Codable {
        let channelId: String
        let description: String
        let publishedAt: String
        let resourceId: ResourceID
        let thumbnails: [ThumbnailQuality: Thumbnail]
        let title: String

        struct ResourceID: Codable {
            let channelId: String
            let kind: String
        }
    }
}

struct Thumbnail: Codable {
    let url: URL
}

enum ThumbnailQuality: String, Codable {
    case `default`
    case high
    case medium
    case standard
    case maxres
}

extension KeyedDecodingContainer  {
    func decode<Element: Decodable>(_ type: [ThumbnailQuality: Element].Type, forKey key: Key) throws -> [ThumbnailQuality: Element] {
        let stringDictionary = try decode([String: Element].self, forKey: key)
        var dictionary = [ThumbnailQuality: Element]()
        for (key, value) in stringDictionary {
            guard let thumbQualityEnum = ThumbnailQuality(rawValue: key) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse json key to an ThumbnailQuality object")
                throw DecodingError.dataCorrupted(context)
            }
            dictionary[thumbQualityEnum] = value
        }
        return dictionary
    }
}

extension KeyedEncodingContainer {
    mutating func encode<Element: Encodable>(_ dict: [ThumbnailQuality: Element], forKey key: Key) throws {
        var newDict = [String: Element]()
        for (key, value) in dict {
            newDict[key.rawValue] = value
        }
        try encode(newDict, forKey: key)
    }
}
