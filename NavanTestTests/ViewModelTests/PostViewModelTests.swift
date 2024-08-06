//
//  PostViewModelTests.swift
//  NavanTestTests
//
//  Created by Travis Palmer on 8/5/24.
//

import XCTest
import Combine
@testable import NavanTest

class PostViewModelTests: XCTestCase {
    var viewModel: MockPostViewModel!
    var session: URLSession!
    var mockNetworkClient: MockNetworkClient!
    var mockReachability: MockNetworkReachability!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        // Configure the session with MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)

        mockReachability = MockNetworkReachability(isReachable: true)
        mockNetworkClient = MockNetworkClient(session: session, reachability: mockReachability)
        
        viewModel = MockPostViewModel(networkClient: mockNetworkClient, reachability: mockReachability)
//        viewModel.networkClient = mockNetworkClient
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkClient = nil
        mockReachability = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchPostsSuccess() {
        // Arrange
        let postData = """
        [
            {
                "userId": 1,
                "id": 1,
                "title": "Test Title",
                "body": "Test Body"
            }
        ]
        """.data(using: .utf8)
        
        mockNetworkClient.result = .success(postData!)
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch posts succeeds")
        
        viewModel.$posts
            .dropFirst() // Ignore the initial value
            .sink { posts in
                // Assert
                XCTAssertEqual(posts.count, 1)
                XCTAssertEqual(posts.first?.title, "Test Title")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchPosts()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchPostsFailure() {
        // Arrange
        mockNetworkClient.result = .failure(.statusCodeError(500))
        
        // Act
        let expectation = XCTestExpectation(description: "Fetch posts fails")
        
        viewModel.$errorMessage
            .dropFirst() // Ignore the initial value
            .sink { errorMessage in
                // Assert
                XCTAssertEqual(errorMessage?.message, "Received error code: 500")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.fetchPosts()
        
        wait(for: [expectation], timeout: 1.0)
    }
}
