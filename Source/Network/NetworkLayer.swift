//
//  NetworkLayer.swift
//  CardForm
//
//  Created by Juan sebastian Sanzone on 10/30/19.
//  Copyright © 2019 JS. All rights reserved.
//

import Foundation

enum NetworkLayerError: Error {
    case dataTask
    case data
    case response
    case statusCode(status: Int, message: String)
    case noInternetConnection
}

extension NetworkLayerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .statusCode(status: _, message: let message):
            return message
        default:
            return "Algo salió mal.".localized
        }
    }
}

extension NetworkLayerError: CustomNSError {
    public static var errorDomain: String {
        return "MLCardForm"
    }
    
    public var errorCode: Int {
        switch self {
        case .statusCode(status: let status, message: _):
            return status
        default:
            return 0
        }
    }
    
    public var errorUserInfo: [String : Any] {
        if let errorDescription = errorDescription {
            return ["message": errorDescription]
        }
        return [:]
    }
}

struct NetworkLayer {
    static func request<T: Codable>(router: MLCardFormApiRouter, completion: @escaping (Result<T, Error>) -> ()) {
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.path = router.path
        components.queryItems = router.parameters

        guard let url = components.url else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method

        if let method = urlRequest.httpMethod, method == "POST" {
            urlRequest.httpBody = router.body
        }

        if let headers = router.headers {
            headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        }

        let session = URLSession(configuration: .default)

        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(error ?? NetworkLayerError.dataTask))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkLayerError.data))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkLayerError.response))
                return
            }
            guard (200...299).contains(response.statusCode) else {
                var message = ""
                do {
                    let responseData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                    if let responseMessage = responseData?["message"] as? String {
                        message = responseMessage
                    }
                } catch let error as NSError {
                    print(error)
                }
                completion(.failure(NetworkLayerError.statusCode(status: response.statusCode, message: message)))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let responseObject = try decoder.decode(T.self, from: data)
                completion(.success(responseObject))
            } catch let error {
                completion(.failure(error))
                print(error.localizedDescription)
            }
        }

        dataTask.resume()
    }

    static func request(imageUrl: String, success: ((UIImage)->Void)?) {
        guard let url = URL(string: imageUrl) else { return }
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            success?(image)
            #if DEBUG
            print("Retrieve image from Cache")
            #endif
        } else {
            let session = URLSession(configuration: .default)
            session.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                    #if DEBUG
                    print("Retrieve image from Network")
                    #endif
                    success?(image)
                }
            }).resume()
        }
    }
}
