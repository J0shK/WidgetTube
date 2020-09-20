//
//  SubscriptionsViewController.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Combine
import SnapKit
import UIKit

protocol SubscriptionsListener {
    func tapped(at indexPath: IndexPath)
}

class SubscriptionsViewController: UIViewController, SubscriptionsProtocol {
    var viewModel: SubscriptionsViewModel
    var listener: SubscriptionsListener?

    private let errorVC = ErrorViewController()
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let refreshControl = UIRefreshControl()
    private var bag = Set<AnyCancellable>()

    init(viewModel: SubscriptionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Subscriptions"
        tabBarItem.image = UIImage(systemName: "list.dash")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupErrorView()
        setupRefreshControl()
        setupCollectionView()
        bind()
    }

    private func setupErrorView() {
        view.addSubview(errorVC.view)
        errorVC.view.isHidden = true
        errorVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    @objc private func refresh() {
        viewModel.refresh()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SubscriptionsCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bind() {
        viewModel
            .subscriptionsUpdated
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] subscriptions in
                self?.errorVC.view.isHidden = true
                self?.collectionView.isHidden = false
                self?.refreshControl.endRefreshing()
                self?.collectionView.reloadData()
                self?.collectionView.collectionViewLayout.invalidateLayout()
            }
            .store(in: &bag)

        viewModel
            .error
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error else { return }
                self?.errorVC.configure(error: error)
                self?.errorVC.view.isHidden = false
                self?.collectionView.isHidden = true
            }
            .store(in: &bag)

        errorVC
            .tappedRetryButton
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.viewModel.refresh()
                self?.refreshControl.beginRefreshing()
                self?.errorVC.view.isHidden = true
            }
            .store(in: &bag)
    }
}

extension SubscriptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 60)
    }
}

extension SubscriptionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.subscriptions.count - 1 ) { viewModel.getSubscriptions()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        listener?.tapped(at: indexPath)
    }
}

extension SubscriptionsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.subscriptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        guard let subscriptionsCell = cell as? SubscriptionsCell else {
            return cell
        }
        let subscription = viewModel.subscriptions[indexPath.item]
        subscriptionsCell.configure(with: subscription)
        subscriptionsCell.backgroundColor = indexPath.item % 2 == 0 ? .systemBackground : .secondarySystemBackground
        return subscriptionsCell
    }


}
