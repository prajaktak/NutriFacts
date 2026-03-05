// MacroPieSlice.swift
// NutriFacts

import SwiftUI

/// A single segment in the macro pie chart, representing one macronutrient.
struct MacroPieSlice: Identifiable {
    let id: UUID
    let macroLabel: String
    let gramValue: Double
    let sliceColor: Color

    /// Builds the three chart slices (Carbs, Protein, Fat) from a Macronutrients value.
    static func slices(from macronutrients: Macronutrients) -> [MacroPieSlice] {
        [
            MacroPieSlice(
                id: UUID(),
                macroLabel: "Carbs",
                gramValue: macronutrients.carbohydrates,
                sliceColor: ThemeColor.carbohydrates
            ),
            MacroPieSlice(
                id: UUID(),
                macroLabel: "Protein",
                gramValue: macronutrients.protein,
                sliceColor: ThemeColor.protein
            ),
            MacroPieSlice(
                id: UUID(),
                macroLabel: "Fat",
                gramValue: macronutrients.totalFat,
                sliceColor: ThemeColor.fat
            )
        ]
    }
}
