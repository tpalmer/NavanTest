//
//  NetworkClientTests.swift
//  NavanTestTests
//
//  Created by Travis Palmer on 8/5/24.
//

import XCTest
import Combine
@testable import NavanTest

class NetworkClientTests: XCTestCase {
    var networkClient: MockNetworkClient!
    var session: URLSession!
    var mockReachability: MockNetworkReachability!

    override func setUp() {
        super.setUp()

        // Configure the session with MockURLProtocol
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)

        // Set up the mock reachability
        mockReachability = MockNetworkReachability(isReachable: true)
        
        // Initialize the mock network client with the mock reachability
        networkClient = MockNetworkClient(session: session, reachability: mockReachability)
    }

    override func tearDown() {
        networkClient = nil
        session = nil
        mockReachability = nil
        super.tearDown()
    }

    func testRequestDecodableSuccess() {
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

        networkClient.result = .success(postData!)

        // Act
        let expectation = XCTestExpectation(description: "Decodable request succeeds")
        networkClient.requestDecodable(from: "https://jsonplaceholder.typicode.com/posts", method: .GET) { (result: Result<[Post], NetworkError>) in
            // Assert
            switch result {
            case .success(let posts):
                XCTAssertEqual(posts.count, 1)
                XCTAssertEqual(posts.first?.title, "Test Title")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testRequestDecodableFailure() {
        // Arrange
        networkClient.result = .failure(.statusCodeError(500))

        // Act
        let expectation = XCTestExpectation(description: "Decodable request fails")
        networkClient.requestDecodable(from: "https://jsonplaceholder.typicode.com/posts", method: .GET) { (result: Result<[Post], NetworkError>) in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error, .statusCodeError(500))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
