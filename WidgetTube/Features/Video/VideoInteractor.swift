//
//  VideoInteractor.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import UIKit
import WebKit

protocol VideoProtocol : AnyObject{
    var viewModel: VideoViewModel { get }
    var listener: VideoListener? { get set }
    var webView: WKWebView { get }
}

class VideoInteractor {
    weak var view: VideoProtocol?

    init(view: VideoProtocol) {
        self.view = view
    }

    static func build(title: String? = nil, video: Video, channel: Channel?) -> VideoViewController {
        let viewModel = VideoViewModel(video: video, channel: channel)
        return build(title: title, viewModel: viewModel)
    }

    static func build(title: String? = nil, videoId: String, channel: Channel?) -> VideoViewController {
        let viewModel = VideoViewModel(videoId: videoId, channel: channel)
        return build(title: title, viewModel: viewModel)
    }

    static func build(title: String? = nil, videoId: String, channelId: String) -> VideoViewController {
        let viewModel = VideoViewModel(videoId: videoId, channelId: channelId)
        return build(title: title, viewModel: viewModel)
    }

    private static func build(title: String?, viewModel: VideoViewModel) -> VideoViewController {
        let vc = VideoViewController(viewModel: viewModel)
        vc.title = title
        let listener = VideoInteractor(view: vc)
        vc.listener = listener
        return vc
    }
}

extension VideoInteractor: VideoListener {
    func tappedVideo() {
        guard let video = view?.viewModel.video,
              let url = URL(string: "youtube://\(video.id)"),
              UIApplication.shared.canOpenURL(url) else {
            view?.webView.isHidden = false
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func tappedChannel() {
        guard let channel = view?.viewModel.channel else { return }
        let vc = ChannelInteractor.build(title: channel.snippet.title, channel: channel)
        (view as? UIViewController)?.navigationController?.show(vc, sender: self)
    }
}
