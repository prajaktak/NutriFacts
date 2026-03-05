// MockURLSession.swift
// NutriFactsTests

import Foundation
@testable import NutriFacts

/// A mock NetworkSession that returns pre-configured responses without network calls.
final class MockNetworkSession: NetworkSession, @unchecked Sendable {
    private let responseData: Data
    private let statusCode: Int

    init(responseData: Data, statusCode: Int = 200) {
        self.responseData = responseData
        self.statusCode = statusCode
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://api.openai.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        return (responseData, response)
    }
}
