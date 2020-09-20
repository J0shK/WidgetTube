//
//  VideoItem.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import UIKit

struct VideoItem: Hashable {
    let id: String
    let title: String
    let channelId: String
    let channelTitle: String
    let image: UIImage

    static var empty: VideoItem {
        return VideoItem(id: "", title: "loading", channelId: "", channelTitle: "title", image: .placeholder)
    }
}
