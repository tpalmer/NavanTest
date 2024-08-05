//
//  DefaultNetworkReachability.swift
//  NavanTest
//
//  Created by Travis Palmer on 8/5/24.
//

import Foundation
import Network
import Combine

struct NetworkErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

// Define a protocol for network reachability
protocol NetworkReachability {
    var isNetworkAvailable: AnyPublisher<Bool, Never> { get }
}

// Default implementation of NetworkReachability using NWPathMonitor
class DefaultNetworkReachability: NetworkReachability {
    private let monitor: NWPathMonitor
    private let subject: CurrentValueSubject<Bool, Never>
    private let queue: DispatchQueue

    init() {
        self.monitor = NWPathMonitor()
        self.subject = CurrentValueSubject<Bool, Never>(false)
        self.queue = DispatchQueue(label: "NetworkReachabilityQueue")
        startMonitoring()
    }

    // Start monitoring network changes
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isReachable = path.status == .satisfied
            self?.subject.send(isReachable)
            DispatchQueue.main.async {
                print(isReachable ? "Network is available" : "Network is unavailable")
            }
        }

        monitor.start(queue: queue)
    }

    // Public publisher for network availability
    var isNetworkAvailable: AnyPublisher<Bool, Never> {
        return subject.eraseToAnyPublisher()
    }

    deinit {
        stopMonitoring()
    }

    // Stop monitoring when the object is deallocated
    private func stopMonitoring() {
        monitor.cancel()
    }
}
