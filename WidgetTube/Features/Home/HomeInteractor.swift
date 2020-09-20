//
//  HomeInteractor.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/22/20.
//

import UIKit

protocol HomeProtocol : AnyObject{
    var viewModel: HomeViewModel { get }
    var listener: HomeListener? { get set }
}

class HomeInteractor {
    weak var view: HomeProtocol?

    init(view: HomeProtocol) {
        self.view = view
    }

    static func build() -> HomeViewController {
        let viewModel = HomeViewModel()
        let vc = HomeViewController(viewModel: viewModel)
        let listener = HomeInteractor(view: vc)
        vc.listener = listener
        return vc
    }
}

extension HomeInteractor: HomeListener {
    func tappedChannel(at indexPath: IndexPath) {
        guard let channel = view?.viewModel.items[indexPath.item].channel else { return }
        let vc = ChannelInteractor.build(title: channel.snippet.title, channel: channel)
        (view as? UIViewController)?.navigationController?.show(vc, sender: self)
    }

    func tappedVideo(at indexPath: IndexPath) {
        guard let item = view?.viewModel.items[indexPath.item], let video = item.video else { return }
        let vc = VideoInteractor.build(title: video.snippet.title, video: video, channel: item.channel)
        (view as? UIViewController)?.navigationController?.show(vc, sender: self)
    }
}
