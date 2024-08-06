//
//  MockNetworkClient.swift
//  NavanTestTests
//
//  Created by Travis Palmer on 8/5/24.
//

import Foundation
import Combine
@testable import NavanTest

class MockNetworkClient: NetworkClient {
    var result: Result<Data, NetworkError>?
    private let mockReachability: MockNetworkReachability

    init(session: URLSession, reachability: MockNetworkReachability) {
        self.mockReachability = reachability
        super.init(session: session, reachability: reachability)
    }

    func setNetworkAvailable(_ available: Bool) {
        mockReachability.setReachable(available)
    }
    
    override var isNetworkAvailable: Bool {
        return mockReachability.currentValue
    }

    override func requestDecodable<T>(from urlString: String, method: HTTPMethod, completion: @escaping (Result<T, NetworkError>) -> Void) where T: Decodable {
        guard isNetworkAvailable else {
            completion(.failure(.noNetwork))
            return
        }

        guard let result = result else {
            completion(.failure(.invalidResponse))
            return
        }

        switch result {
        case .success(let data):
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decodingError))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
