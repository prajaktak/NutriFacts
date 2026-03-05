// DetailsTabView.swift
// NutriFacts

import SwiftUI

/// Tab 2 of ResultsView: full macronutrients, vitamins, minerals, allergens, ingredients.
/// Full implementation: ISSUE-07.
struct DetailsTabView: View {

    let nutritionFacts: NutritionFacts

    var body: some View {
        Text("Full Details — \(nutritionFacts.productName)")
            .foregroundStyle(ThemeColor.secondaryLabel)
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
        vitamins: [], minerals: [], allergens: [], ingredients: nil
    ))
}
