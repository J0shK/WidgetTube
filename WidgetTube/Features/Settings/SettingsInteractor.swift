//
//  SettingsInteractor.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import GoogleSignInSwift
import UIKit

protocol SettingsProtocol : AnyObject{
    var viewModel: SettingsViewModel { get }
    var listener: SettingsListener? { get set }
}

class SettingsInteractor {
    weak var view: SettingsProtocol?

    init(view: SettingsProtocol) {
        self.view = view
    }

    static func build() -> SettingsViewController {
        let viewModel = SettingsViewModel()
        let vc = SettingsViewController(viewModel: viewModel)
        let listener = SettingsInteractor(view: vc)
        vc.listener = listener
        return vc
    }
}

extension SettingsInteractor: SettingsListener {
    func tappedClearCacheButton() {
        try? Current.store.clear()
    }

    func tappedLogoutButton() {
        try? Current.store.clear()
        GoogleSignIn.shared.signOut()
        ((view as? UIViewController)?.view.window?.windowScene?.delegate as? SceneDelegate)?.window?.rootViewController = LoginInteractor.build()
    }
}
