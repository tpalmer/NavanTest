//
//  PostViewModel.swift
//  NavanTest
//
//  Created by Travis Palmer on 8/5/24.
//

import Foundation
import Combine

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var errorMessage: NetworkErrorMessage? = nil
    @Published var isConnected: Bool = false

    private var networkClient = NetworkClient()
    private var reachability: DefaultNetworkReachability
    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.reachability = DefaultNetworkReachability()
        setupNetworkMonitor()
        fetchPosts()
    }

    private func setupNetworkMonitor() {
        reachability.isNetworkAvailable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
                if !isConnected {
                    self?.updateErrorMessage("No Internet Connection")
                } else {
                    self?.updateErrorMessage(nil) // Clear error when connected
                    self?.fetchPosts()
                }
            }
            .store(in: &cancellables)
    }

    func fetchPosts() {
        guard isConnected else {
            updateErrorMessage("No Internet Connection")
            return
        }

        networkClient.requestDecodable(from: "https://jsonplaceholder.typicode.com/posts", method: .GET) { [weak self] (result: Result<[Post], NetworkError>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let posts):
                    self?.posts = posts
                    self?.updateErrorMessage(nil) // Clear any previous error messages
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }

    private func updateErrorMessage(_ message: String?) {
        DispatchQueue.main.async {
            if let message = message {
                self.errorMessage = NetworkErrorMessage(message: message)
            } else {
                self.errorMessage = nil
            }
        }
    }

    private func handleError(_ error: NetworkError) {
        let message: String
        switch error {
        case .noNetwork:
            message = "No network connection"
        case .invalidURL:
            message = "Invalid URL"
        case .invalidResponse:
            message = "Invalid response from server"
        case .statusCodeError(let code):
            message = "Received error code: \(code)"
        case .noData:
            message = "No data received"
        case .decodingError:
            message = "Error decoding data"
        }
        updateErrorMessage(message)
        print("Network error occurred: \(message)")
    }
}
