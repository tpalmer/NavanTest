//
//  MockNetworkReachability.swift
//  NavanTestTests
//
//  Created by Travis Palmer on 8/5/24.
//

import Combine
@testable import NavanTest

class MockNetworkReachability: NetworkReachability {
    private let isReachableSubject: CurrentValueSubject<Bool, Never>

    init(isReachable: Bool) {
        self.isReachableSubject = CurrentValueSubject<Bool, Never>(isReachable)
    }

    var isNetworkAvailable: AnyPublisher<Bool, Never> {
        return isReachableSubject.eraseToAnyPublisher()
    }
    
    var currentValue: Bool {
        return isReachableSubject.value
    }

    func setReachable(_ reachable: Bool) {
        isReachableSubject.send(reachable)
    }
}
