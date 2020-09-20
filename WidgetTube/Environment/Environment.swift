//
//  Environment.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import GoogleSignInSwift

struct Environment {
    var api: API
    var store: FileStore

    var isSignedIn: Bool {
        return GoogleSignIn.shared.isSignedIn
    }

    init(api: API, store: FileStore) {
        self.api = api
        self.store = store
        GoogleSignIn.shared.clientId = AppSecrets.googleClientId
        GoogleSignIn.shared.addScope("https://www.googleapis.com/auth/youtube.readonly")
        GoogleSignIn.shared.storage = UserCache()
    }
}

var Current: Environment = {
    return .init(
        api: API(),
        store: FileStore()
    )
}()
