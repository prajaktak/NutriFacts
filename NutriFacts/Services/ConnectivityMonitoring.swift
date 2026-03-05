// ConnectivityMonitoring.swift
// NutriFacts

/// Protocol for observing network reachability.
protocol ConnectivityMonitoring {
    /// True when a usable network path is available.
    var isOnline: Bool { get }
}
