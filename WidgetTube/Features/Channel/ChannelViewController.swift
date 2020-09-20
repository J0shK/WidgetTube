//
//  ChannelViewController.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import AlamofireImage
import Combine
import UIKit

protocol ChannelListener {
    func tappedCell(at indexPath: IndexPath)
}

class ChannelViewController: UIViewController, ChannelProtocol {
    var viewModel: ChannelViewModel
    var listener: ChannelListener?

    
    private let collectionView: UICollectionView = {
        let layout = ChannelFlowLayout()
        layout.minimumLineSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    private var bag = Set<AnyCancellable>()

    init(viewModel: ChannelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
        bind()
    }

    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.register(ChannelHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(ChannelCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func bind() {
        viewModel
            .channelUpdated
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: configure)
            .store(in: &bag)

        viewModel
            .playlistItemsUpdated
            .subscribe(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.collectionView.reloadData()
            }
            .store(in: &bag)
    }

    private func configure(_ channel: Channel?) {
        guard let channel = channel else { return }
        title = channel.snippet.title
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ChannelViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 240)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 200)
    }
}

extension ChannelViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == viewModel.items.count - 1 ) { viewModel.getPlaylistItems()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        listener?.tappedCell(at: indexPath)
    }
}

extension ChannelViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)

        guard let channelHeader = view as? ChannelHeader else {
            return view
        }

        channelHeader.configure(viewModel.channelUpdated.value)

        return channelHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        guard let channelCell = cell as? ChannelCell else {
            return cell
        }
        let item = viewModel.items[indexPath.item]
        channelCell.configure(with: item)
        channelCell.backgroundColor = indexPath.item % 2 == 0 ? .systemBackground : .secondarySystemBackground
        return channelCell
    }
}
