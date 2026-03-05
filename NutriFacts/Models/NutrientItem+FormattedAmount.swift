// NutrientItem+FormattedAmount.swift
// NutriFacts

import Foundation

extension NutrientItem {
    /// The nutrient amount formatted as a string with its unit.
    /// Whole numbers show no decimal places; others show one decimal place.
    var formattedAmount: String {
        let formattedValue = nutrientAmount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(nutrientAmount))
            : String(format: "%.1f", nutrientAmount)
        return "\(formattedValue) \(nutrientUnit)"
    }
}
