//
//  MediumView.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import SwiftUI

struct MediumView : View {
    let entry: YouTubeProvider.Entry

    var body: some View {
        HStack(spacing: 3) {
            VStack(spacing: 3) {
                if let item = entry.items.first {
                    Link(destination: URL(string: "widgettube:\(item.channelId)/\(item.id)")!) {
                        Image(uiImage: item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxHeight: 85)
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
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 9))
            VStack(spacing: 2) {
                ForEach(entry.items.count < 2 ? [] : entry.items[1...min(3, entry.items.count - 1)], id: \.self) { item in
                    Link(destination: URL(string: "widgettube:\(item.channelId)/\(item.id)")!) {
                        HStack(spacing: 9) {
                            Image(uiImage: item.image)
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 40)
                                .clipped()
                            VStack(alignment: .leading, spacing: 3) {
                                Text(item.title)
                                    .font(.system(size: 9))
                                    .bold()
                                    .lineLimit(2)
                                Text(item.channelTitle)
                                    .font(.system(size: 7))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }.padding(9)
    }
}

