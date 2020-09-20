//
//  YouTubeEntry.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import WidgetKit

struct YouTubeEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let items: [VideoItem]
    var error: Error?
}
