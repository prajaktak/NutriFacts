// MockConnectivityMonitor.swift
// NutriFactsTests

@testable import NutriFacts

/// A test double for ConnectivityMonitoring with a fixed online state.
final class MockConnectivityMonitor: ConnectivityMonitoring {
    private(set) var isOnline: Bool

    init(isOnline: Bool) {
        self.isOnline = isOnline
    }
}
