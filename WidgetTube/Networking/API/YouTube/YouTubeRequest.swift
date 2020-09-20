//
//  YouTubeRequest.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Alamofire
import Combine
import GoogleSignInSwift

enum YouTubeRequest: Request {
    enum RequestError: Swift.Error {
        case noUser
        case refreshError
    }
    var hostURLString: String {
        return "https://www.googleapis.com/youtube/v3"
    }

    var isAuthenticated: Bool {
        return true
    }

    var headers: HTTPHeaders? {
        guard let token = GoogleSignIn.shared.auth?.accessToken else { return nil }
        return [.authorization(bearerToken: token)]
    }

    case subscriptions(nextPageToken: String?)
    case channel(channelIds: [String])
    case playlist(playlistIds: [String])
    case playlistItems(playlistId: String, nextPageToken: String?)
    case video(videoIds: [String])

    var method: HTTPMethod {
        switch self {
        case .subscriptions, .channel, .playlist, .playlistItems, .video:
            return .get
        }
    }

    var path: String {
        switch self {
        case .subscriptions:
            return "subscriptions"
        case .channel:
            return "channels"
        case .playlist:
            return "playlists"
        case .playlistItems:
            return "playlistItems"
        case .video:
            return "videos"
        }
    }

    var parameters: Parameters {
        var params: [String: Any] = [
            "part": "snippet, contentDetails",
            "key": AppSecrets.youtubeKey
        ]
        switch self {
        case .subscriptions(let nextPageToken):
            params["mine"] = true
            if let nextPageToken = nextPageToken {
                params["pageToken"] = nextPageToken
            }
        case .channel(let channelIds):
            params["id"] = channelIds.joined(separator: ",")
        case .playlist(let playlistIds):
            params["id"] = playlistIds.joined(separator: ",")
        case .playlistItems(let playlistId, let nextPageToken):
            params["playlistId"] = playlistId
            if let nextPageToken = nextPageToken {
                params["pageToken"] = nextPageToken
            }
        case .video(let videoIds):
            params["part"] = "snippet, contentDetails, player"
            params["id"] = videoIds.joined(separator: ",")
        }
        return params
    }

    func refreshTokenIfNecessary() -> AnyPublisher<Request, Error> {
        return Future<Request, Error> { observer in
            GoogleSignIn.shared.refreshingAccessToken { accessToken, error in
                if let error = error {
                    observer(.failure(error))
                    return
                }
                observer(.success(self))
            }
        }.eraseToAnyPublisher()
    }
}
