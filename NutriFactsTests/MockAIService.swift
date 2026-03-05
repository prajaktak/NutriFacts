// MockAIService.swift
// NutriFactsTests

import UIKit
@testable import NutriFacts

/// A test double for AIServiceProtocol that returns a pre-configured result.
final class MockAIService: AIServiceProtocol {

    private let result: Result<NutritionFacts, Error>

    init(result: Result<NutritionFacts, Error>) {
        self.result = result
    }

    func lookupNutrition(query: String) async throws -> NutritionFacts {
        switch result {
        case .success(let nutritionFacts):
            return nutritionFacts
        case .failure(let error):
            throw error
        }
    }

    func lookupNutrition(image: UIImage) async throws -> NutritionFacts {
        switch result {
        case .success(let nutritionFacts):
            return nutritionFacts
        case .failure(let error):
            throw error
        }
    }
}
