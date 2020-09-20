//
//  HomeViewController.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/22/20.
//

import Combine
import UIKit

protocol HomeListener {
    func tappedChannel(at indexPath: IndexPath)
    func tappedVideo(at indexPath: IndexPath)
}

class HomeViewController: UIViewController, HomeProtocol {
    var viewModel: HomeViewModel
    var listener: HomeListener?

    private let errorVC = ErrorViewController()
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private let refreshControl = UIRefreshControl()
    private var bag = Set<AnyCancellable>()

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Home"
        tabBarItem.image = UIImage(systemName: "house")
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
        collectionView.register(HomeCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bind() {
        viewModel
            .itemsUpdated
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] _ in
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

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 240)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.items.count - 1 ) {
            viewModel.getAssortment()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        listener?.tappedVideo(at: indexPath)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        guard let homeCell = cell as? HomeCell else {
            return cell
        }
        let item = viewModel.items[indexPath.item]
        homeCell.configure(with: item, indexPath: indexPath)
        homeCell.delegate = self
        return homeCell
    }
}

extension HomeViewController: HomeCellDelegate {
    func tappedChannel(at indexPath: IndexPath) {
        listener?.tappedChannel(at: indexPath)
    }
}
