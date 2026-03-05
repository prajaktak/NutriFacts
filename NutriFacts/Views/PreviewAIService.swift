// PreviewAIService.swift
// NutriFacts

import UIKit

/// A lightweight AIServiceProtocol implementation used exclusively in SwiftUI previews.
/// Returns a fixed NutritionFacts response after a brief simulated delay.
final class PreviewAIService: AIServiceProtocol {

    private let previewNutritionFacts = NutritionFacts(
        productName: "Apple",
        isLiquid: false,
        macronutrients: Macronutrients(
            calories: 52,
            totalFat: 0.2,
            saturatedFat: 0.0,
            transFat: 0.0,
            carbohydrates: 14,
            sugar: 10,
            dietaryFiber: 2.4,
            protein: 0.3
        ),
        vitamins: [
            NutrientItem(id: UUID(), nutrientName: "Vitamin C", nutrientAmount: 5.1, nutrientUnit: "mg"),
            NutrientItem(id: UUID(), nutrientName: "Vitamin B6", nutrientAmount: 0.04, nutrientUnit: "mg")
        ],
        minerals: [
            NutrientItem(id: UUID(), nutrientName: "Potassium", nutrientAmount: 107, nutrientUnit: "mg"),
            NutrientItem(id: UUID(), nutrientName: "Phosphorus", nutrientAmount: 11, nutrientUnit: "mg")
        ],
        allergens: [],
        ingredients: nil
    )

    func lookupNutrition(query: String) async throws -> NutritionFacts {
        try await Task.sleep(for: .milliseconds(500))
        return previewNutritionFacts
    }

    func lookupNutrition(image: UIImage) async throws -> NutritionFacts {
        try await Task.sleep(for: .milliseconds(500))
        return previewNutritionFacts
    }
}
