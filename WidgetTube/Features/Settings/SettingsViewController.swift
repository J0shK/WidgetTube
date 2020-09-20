//
//  SettingsViewController.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import UIKit

protocol SettingsListener {
    func tappedClearCacheButton()
    func tappedLogoutButton()
}

class SettingsViewController: UIViewController, SettingsProtocol {
    var viewModel: SettingsViewModel
    var listener: SettingsListener?

    private let clearCacheButton = UIButton()
    private let logoutButton = UIButton()

    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        tabBarItem.image = UIImage(systemName: "gear")
        tabBarItem.title = "Settings"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        setupClearCacheButton()
        setupLogoutButton()
    }

    private func setupClearCacheButton() {
        view.addSubview(clearCacheButton)
        clearCacheButton.setTitle("Clear Cache", for: .normal)
        clearCacheButton.setTitleColor(.link, for: .normal)
        clearCacheButton.addTarget(self, action: #selector(tappedClearCacheButton), for: .touchUpInside)
        clearCacheButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.link, for: .normal)
        logoutButton.addTarget(self, action: #selector(tappedLogoutButton), for: .touchUpInside)
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(clearCacheButton.snp.bottom).offset(9)
            make.centerX.equalToSuperview()
        }
    }

    @objc private func tappedClearCacheButton() {
        listener?.tappedClearCacheButton()
    }

    @objc private func tappedLogoutButton() {
        listener?.tappedLogoutButton()
    }
}
