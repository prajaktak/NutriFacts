// NutrientItem.swift
// NutriFacts

import Foundation

struct NutrientItem: Codable, Identifiable {
    let id: UUID
    let nutrientName: String
    let nutrientAmount: Double
    let nutrientUnit: String
}
