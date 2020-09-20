//
//  SmallView.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import SwiftUI

struct SmallView : View {
    let entry: YouTubeProvider.Entry

    var body: some View {
        VStack(spacing: 0) {
            if let item = entry.items.first {
                Image(uiImage: item.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 11))
                        .bold()
                        .lineLimit(2)
                    Text(item.channelTitle)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .widgetURL(URL(string: "widgettube:\(item.channelId)/\(item.id)")!)
                .padding(EdgeInsets(top: 0, leading: 9, bottom: 9, trailing: 9))
            } else {
                Image(uiImage: .placeholder)
                Text("No item")
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 9, trailing: 0))
    }
}
