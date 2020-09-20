//
//  ChannelCell.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import AlamofireImage
import UIKit

class ChannelCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupNameLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
    }

    private func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.font = .boldSystemFont(ofSize: 14)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(9)
            make.leading.trailing.bottom.equalToSuperview().inset(9)
        }
    }

    func configure(with item: PlaylistItem) {
        nameLabel.text = item.snippet.title
        guard let url = item.snippet.thumbnails[.medium]?.url else { return }
        imageView.af.setImage(withURL: url)
    }
}

