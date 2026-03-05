// AppleIntelligenceService.swift
// NutriFacts

import UIKit

/// Stub for the Apple Intelligence offline service.
/// Full implementation is in ISSUE-14 using the FoundationModels framework.
final class AppleIntelligenceService: AIServiceProtocol {

    func lookupNutrition(query: String) async throws -> NutritionFacts {
        throw AppError.aiUnavailable
    }

    func lookupNutrition(image: UIImage) async throws -> NutritionFacts {
        throw AppError.aiUnavailable
    }
}
