//
//  MetadataStore.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/23/20.
//

import Foundation

struct MetadataStore {
    enum Error: Swift.Error {
        case fileNotFound
        case invalidDirectory
        case writingFailed
        case readingFailed
    }

    struct Metadata: Codable {
        var lastUpdate: Date?
        var nextPageToken: String?
    }

    private let fileManager: FileManager
    private var url: URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)?.appendingPathComponent("db/metadata.plist")
    }
    var metadata: [StorageKey: Metadata] {
        guard let metadata = try? load() else {
            var dict = [StorageKey: Metadata]()
            // No metadata
            for key in StorageKey.allValues {
                dict[key] = Metadata()
            }
            return dict
        }
        return metadata
    }

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func save(metadata: [StorageKey: Metadata]) throws {
        guard let url = url else { throw Error.invalidDirectory }
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            try encoder.encode(metadata).write(to: url, options: [.atomic])
        } catch {
            debugPrint(error)
            throw Error.writingFailed
        }
    }

    func load() throws -> [StorageKey: Metadata] {
        guard let url = url else { throw Error.invalidDirectory }
        do {
            let data = try Data(contentsOf: url)
            return try PropertyListDecoder().decode([StorageKey: Metadata].self, from: data)
        } catch {
            debugPrint(error)
            throw Error.readingFailed
        }
    }

    func clear() throws {
        guard let url = url, fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
        print("Cleared Metadata")
    }
}
