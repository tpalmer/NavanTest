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
    @Published var isLoading: Bool = false

    var networkClient: NetworkClient
    private var reachability: NetworkReachability
    private var cancellables: Set<AnyCancellable> = []

    // Allow dependency injection
    init(networkClient: NetworkClient = NetworkClient(), reachability: NetworkReachability = DefaultNetworkReachability()) {
        self.networkClient = networkClient
        self.reachability = reachability
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
                } else if self?.posts.isEmpty ?? true {
                    // Fetch posts only if they haven't been loaded yet
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

        isLoading = true

        networkClient.requestDecodable(from: "https://jsonplaceholder.typicode.com/posts", method: .GET) { [weak self] (result: Result<[Post], NetworkError>) in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let posts):
                    self?.posts = posts
                    if posts.isEmpty {
                        self?.updateErrorMessage("No posts available")
                    } else {
                        self?.updateErrorMessage(nil)
                    }
                case .failure(let error):
                    self?.handleError(error)
                }
            }
        }
    }

    private func updateErrorMessage(_ message: String?) {
        if let message = message {
            self.errorMessage = NetworkErrorMessage(message: message)
        } else {
            self.errorMessage = nil
        }
    }

    private func handleError(_ error: NetworkError) {
        let message: String
        switch error {
        case .noNetwork:
            message = "No Internet Connection"
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
