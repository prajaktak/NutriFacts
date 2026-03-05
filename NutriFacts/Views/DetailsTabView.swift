// DetailsTabView.swift
// NutriFacts

import SwiftUI

/// Tab 2 of ResultsView: full macronutrient breakdown, vitamins, minerals, allergens, and ingredients.
/// Uses SwiftUI List with insetGrouped style for native iOS appearance.
struct DetailsTabView: View {

    let nutritionFacts: NutritionFacts

    var body: some View {
        List {
            macronutrientsSection
            vitaminsSection
            mineralsSection
            allergensSection
            ingredientsSection
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Sections

    private var macronutrientsSection: some View {
        Section("Macronutrients") {
            let macros = nutritionFacts.macronutrients
            nutrientRow(name: "Calories", value: formatValue(macros.calories), unit: "kcal")
            nutrientRow(name: "Total Fat", value: formatValue(macros.totalFat), unit: "g")
            nutrientRow(name: "Saturated Fat", value: formatValue(macros.saturatedFat), unit: "g", isIndented: true)
            nutrientRow(name: "Trans Fat", value: formatValue(macros.transFat), unit: "g", isIndented: true)
            nutrientRow(name: "Carbohydrates", value: formatValue(macros.carbohydrates), unit: "g")
            nutrientRow(name: "Sugar", value: formatValue(macros.sugar), unit: "g", isIndented: true)
            nutrientRow(name: "Dietary Fiber", value: formatValue(macros.dietaryFiber), unit: "g", isIndented: true)
            nutrientRow(name: "Protein", value: formatValue(macros.protein), unit: "g")
        }
    }

    @ViewBuilder
    private var vitaminsSection: some View {
        if !nutritionFacts.vitamins.isEmpty {
            Section("Vitamins") {
                ForEach(nutritionFacts.vitamins) { vitamin in
                    nutrientItemRow(vitamin)
                }
            }
        }
    }

    @ViewBuilder
    private var mineralsSection: some View {
        if !nutritionFacts.minerals.isEmpty {
            Section("Minerals") {
                ForEach(nutritionFacts.minerals) { mineral in
                    nutrientItemRow(mineral)
                }
            }
        }
    }

    private var allergensSection: some View {
        Section("Allergens") {
            let isNoneDetected = nutritionFacts.allergens.isEmpty
            Text(nutritionFacts.allergensDisplayText)
                .foregroundStyle(isNoneDetected ? ThemeColor.secondaryLabel : ThemeColor.error)
        }
    }

    private var ingredientsSection: some View {
        Section("Ingredients") {
            Text(nutritionFacts.ingredients ?? "Not available")
                .foregroundStyle(
                    nutritionFacts.ingredients != nil ? ThemeColor.label : ThemeColor.secondaryLabel
                )
        }
    }

    // MARK: - Row Builders

    @ViewBuilder
    private func nutrientRow(name: String, value: String, unit: String, isIndented: Bool = false) -> some View {
        HStack {
            Text(isIndented ? "— \(name)" : name)
                .foregroundStyle(ThemeColor.label)
            Spacer()
            Text("\(value) \(unit)")
                .foregroundStyle(ThemeColor.secondaryLabel)
        }
    }

    @ViewBuilder
    private func nutrientItemRow(_ item: NutrientItem) -> some View {
        HStack {
            Text(item.nutrientName)
                .foregroundStyle(ThemeColor.label)
            Spacer()
            Text(item.formattedAmount)
                .foregroundStyle(ThemeColor.secondaryLabel)
        }
    }

    // MARK: - Helpers

    /// Formats a macro value — whole numbers with no decimal, others with one decimal place.
    private func formatValue(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

#Preview {
    DetailsTabView(nutritionFacts: NutritionFacts(
        productName: "Apple",
        isLiquid: false,
        macronutrients: Macronutrients(
            calories: 52, totalFat: 0.2, saturatedFat: 0.0,
            transFat: 0.0, carbohydrates: 14, sugar: 10,
            dietaryFiber: 2.4, protein: 0.3
        ),
        vitamins: [
            NutrientItem(id: UUID(), nutrientName: "Vitamin C", nutrientAmount: 5.1, nutrientUnit: "mg"),
            NutrientItem(id: UUID(), nutrientName: "Vitamin B6", nutrientAmount: 0.04, nutrientUnit: "mg")
        ],
        minerals: [
            NutrientItem(id: UUID(), nutrientName: "Potassium", nutrientAmount: 107, nutrientUnit: "mg"),
            NutrientItem(id: UUID(), nutrientName: "Phosphorus", nutrientAmount: 11, nutrientUnit: "mg")
        ],
        allergens: [],
        ingredients: "Apple."
    ))
}
