//
//  MockPostViewModel.swift
//  NavanTestTests
//
//  Created by Travis Palmer on 8/5/24.
//

import Combine
@testable import NavanTest

class MockPostViewModel: PostViewModel {
    init(networkClient: MockNetworkClient, reachability: MockNetworkReachability) {
        super.init(networkClient: networkClient, reachability: reachability)
    }
}
