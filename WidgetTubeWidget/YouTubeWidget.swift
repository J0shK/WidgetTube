//
//  YouTubeWidget.swift
//  YouTubeWidget
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Combine
import WidgetKit
import SwiftUI
import Intents

struct YouTubeWidgetEntryView : View {
    @SwiftUI.Environment(\.widgetFamily) var family: WidgetFamily
    var entry: YouTubeProvider.Entry

    @ViewBuilder
    var body: some View {
        if let error = entry.error {
            ErrorView(entry: entry, error: error)
        } else {
            switch family {
            case .systemSmall: SmallView(entry: entry)
            case .systemMedium: MediumView(entry: entry)
            case .systemLarge: LargeView(entry: entry)
            default: UnknownView()
            }
        }
    }
}

@main
struct YouTubeWidget: Widget {
    let kind: String = "WidgetTubeWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: YouTubeProvider()) { entry in
            YouTubeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("YouTube Subscriptions")
        .description("List of newest videos from YouTube subscriptions.")
    }
}

struct YouTubeWidget_Previews: PreviewProvider {
    static var previews: some View {
        let entry = YouTubeEntry(date: Date(), configuration: ConfigurationIntent(), items: .init(repeating: .empty, count: 5))
        YouTubeWidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
