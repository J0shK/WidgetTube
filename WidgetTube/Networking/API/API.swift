//
//  API.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Alamofire
import Combine

struct API {
    func request(_ request: Request) -> AnyPublisher<Data, Swift.Error> {
        guard request.isAuthenticated else {
            return performRequest(request).eraseToAnyPublisher()
        }
        return request
            .refreshTokenIfNecessary()
            .flatMap(performRequest)
            .eraseToAnyPublisher()
    }

    private func performRequest(_ request: Request) -> AnyPublisher<Data, Swift.Error> {
        return Future<Data, Swift.Error> { observer in
            AF.request(URL(string: "\(request.hostURLString)/\(request.path)")!, method: request.method, parameters: request.parameters, headers: request.headers).responseData { response in
                switch response.result {
                case .success(let data):
                    if let errorWrapper = try? JSONDecoder().decode(YTErrorWrapper.self, from: data) {
                        observer(.failure(errorWrapper.error))
                        return
                    }
                    observer(.success(data))
                case .failure(let error):
                    observer(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
