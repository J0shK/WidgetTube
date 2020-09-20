//
//  HomeCell.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/22/20.
//

import AlamofireImage
import Combine
import UIKit

@objc protocol HomeCellDelegate {
    func tappedChannel(at indexPath: IndexPath)
}

class HomeCell: UICollectionViewCell {
    weak var delegate: HomeCellDelegate?
    private let imageView = UIImageView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let durationLabel = UILabel()
    private var indexPath: IndexPath = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupImageView()
        setupIconImageView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupDurationLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.af.cancelImageRequest()
        imageView.image = nil
        iconImageView.af.cancelImageRequest()
        iconImageView.image = nil
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
        }
    }

    private func setupIconImageView() {
        addSubview(iconImageView)
        iconImageView.layer.cornerRadius = 24 / 2
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(9)
            make.leading.equalToSuperview().offset(9)
            make.width.height.equalTo(24)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedIconImageView))
        iconImageView.isUserInteractionEnabled = true
        iconImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func tappedIconImageView() {
        delegate?.tappedChannel(at: indexPath)
    }

    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(9)
            make.leading.equalTo(iconImageView.snp.trailing).offset(9)
            make.trailing.equalToSuperview().inset(9)
        }
    }

    private func setupSubtitleLabel() {
        addSubview(subtitleLabel)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.font = .preferredFont(forTextStyle: .caption2)
        subtitleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().inset(9)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedSubtitleLabel))
        subtitleLabel.isUserInteractionEnabled = true
        subtitleLabel.addGestureRecognizer(tapGesture)
    }

    @objc private func tappedSubtitleLabel() {
        delegate?.tappedChannel(at: indexPath)
    }

    private func setupDurationLabel() {
        addSubview(durationLabel)
        durationLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        durationLabel.textColor = .white
        durationLabel.font = .boldSystemFont(ofSize: 10)
        durationLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(imageView).inset(9)
        }
    }

    func configure(with mappedVideo: MappedVideo, indexPath: IndexPath) {
        self.indexPath = indexPath
        
        if let channel = mappedVideo.channel {
            if let url = channel.snippet.thumbnails[.default]?.url {
                iconImageView.af.setImage(withURL: url)
            }
            subtitleLabel.text = channel.snippet.title
        }
        if let video = mappedVideo.video {
            durationLabel.text = video.contentDetails.duration.formatISO8601()
            titleLabel.text = video.snippet.title
            guard let url = video.snippet.thumbnails[.maxres]?.url else { return }
            imageView.af.setImage(withURL: url)
        }
    }
}
