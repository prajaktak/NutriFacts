// MockVisionAnalysisService.swift
// NutriFactsTests

import UIKit
@testable import NutriFacts

final class MockVisionAnalysisService: VisionAnalysisServiceProtocol {
    private let ocrText: String?
    private let foodLabel: String?

    init(ocrText: String?, foodLabel: String?) {
        self.ocrText = ocrText
        self.foodLabel = foodLabel
    }

    func extractText(from image: UIImage) async -> String? {
        ocrText
    }

    func classifyFood(from image: UIImage) async -> String? {
        foodLabel
    }
}
