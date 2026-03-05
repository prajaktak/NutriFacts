// NutritionFacts+AllergensDisplay.swift
// NutriFacts

import Foundation

extension NutritionFacts {
    /// The allergens list as a display string.
    /// Returns "None detected" when the allergens array is empty.
    var allergensDisplayText: String {
        allergens.isEmpty ? "None detected" : allergens.joined(separator: ", ")
    }
}
