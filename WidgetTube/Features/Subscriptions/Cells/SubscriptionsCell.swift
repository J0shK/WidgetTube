//
//  SubscriptionsCell.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import AlamofireImage
import UIKit

class SubscriptionsCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let dividerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupNameLabel()
        setupDividerLabel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.af.cancelImageRequest()
        imageView.image = nil
    }

    private func setupImageView() {
        addSubview(imageView)
        imageView.layer.cornerRadius = 50 / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }

    private func setupNameLabel() {
        addSubview(nameLabel)
        nameLabel.textColor = .label
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(imageView.snp.centerY)
            make.leading.equalTo(imageView.snp.trailing).offset(9)
            make.trailing.equalToSuperview()
        }
    }

    private func setupDividerLabel() {
        addSubview(dividerView)
        dividerView.backgroundColor = .separator

        dividerView.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    func configure(with subscription: Subscription) {
        nameLabel.text = subscription.snippet.title
        guard let url = subscription.snippet.thumbnails[.default]?.url else { return }
        imageView.af.setImage(withURL: url)
    }
}
