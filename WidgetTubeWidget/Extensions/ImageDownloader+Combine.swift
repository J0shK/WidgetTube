//
//  ImageDownloader+Combine.swift
//  YouTubeWidgetExtension
//
//  Created by Josh Kowarsky on 9/21/20.
//

import AlamofireImage
import Combine

extension ImageDownloader {
    func image(for url: URL, with id: String) -> AnyPublisher<(String, UIImage?), Never> {
        return Future { [weak self] subscriber in
            let urlRequest = URLRequest(url: url)
            self?.download(urlRequest, completion:  { response in
                switch response.result {
                case .failure(let error):
                    print("Download image error: \(error)")
                case .success(let image):
                    print("Got Image")
                    subscriber(.success((id, image)))
                }
            })
        }
        .eraseToAnyPublisher()
    }
}
