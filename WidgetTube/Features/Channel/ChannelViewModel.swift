//
//  ChannelViewModel.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Alamofire
import Combine

class ChannelViewModel {
    let channelUpdated = CurrentValueSubject<Channel?, Never>(nil)
    let playlistItemsUpdated = CurrentValueSubject<[PlaylistItem], Never>([])
    var items: [PlaylistItem] {
        return playlistItemsUpdated.value
    }
    private var isLoading = false
    private var nextPageToken: String?
    private var bag = Set<AnyCancellable>()
    init(channelId: String) {
        let metadata = try? Current.store.metadataStore.load()
        if let nextPageToken = metadata?[.channel(id: channelId)]?.nextPageToken {
            self.nextPageToken = nextPageToken
        }

        if let lastUpdate = metadata?[.channel(id: channelId)]?.lastUpdate {
            let timeSince = Date().timeIntervalSince(lastUpdate)
            print("\(timeSince) since last Channel update")
            if timeSince < 3600 {
                if let mappedChannel: MappedChannel = try? Current.store.load(key: .channel(id: channelId)) {
                    channelUpdated.send(mappedChannel.channel)
                    if let items = mappedChannel.items {
                        playlistItemsUpdated.send(items)
                    }
                }
                print("Should update")
            }
        }else{
            print("No update date found")
        }

        Current
            .api
            .request(YouTubeRequest.channel(channelIds: [channelId]))
            .decodeJSON(type: ChannelResponse.self)
            .sink { completed in
                switch completed {
                case .failure(let error):
                    print("Error fetching channel: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] response in
                self?.channelUpdated.send(response.items.first)
                self?.getPlaylistItems(firstLoad: true)
            }
            .store(in: &bag)
    }

    convenience init(channel: Channel) {
        self.init(channelId: channel.id)
        channelUpdated.send(channel)
    }

    func getPlaylistItems(firstLoad: Bool = false) {
        guard !isLoading, let channel = channelUpdated.value, nextPageToken != nil || firstLoad else { return }
        isLoading = true
        Current
            .api
            .request(YouTubeRequest.playlistItems(playlistId: channel.contentDetails.relatedPlaylists.uploads, nextPageToken: nextPageToken))
            .decodeJSON(type: PlaylistItemResponse.self)
            .sink { [weak self] completed in
                switch completed {
                case .failure(let error):
                    print("Error fetching channel playlist items: \(error)")
                case .finished:
                    break
                }
                self?.isLoading = false
            } receiveValue: { [weak self] response in
                let existing = self?.playlistItemsUpdated.value ?? []
                self?.nextPageToken = response.nextPageToken
                let combined = existing + response.items
                self?.playlistItemsUpdated.send(combined)
                do {
                    guard let channel = self?.channelUpdated.value else { return }
                    try Current.store.save(MappedChannel(channel: channel, items: combined), key: .channel(id: channel.id), nextPageToken: response.nextPageToken)
                } catch {
                    print("Save error: \(error)")
                }
            }
            .store(in: &bag)
    }
}
