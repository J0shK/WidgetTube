//
//  LargeView.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import SwiftUI

struct LargeView : View {
    let entry: YouTubeProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Subscriptions").font(.title)
            ForEach(entry.items.prefix(5), id: \.self) { item in
                HStack(spacing: 9) {
                    Link(destination: URL(string: "widgettube:\(item.channelId)/\(item.id)")!) {
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 85, height: 50)
                            .clipped()
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(.system(size: 11))
                                .bold()
                            Text(item.channelTitle)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }.padding()
    }
}

