// Macronutrients.swift
// NutriFacts

import Foundation

struct Macronutrients: Codable {
    let calories: Double        // kcal per 100g or 100ml
    let totalFat: Double        // grams
    let saturatedFat: Double    // grams
    let transFat: Double        // grams
    let carbohydrates: Double   // grams
    let sugar: Double           // grams
    let dietaryFiber: Double    // grams
    let protein: Double         // grams
}
