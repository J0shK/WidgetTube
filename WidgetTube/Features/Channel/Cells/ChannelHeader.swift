//
//  ChannelHeader.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/22/20.
//

import UIKit

class ChannelHeader: UICollectionReusableView {
    private let nameLabel = UILabel()
    private let roundedView = UIView()
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setupImageView()
        setupRoundedView()
        setupNameLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    private func setupRoundedView() {
        addSubview(roundedView)
        roundedView.backgroundColor = .systemBackground
        roundedView.layer.cornerRadius = 14
        roundedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        roundedView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.textColor = .label
        nameLabel.font = .boldSystemFont(ofSize: 25)
        nameLabel.textAlignment = .center
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.bottom.trailing.equalToSuperview().inset(12)
        }
    }

    func configure(_ channel: Channel?) {
        guard let channel = channel else { return }
        nameLabel.text = channel.snippet.title
        guard let url = channel.snippet.thumbnails[.high]?.url else { return }
        imageView.af.setImage(withURL: url)
    }
}
