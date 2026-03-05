// VisionAnalysisServiceProtocol.swift
// NutriFacts

import UIKit

/// Protocol for image analysis services that extract text and classify food items.
protocol VisionAnalysisServiceProtocol {
    /// Returns OCR-extracted text from a nutrition label image, or nil if none found.
    func extractText(from image: UIImage) async -> String?
    /// Returns a food label description for an image, or nil if not identifiable.
    func classifyFood(from image: UIImage) async -> String?
}
