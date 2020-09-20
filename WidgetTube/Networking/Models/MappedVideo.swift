//
//  MappedVideo.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/23/20.
//

import Foundation

struct MappedVideo: Codable {
    let subscription: Subscription
    var channel: Channel?
    var item: PlaylistItem?
    var video: Video?
}
