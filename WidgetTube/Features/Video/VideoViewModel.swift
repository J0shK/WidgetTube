//
//  VideoViewModel.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Alamofire
import Combine

class VideoViewModel {
    let videoUpdated = CurrentValueSubject<Video?, Never>(nil)
    var video: Video? {
        return videoUpdated.value
    }
    let channelUpdated = CurrentValueSubject<Channel?, Never>(nil)
    var channel: Channel? {
        return channelUpdated.value
    }
    private var bag = Set<AnyCancellable>()
    
    init(videoId: String?, channelId: String?) {
        getVideo(videoId: videoId)
        getChannel(channelId: channelId)
    }

    private func getVideo(videoId: String?) {
        guard let videoId = videoId else { return }
        Current
            .api
            .request(YouTubeRequest.video(videoIds: [videoId]))
            .decodeJSON(type: VideoResponse.self)
            .sink { completed in
            switch completed {
            case .failure(let error):
                print("Error fetching video: \(error)")
            case .finished:
                break
            }
        } receiveValue: { [weak self] response in
            self?.videoUpdated.send(response.items.first)
        }.store(in: &bag)
    }

    private func getChannel(channelId: String?) {
        guard let channelId = channelId else { return }
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
        }.store(in: &bag)
    }

    convenience init(video: Video, channel: Channel?) {
        self.init(videoId: nil, channelId: channel?.id)
        videoUpdated.send(video)
        channelUpdated.send(channel)
    }

    convenience init(videoId: String, channel: Channel?) {
        self.init(videoId: videoId, channelId: channel?.id)
        channelUpdated.send(channel)
    }
}
