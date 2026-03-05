// OverviewTabView.swift
// NutriFacts

import SwiftUI

/// Tab 1 of ResultsView: pie chart and macro summary cards.
/// Full implementation: ISSUE-06.
struct OverviewTabView: View {

    let nutritionFacts: NutritionFacts

    var body: some View {
        Text("Overview — \(nutritionFacts.productName)")
            .foregroundStyle(ThemeColor.secondaryLabel)
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
