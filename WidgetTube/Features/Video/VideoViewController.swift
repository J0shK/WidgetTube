//
//  VideoViewController.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Combine
import UIKit
import WebKit

@objc protocol VideoListener {
    func tappedVideo()
    func tappedChannel()
}

class VideoViewController: UIViewController, VideoProtocol {
    var viewModel: VideoViewModel
    var listener: VideoListener?

    private let imageView = UIImageView()
    private let iconImageView = UIImageView()
    private let playButton = UIButton()
    var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        return WKWebView(frame: .zero, configuration: config)
    }()
    private let nameLabel = UILabel()
    private let scrollView = UIScrollView()
    private let descriptionLabel = UILabel()
    private var bag = Set<AnyCancellable>()

    init(viewModel: VideoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupImageView()
        setupPlayButton()
        setupWebView()
        setupScrollView()
        setupIconImageView()
        setupNameLabel()
        setupDescriptionLabel()
        bind()
    }

    private func setupImageView() {
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }

        let tapGesture = UITapGestureRecognizer(target: listener, action: #selector(VideoListener.tappedVideo))
        imageView.addGestureRecognizer(tapGesture)
    }

    private func setupPlayButton() {
        view.addSubview(playButton)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold, scale: .large)

         let largeBoldPlay = UIImage(systemName: "play.fill", withConfiguration: largeConfig)
        playButton.setImage(largeBoldPlay, for: .normal)
        playButton.tintColor = .systemRed
        playButton.addTarget(listener, action: #selector(VideoListener.tappedVideo), for: .touchUpInside)
        playButton.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalTo(imageView)
        }
    }

    private func setupWebView() {
        view.addSubview(webView)
        webView.isHidden = true
        webView.backgroundColor = .clear
        webView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
        }
    }

    private func setupIconImageView() {
        scrollView.addSubview(iconImageView)
        iconImageView.layer.cornerRadius = 30 / 2
        iconImageView.clipsToBounds = true
        iconImageView.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(9)
            make.width.height.equalTo(30)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedIconImageView))
        iconImageView.isUserInteractionEnabled = true
        iconImageView.addGestureRecognizer(tapGesture)
    }

    @objc private func tappedIconImageView() {
        listener?.tappedChannel()
    }

    private func setupNameLabel() {
        scrollView.addSubview(nameLabel)
        nameLabel.textColor = .label
        nameLabel.font = .boldSystemFont(ofSize: 21)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.numberOfLines = 0
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(9)
            make.trailing.equalToSuperview()
            make.height.lessThanOrEqualTo(60)
        }
    }

    private func setupDescriptionLabel() {
        scrollView.addSubview(descriptionLabel)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(9)
            make.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(scrollView.snp.width)
        }
    }

    private func bind() {
        viewModel
            .videoUpdated
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: configure)
            .store(in: &bag)

        viewModel
            .channelUpdated
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: configure)
            .store(in: &bag)
    }

    private func configure(_ video: Video?) {
        guard let video = video else { return }
        title = video.snippet.title
        nameLabel.text = video.snippet.title
        descriptionLabel.text = video.snippet.description
        webView.loadHTMLString(processedHtmlEmbed(video.player), baseURL: nil)
        guard let url = video.snippet.thumbnails[.standard]?.url else { return }
        imageView.af.setImage(withURL: url)
    }

    private func processedHtmlEmbed(_ player: Video.Player) -> String {
        var finalEmbedString = ""
        finalEmbedString.append("<html><body style=\"margin:0\">")
        let fixScheme = player.embedHtml.replacingOccurrences(of: "src=\"//www", with: "src=\"https://www")
        let fixWidth = fixScheme.replacingOccurrences(of: "width=\"\(player.embedWidth ?? 480)\"", with: "width=\"100%\"")
        let fixHeight = fixWidth.replacingOccurrences(of: "height=\"\(player.embedWidth ?? 270)\"", with: "height=\"100%\"")
        finalEmbedString.append(fixHeight)
        finalEmbedString.append("</body></html>")
        return finalEmbedString
    }

    private func configure(_ channel: Channel?) {
        guard let channel = channel, let url = channel.snippet.thumbnails[.default]?.url else { return }
        iconImageView.af.setImage(withURL: url)
    }
}
