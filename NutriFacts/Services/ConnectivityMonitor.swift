// ConnectivityMonitor.swift
// NutriFacts

import Network

/// Monitors network reachability using NWPathMonitor.
final class ConnectivityMonitor: ConnectivityMonitoring {

    private(set) var isOnline: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.nutrifacts.connectivity")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isOnline = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
