// OverviewTabView.swift
// NutriFacts

import SwiftUI
import Charts

/// Tab 1 of ResultsView: donut pie chart of macros and a 2×2 macro summary grid.
struct OverviewTabView: View {

    let nutritionFacts: NutritionFacts

    private var pieSlices: [MacroPieSlice] {
        MacroPieSlice.slices(from: nutritionFacts.macronutrients)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                macroChart
                macroLegend
                macroSummaryGrid
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Subviews

    private var macroChart: some View {
        Chart(pieSlices) { slice in
            SectorMark(
                angle: .value("Grams", max(slice.gramValue, 0.01)),
                innerRadius: .ratio(0.55),
                angularInset: 2
            )
            .foregroundStyle(slice.sliceColor)
            .cornerRadius(4)
        }
        .frame(height: 220)
        .accessibilityLabel(chartAccessibilityDescription)
    }

    private var macroLegend: some View {
        HStack(spacing: 20) {
            ForEach(pieSlices) { slice in
                HStack(spacing: 6) {
                    Circle()
                        .fill(slice.sliceColor)
                        .frame(width: 10, height: 10)
                    Text(slice.macroLabel)
                        .font(.caption)
                        .foregroundStyle(ThemeColor.secondaryLabel)
                }
            }
        }
    }

    private var macroSummaryGrid: some View {
        let macros = nutritionFacts.macronutrients
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            MacroSummaryCardView(
                cardTitle: "Calories",
                cardValue: formatMacroValue(macros.calories),
                cardUnit: "kcal"
            )
            MacroSummaryCardView(
                cardTitle: "Fat",
                cardValue: formatMacroValue(macros.totalFat),
                cardUnit: "g"
            )
            MacroSummaryCardView(
                cardTitle: "Carbs",
                cardValue: formatMacroValue(macros.carbohydrates),
                cardUnit: "g"
            )
            MacroSummaryCardView(
                cardTitle: "Protein",
                cardValue: formatMacroValue(macros.protein),
                cardUnit: "g"
            )
        }
    }

    // MARK: - Helpers

    /// Formats a macro gram value — shows no decimal places for whole numbers.
    private func formatMacroValue(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }

    /// Accessibility text describing the macro breakdown.
    private var chartAccessibilityDescription: String {
        let macros = nutritionFacts.macronutrients
        return "Macro breakdown: \(formatMacroValue(macros.carbohydrates)) grams carbs, " +
               "\(formatMacroValue(macros.protein)) grams protein, " +
               "\(formatMacroValue(macros.totalFat)) grams fat."
    }
}

#Preview {
    OverviewTabView(nutritionFacts: NutritionFacts(
        productName: "Apple",
        isLiquid: false,
        macronutrients: Macronutrients(
            calories: 52, totalFat: 0.2, saturatedFat: 0.0,
            transFat: 0.0, carbohydrates: 14, sugar: 10,
            dietaryFiber: 2.4, protein: 0.3
        ),
        vitamins: [], minerals: [], allergens: [], ingredients: nil
    ))
}
