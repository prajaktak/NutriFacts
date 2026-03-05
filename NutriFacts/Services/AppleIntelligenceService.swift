// AppleIntelligenceService.swift
// NutriFacts

import UIKit
import FoundationModels

/// Apple Intelligence offline AI service using the FoundationModels framework.
/// Falls back to Vision-based image analysis for photo input.
final class AppleIntelligenceService: AIServiceProtocol {

    // MARK: - Testability

    /// Used to override real availability in unit tests.
    enum ModelAvailability {
        case available
        case unavailable
    }

    // MARK: - Private types

    @Generable(description: "Nutrition facts for a food or product per 100g or 100ml")
    fileprivate struct GenerableNutritionFacts {
        @Guide(description: "Common product name")
        var productName: String

        @Guide(description: "True if the food is a liquid (per 100ml), false if solid (per 100g)")
        var isLiquid: Bool

        @Guide(description: "Calories in kcal")
        var calories: Double

        @Guide(description: "Total fat in grams")
        var totalFat: Double

        @Guide(description: "Saturated fat in grams")
        var saturatedFat: Double

        @Guide(description: "Trans fat in grams")
        var transFat: Double

        @Guide(description: "Total carbohydrates in grams")
        var carbohydrates: Double

        @Guide(description: "Sugar in grams")
        var sugar: Double

        @Guide(description: "Dietary fiber in grams")
        var dietaryFiber: Double

        @Guide(description: "Protein in grams")
        var protein: Double

        @Guide(description: "Vitamin C in mg, -1 if unknown")
        var vitaminCMg: Double

        @Guide(description: "Potassium in mg, -1 if unknown")
        var potassiumMg: Double

        @Guide(description: "Allergens present, empty array if none")
        var allergens: [String]

        @Guide(description: "Ingredient list text, empty string if not available")
        var ingredients: String
    }

    // MARK: - Dependencies

    private let overriddenAvailability: ModelAvailability?
    private let visionService: VisionAnalysisServiceProtocol

    // MARK: - Init

    /// Designated initialiser for production use.
    convenience init() {
        self.init(availability: nil, visionService: VisionAnalysisService())
    }

    /// Initialiser for unit testing — lets tests inject availability and a mock Vision service.
    init(
        availability: ModelAvailability? = nil,
        visionService: VisionAnalysisServiceProtocol = VisionAnalysisService()
    ) {
        self.overriddenAvailability = availability
        self.visionService = visionService
    }

    // MARK: - AIServiceProtocol

    func lookupNutrition(query: String) async throws -> NutritionFacts {
        guard isAvailable else { throw AppError.aiUnavailable }
        return try await generateNutritionFacts(for: query)
    }

    func lookupNutrition(image: UIImage) async throws -> NutritionFacts {
        guard isAvailable else { throw AppError.aiUnavailable }

        // Build a text query from Vision analysis results.
        let ocrText = await visionService.extractText(from: image)
        let foodLabel = await visionService.classifyFood(from: image)

        let query: String
        if let text = ocrText, !text.isEmpty {
            query = "Nutrition label text: \(text)"
        } else if let label = foodLabel, !label.isEmpty {
            query = label
        } else {
            throw AppError.aiUnavailable
        }

        return try await generateNutritionFacts(for: query)
    }

    // MARK: - Private helpers

    private var isAvailable: Bool {
        if let overridden = overriddenAvailability {
            return overridden == .available
        }
        if case .available = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }

    private func generateNutritionFacts(for query: String) async throws -> NutritionFacts {
        let session = LanguageModelSession(
            instructions: """
            You are a nutrition expert. Return accurate nutrition facts per 100g or 100ml \
            for the food or product described. Use standard reference values. \
            If a value is unknown, use -1 for numeric fields and empty string for text fields.
            """
        )

        let response = try await session.respond(
            to: "Provide nutrition facts for: \(query)",
            generating: GenerableNutritionFacts.self
        )

        return mapToNutritionFacts(response.content)
    }

    private func mapToNutritionFacts(_ generated: GenerableNutritionFacts) -> NutritionFacts {
        let macros = Macronutrients(
            calories: generated.calories,
            totalFat: generated.totalFat,
            saturatedFat: generated.saturatedFat,
            transFat: generated.transFat,
            carbohydrates: generated.carbohydrates,
            sugar: generated.sugar,
            dietaryFiber: generated.dietaryFiber,
            protein: generated.protein
        )

        var vitamins: [NutrientItem] = []
        if generated.vitaminCMg >= 0 {
            vitamins.append(NutrientItem(id: UUID(), nutrientName: "Vitamin C",
                                         nutrientAmount: generated.vitaminCMg, nutrientUnit: "mg"))
        }

        var minerals: [NutrientItem] = []
        if generated.potassiumMg >= 0 {
            minerals.append(NutrientItem(id: UUID(), nutrientName: "Potassium",
                                          nutrientAmount: generated.potassiumMg, nutrientUnit: "mg"))
        }

        return NutritionFacts(
            productName: generated.productName,
            isLiquid: generated.isLiquid,
            macronutrients: macros,
            vitamins: vitamins,
            minerals: minerals,
            allergens: generated.allergens,
            ingredients: generated.ingredients.isEmpty ? nil : generated.ingredients
        )
    }
}
