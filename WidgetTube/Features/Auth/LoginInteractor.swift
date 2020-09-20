//
//  LoginInteractor.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Combine
import GoogleSignInSwift
import UIKit
import WidgetKit

protocol LoginProtocol : AnyObject{
    var viewModel: LoginViewModel { get }
    var listener: LoginListener? { get set }
}

class LoginInteractor {
    weak var view: LoginProtocol?
    private var bag = Set<AnyCancellable>()

    init(view: LoginProtocol) {
        self.view = view
        GoogleSignIn.shared.delegate = self
    }

    static func build() -> LoginViewController {
        let viewModel = LoginViewModel()
        let vc = LoginViewController(viewModel: viewModel)
        let listener = LoginInteractor(view: vc)
        vc.listener = listener
        return vc
    }
}

extension LoginInteractor: LoginListener {
    func tappedSignInButton() {
        GoogleSignIn.shared.presentingWindow = (view as? UIViewController)?.view.window
        GoogleSignIn.shared.signIn()
    }
}

extension LoginInteractor: GoogleSignInDelegate {
    func googleSignIn(didSignIn auth: GoogleSignIn.Auth?, user: GoogleSignIn.User?, error: Error?) {
        WidgetCenter.shared.reloadAllTimelines()
        DispatchQueue.main.async { [weak self] in
            guard let vc = self?.view as? UIViewController, let scene = vc.view.window?.windowScene?.delegate as? SceneDelegate else { return }
            scene.showHomeViewController()
        }
    }
}
