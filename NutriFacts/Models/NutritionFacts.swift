// NutritionFacts.swift
// NutriFacts

import Foundation

struct NutritionFacts: Codable {
    let productName: String
    let isLiquid: Bool              // true → display "per 100ml", false → "per 100g"
    let macronutrients: Macronutrients
    let vitamins: [NutrientItem]
    let minerals: [NutrientItem]
    let allergens: [String]
    let ingredients: String?        // nil when not available
}
