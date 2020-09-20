//
//  MappedChannel.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/26/20.
//

import Foundation

struct MappedChannel: Codable {
    var channel: Channel
    var items: [PlaylistItem]?
}
