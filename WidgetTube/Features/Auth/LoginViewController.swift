//
//  LoginViewController.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import UIKit

@objc protocol LoginListener: AnyObject {
    func tappedSignInButton()
}

class LoginViewController: UIViewController, LoginProtocol {
    var viewModel: LoginViewModel
    var listener: LoginListener?

    private let signInButton = UIButton()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSignInButton()
    }

    private func setupSignInButton() {
        view.addSubview(signInButton)
        signInButton.setImage(UIImage(named: "btn_google_signin_normal"), for: .normal)
        signInButton.setImage(UIImage(named: "btn_google_signin_disabled"), for: .disabled)
        signInButton.setImage(UIImage(named: "btn_google_signin_focus"), for: .focused)
        signInButton.setImage(UIImage(named: "btn_google_signin_pressed"), for: .highlighted)
        signInButton.addTarget(listener, action: #selector(LoginListener.tappedSignInButton), for: .touchUpInside)
        signInButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
