//
//  Request.swift
//  YouTube
//
//  Created by Josh Kowarsky on 9/20/20.
//

import Alamofire
import Combine

enum RequestError: Error {
    case createURLError
}

public protocol Request: URLRequestConvertible {
    var hostURLString: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters { get }
    var headers: HTTPHeaders? { get }
    var isAuthenticated: Bool { get }
    func refreshTokenIfNecessary() -> AnyPublisher<Request, Error>
}


extension Request {
    public func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: hostURLString) else {
            throw RequestError.createURLError
        }
        components.path = "\(components.path)/\(path)"
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
        let url = try components.asURL()
        return try URLRequest(url: url, method: method, headers: headers)
    }

    func refreshTokenIfNecessary() -> AnyPublisher<Request, Error> {
        return Just(self).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
