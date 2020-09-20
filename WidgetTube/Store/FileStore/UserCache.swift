//
//  UserCache.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/25/20.
//

import GoogleSignInSwift

struct UserCache: GoogleSignInStorage {
    enum Key: String, CaseIterable {
        case auth
        case user
    }
    let userDefaults = UserDefaults.init(suiteName: groupIdentifier)

    func get() -> GoogleSignIn.Auth? {
        guard let data = userDefaults?.data(forKey: Key.auth.rawValue) else { return nil }
        return try? JSONDecoder().decode(GoogleSignIn.Auth.self, from: data)
    }

    func get() -> GoogleSignIn.User? {
        guard let data = userDefaults?.data(forKey: Key.user.rawValue) else { return nil }
        return try? JSONDecoder().decode(GoogleSignIn.User.self, from: data)
    }

    func set(auth: GoogleSignIn.Auth?) {
        let data = try? JSONEncoder().encode(auth)
        userDefaults?.set(data, forKey: Key.auth.rawValue)
    }

    func set(user: GoogleSignIn.User?) {
        let data = try? JSONEncoder().encode(user)
        userDefaults?.set(data, forKey: Key.user.rawValue)
    }

    func clear() -> Bool {
        for key in Key.allCases {
            userDefaults?.removeObject(forKey: key.rawValue)
        }
        return true
    }
}
