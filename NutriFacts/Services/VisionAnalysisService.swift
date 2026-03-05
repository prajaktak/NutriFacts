// VisionAnalysisService.swift
// NutriFacts

import UIKit
import Vision

/// Performs on-device image analysis using the Vision framework.
/// - OCR via `VNRecognizeTextRequest` for nutrition label scanning.
/// - Food classification via `VNClassifyImageRequest` for food identification.
final class VisionAnalysisService: VisionAnalysisServiceProtocol {

    // MARK: - VisionAnalysisServiceProtocol

    func extractText(from image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, _ in
                let observations = request.results as? [VNRecognizedTextObservation] ?? []
                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                let combined = lines.joined(separator: "\n")
                continuation.resume(returning: combined.isEmpty ? nil : combined)
            }
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }

    func classifyFood(from image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, _ in
                let observations = request.results as? [VNClassificationObservation] ?? []
                // Return the highest-confidence food-related label.
                let topLabel = observations
                    .filter { $0.confidence > 0.3 }
                    .sorted { $0.confidence > $1.confidence }
                    .first?.identifier
                continuation.resume(returning: topLabel)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
}
