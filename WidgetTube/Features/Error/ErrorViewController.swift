//
//  ErrorViewController.swift
//  YouTube
//
//  Created by Josh Kowarsky on 10/5/20.
//

import Combine
import UIKit

class ErrorViewController: UIViewController {
    let tappedRetryButton = PassthroughSubject<Void, Never>()
    private let stackView = UIStackView()
    private let label = UILabel()
    private let retryButton = UIButton()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupStackView()
        setupLabel()
        setupRetryButton()
    }

    private func setupStackView() {
        view.addSubview(stackView)
        stackView.axis = .vertical

        stackView.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
        }
    }

    private func setupLabel() {
        stackView.addArrangedSubview(label)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .label
    }

    private func setupRetryButton() {
        stackView.addArrangedSubview(retryButton)
        retryButton.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
        retryButton.setTitle("retry", for: .normal)
        retryButton.setTitleColor(.link, for: .normal)
    }

    @objc private func didTapRetryButton() {
        tappedRetryButton.send(())
    }

    func configure(error: Error?) {
        guard let error = error as? YTError else {
            label.text = "unknown error"
            return
        }
        label.text = error.message.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
