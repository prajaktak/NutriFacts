// AIServiceProtocol.swift
// NutriFacts

import UIKit

/// Defines the contract for any AI provider used to look up nutrition facts.
/// Concrete implementations (OpenAI, Apple Intelligence) conform to this protocol,
/// enabling the ViewModel to depend on an abstraction rather than a concrete type.
protocol AIServiceProtocol {
    func lookupNutrition(query: String) async throws -> NutritionFacts
    func lookupNutrition(image: UIImage) async throws -> NutritionFacts
}
