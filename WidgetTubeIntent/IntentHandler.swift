//
//  IntentHandler.swift
//  WidgetTubeIntent
//
//  Created by Josh Kowarsky on 10/6/20.
//

import Intents

class IntentHandler: INExtension, ConfigurationIntentHandling {
    let fileStore = FileStore()

    func resolveSubscriptions(for intent: ConfigurationIntent, with completion: @escaping ([WidgetSubscriptionResolutionResult]) -> Void) {
        print("Resolve subscriptions")
        completion([])
    }

    func provideSubscriptionsOptionsCollection(for intent: ConfigurationIntent, with completion: @escaping (INObjectCollection<WidgetSubscription>?, Error?) -> Void) {
        print("Provide subscriptions options")
        let subscriptions: [Subscription]? = try? fileStore.load(key: .subscriptions)
        let mapped = subscriptions?.map { subscription -> WidgetSubscription in
            let ws = WidgetSubscription(
                identifier: subscription.snippet.resourceId.channelId,
                display: subscription.snippet.title
            )
            ws.title = subscription.snippet.title
            return ws
        }
        let collection = INObjectCollection(items: mapped ?? [])
        completion(collection, nil)
    }
}
