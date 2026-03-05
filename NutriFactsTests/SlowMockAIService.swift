// SlowMockAIService.swift
// NutriFactsTests

import UIKit
@testable import NutriFacts

/// A test double for AIServiceProtocol that suspends until complete(with:) is called.
/// Used to capture in-progress state before the service responds.
final class SlowMockAIService: AIServiceProtocol {

    private var continuation: CheckedContinuation<NutritionFacts, Error>?
    private var pendingResult: Result<NutritionFacts, Error>?

    func lookupNutrition(query: String) async throws -> NutritionFacts {
        try await withCheckedThrowingContinuation { continuation in
            if let result = pendingResult {
                pendingResult = nil
                continuation.resume(with: result)
            } else {
                self.continuation = continuation
            }
        }
    }

    func lookupNutrition(image: UIImage) async throws -> NutritionFacts {
        try await lookupNutrition(query: "photo")
    }

    /// Resolves the suspended call with the given result.
    func complete(with result: Result<NutritionFacts, Error>) {
        if let continuation {
            self.continuation = nil
            continuation.resume(with: result)
        } else {
            pendingResult = result
        }
    }
}
