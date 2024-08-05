//
//  NetworkClient.swift
//  NavanTest
//
//  Created by Travis Palmer on 8/5/24.
//

import Foundation
import Combine

// Define HTTP methods
enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

// Define network errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCodeError(Int)
    case noData
    case decodingError
    case noNetwork
}

// Network client to perform API requests
class NetworkClient {
    private let session: URLSession
    private var reachabilitySubscription: AnyCancellable?
    private var isNetworkAvailable = false

    init(session: URLSession = .shared, reachability: NetworkReachability = DefaultNetworkReachability()) {
        self.session = session
        self.reachabilitySubscription = reachability.isNetworkAvailable
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isAvailable in
                self?.isNetworkAvailable = isAvailable
                print("Network availability updated: \(isAvailable)")
            })
    }

    private func performRequest(with urlString: String, method: HTTPMethod, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard isNetworkAvailable else {
            completion(.failure(.noNetwork))
            print("❌ No network connection available")
            return
        }

        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            print("❌ Invalid URL: \(urlString)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        // Log the request
        Logger.logRequest(request)

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Request failed with error: \(error.localizedDescription)")
                completion(.failure(.invalidResponse))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                print("❌ Invalid response received")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.statusCodeError(httpResponse.statusCode)))
                print("❌ HTTP status code error: \(httpResponse.statusCode)")
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                print("❌ No data received")
                return
            }

            // Log the response
            Logger.logResponse(httpResponse, data: data)

            completion(.success(data))
        }

        task.resume()
    }

    func requestData(from urlString: String, method: HTTPMethod, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        performRequest(with: urlString, method: method, completion: completion)
    }

    func requestDecodable<T: Decodable>(from urlString: String, method: HTTPMethod, completion: @escaping (Result<T, NetworkError>) -> Void) {
        performRequest(with: urlString, method: method) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                    print("✅ Decoding successful for type: \(T.self)")
                } catch {
                    completion(.failure(.decodingError))
                    print("❌ Decoding error: \(error.localizedDescription)")
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func requestVoid(from urlString: String, method: HTTPMethod, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        performRequest(with: urlString, method: method) { result in
            switch result {
            case .success:
                completion(.success(()))
                print("✅ Request completed with no data required.")
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
