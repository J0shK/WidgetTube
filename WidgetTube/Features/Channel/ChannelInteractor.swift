//
//  ChannelInteractor.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import UIKit

protocol ChannelProtocol : AnyObject{
    var viewModel: ChannelViewModel { get }
    var listener: ChannelListener? { get set }
}

class ChannelInteractor {
    weak var view: ChannelProtocol?

    init(view: ChannelProtocol) {
        self.view = view
    }

    static func build(title: String? = nil, channel: Channel) -> ChannelViewController {
        let viewModel = ChannelViewModel(channel: channel)
        return build(title: title, viewModel: viewModel)
    }

    static func build(title: String? = nil, channelId: String) -> ChannelViewController {
        let viewModel = ChannelViewModel(channelId: channelId)
        return build(title: title, viewModel: viewModel)
    }

    static func build(title: String? = nil, viewModel: ChannelViewModel) -> ChannelViewController {
        let vc = ChannelViewController(viewModel: viewModel)
        vc.title = title
        let listener = ChannelInteractor(view: vc)
        vc.listener = listener
        return vc
    }
}

extension ChannelInteractor: ChannelListener {
    func tappedCell(at indexPath: IndexPath) {
        guard let item = view?.viewModel.items[indexPath.item] else { return }
        let vc = VideoInteractor.build(title: item.snippet.title, videoId: item.snippet.resourceId.videoId, channel: view?.viewModel.channelUpdated.value)
        (view as? UIViewController)?.navigationController?.show(vc, sender: self)
    }
}
