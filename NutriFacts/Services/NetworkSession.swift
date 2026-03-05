// NetworkSession.swift
// NutriFacts

import Foundation

/// Abstraction over URLSession to allow injecting mock sessions in tests.
protocol NetworkSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
