//
//  ErrorView.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/22/20.
//

import GoogleSignInSwift
import SwiftUI

struct ErrorView : View {
    let entry: YouTubeProvider.Entry
    let error: Error

    var body: some View {
        VStack(spacing: 0) {
            if let ytError = error as? YTError {
                if ytError.code == 401 {
                    Text("Tap to reauthenticate")
                } else {
                    Text("\(ytError.code)")
                    Text(ytError.message.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                }
            } else if let gError = error as? GoogleSignIn.Error {
                if gError == .notSignedIn {
                    Text("Tap to sign in")
                } else {
                    Text("\(gError.localizedDescription)")
                }
            } else {
                Text("unknown error")
            }
        }
        .padding(9)
    }
}
