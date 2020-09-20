//
//  SubscriptionsViewModel.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Alamofire
import Combine

class SubscriptionsViewModel {
    let subscriptionsUpdated = CurrentValueSubject<[Subscription], Never>([])
    let error = CurrentValueSubject<YTError?, Never>(nil)
    private var nextPageToken: String?
    private var isLoading = false
    private var isRefreshing = false
    private var bag = Set<AnyCancellable>()

    var subscriptions: [Subscription] {
        return subscriptionsUpdated.value
    }

    init() {
        let metadata = try? Current.store.metadataStore.load()
        if let nextPageToken = metadata?[.subscriptions]?.nextPageToken {
            self.nextPageToken = nextPageToken
        }

        if let lastUpdate = metadata?[.subscriptions]?.lastUpdate {
            let timeSince = Date().timeIntervalSince(lastUpdate)
            print("\(timeSince) since last Subscriptions update")
            if timeSince < 3600 {
                let subscriptions: [Subscription] = (try? Current.store.load(key: .subscriptions)) ?? []
                if !subscriptions.isEmpty {
                    subscriptionsUpdated.send(subscriptions)
                    return
                }
                print("Should update")
            }
        }else{
            print("No update date found")
        }

        getSubscriptions(firstLoad: true)
    }

    func refresh() {
        bag = Set<AnyCancellable>()
        isLoading = false
        isRefreshing = true
        nextPageToken = nil
        getSubscriptions()
    }

    func getSubscriptions(firstLoad: Bool = false) {
        guard !isLoading, nextPageToken != nil || firstLoad || isRefreshing else { return }
        isLoading = true
        Current
            .api
            .request(YouTubeRequest.subscriptions(nextPageToken: nextPageToken))
            .decodeJSON(type: SubscriptionResponse.self)
            .sink { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error.send(error as? YTError)
                    print("Error fetching subscriptions: \(error)")
                case .finished:
                    break
                }
                self?.isRefreshing = false
                self?.isLoading = false
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                let existing = self.isRefreshing ? [] : self.subscriptionsUpdated.value
                self.nextPageToken = response.nextPageToken
                let combined = existing + response.items
                self.subscriptionsUpdated.send(combined)
                do {
                    try Current.store.save(combined, key: .subscriptions, nextPageToken: response.nextPageToken)
                } catch {
                    print("Save error: \(error)")
                }
            }
            .store(in: &bag)
    }
}
