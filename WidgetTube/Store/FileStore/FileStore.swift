//
//  FileStore.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/23/20.
//

import Foundation

let groupIdentifier = "group.JKLOL.youtube"

enum StorageKey: Hashable {
    enum Error: Swift.Error {
        case noType
    }
    case home
    case subscriptions
    case channel(id: String? = nil)
    case video(id: String? = nil)

    static let allValues: [StorageKey] = [.home, .subscriptions, .channel(), .video()]

    var stringValue: String {
        switch self {
        case .home:
            return "home"
        case .subscriptions:
            return "subscriptions"
        case .channel(let id):
            return "channels/\(id ?? "noid")"
        case .video(let id):
            return "videos/\(id ?? "noid")"
        }
    }

    init(rawValue: String) throws {
        let components = rawValue.components(separatedBy: "/")
        if let first = components.first {
            switch first {
            case "home":
                self = .home
                return
            case "subscriptions":
                self = .subscriptions
                return
            case "channels", "videos":
                let second = components[1]
                switch first {
                case "channels":
                    self = .channel(id: second)
                    return
                case "videos":
                    self = .video(id: second)
                    return
                default:
                    break
                }
            default:
                break
            }
        }
        throw Error.noType
    }
}

class FileStore {
    enum Error: Swift.Error {
        case fileNotFound
        case invalidDirectory
        case writingFailed
        case readingFailed
    }

    private let fileManager: FileManager
    let userDefaults = UserDefaults.init(suiteName: groupIdentifier)
    var metadataStore: MetadataStore

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let dbFolderURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?.appendingPathComponent("db")
        if let dbFolderURL = dbFolderURL, !fileManager.fileExists(atPath: dbFolderURL.path) {
            try? fileManager.createDirectory(at: dbFolderURL, withIntermediateDirectories: true)
        }
        metadataStore = MetadataStore(fileManager: fileManager)
    }

    private func getDBURL(for key: StorageKey) -> URL? {
        let mainPath = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?.appendingPathComponent("db")
        if case .channel = key {
            if let directoryPath = mainPath?.appendingPathComponent("channels"), !fileManager.fileExists(atPath: directoryPath.path) {
                try? fileManager.createDirectory(atPath: directoryPath.path, withIntermediateDirectories: true)
            }
        }
        return mainPath?.appendingPathComponent("\(key.stringValue).json")
    }

    func save<T: Codable>(_ items: T, key: StorageKey, nextPageToken: String?) throws {
        guard let url = getDBURL(for: key) else { throw Error.invalidDirectory }
        do {
            print("[FileStore] Saving \(key) to \(url.absoluteString)")
            try JSONEncoder().encode(items).write(to: url, options: [.atomic])
            var metadata = metadataStore.metadata
            metadata[key]?.lastUpdate = Date()
            metadata[key]?.nextPageToken = nextPageToken
            try metadataStore.save(metadata: metadata)
        } catch {
            debugPrint(error)
            throw Error.writingFailed
        }
    }

    func load<T: Codable>(key: StorageKey) throws -> T {
        guard let url = getDBURL(for: key) else { throw Error.invalidDirectory }
        guard fileManager.fileExists(atPath: url.path) else { throw Error.fileNotFound }
        do {
            print("[FileStore] Loading \(key) from \(url.absoluteString)")
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {

            debugPrint(error)
            throw Error.readingFailed
        }
    }

    func clear() throws {
        for value in StorageKey.allValues {
            guard let url = getDBURL(for: value), fileManager.fileExists(atPath: url.path) else { continue }
            try fileManager.removeItem(at: url)

        }
        try metadataStore.clear()
        print("[FileStore] Cleared cache")
    }
}


extension KeyedDecodingContainer  {
    func decode<Element: Decodable>(_ type: [StorageKey: Element].Type, forKey key: Key) throws -> [StorageKey: Element] {
        let stringDictionary = try decode([String: Element].self, forKey: key)
        var dictionary = [StorageKey: Element]()
        for (key, value) in stringDictionary {
            guard let thumbQualityEnum = try? StorageKey(rawValue: key) else {
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse json key to an StorageKey object")
                throw DecodingError.dataCorrupted(context)
            }
            dictionary[thumbQualityEnum] = value
        }
        return dictionary
    }
}

extension KeyedEncodingContainer {
    mutating func encode<Element: Encodable>(_ dict: [StorageKey: Element], forKey key: Key) throws {
        var newDict = [String: Element]()
        for (key, value) in dict {
            newDict[key.stringValue] = value
        }
        try encode(newDict, forKey: key)
    }
}

extension StorageKey: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.stringValue)
    }
}

extension StorageKey: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        try self.init(rawValue: stringValue)
    }
}
