//
//  SubscriptionsInteractor.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import UIKit

protocol SubscriptionsProtocol : AnyObject{
    var viewModel: SubscriptionsViewModel { get }
    var listener: SubscriptionsListener? { get set }
}

class SubscriptionsInteractor {
    weak var view: SubscriptionsProtocol?

    init(view: SubscriptionsProtocol) {
        self.view = view
    }

    static func build() -> SubscriptionsViewController {
        let viewModel = SubscriptionsViewModel()
        let vc = SubscriptionsViewController(viewModel: viewModel)
        let listener = SubscriptionsInteractor(view: vc)
        vc.listener = listener
        return vc
    }
}

extension SubscriptionsInteractor: SubscriptionsListener {
    func tapped(at indexPath: IndexPath) {
        guard let subscription = view?.viewModel.subscriptions[indexPath.item] else { return }
        let vc = ChannelInteractor.build(title: subscription.snippet.title, channelId: subscription.snippet.resourceId.channelId)
        (view as? UIViewController)?.navigationController?.show(vc, sender: self)
    }
}
