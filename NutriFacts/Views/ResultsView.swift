// ResultsView.swift
// NutriFacts

import SwiftUI

/// Displays nutrition facts after a successful AI lookup.
/// Contains a tab picker switching between OverviewTabView and DetailsTabView.
/// Full implementation: ISSUE-05, ISSUE-06, ISSUE-07.
struct ResultsView: View {

    let nutritionFacts: NutritionFacts

    var body: some View {
        Text("Results for \(nutritionFacts.productName)")
            .navigationTitle(nutritionFacts.productName)
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ResultsView(nutritionFacts: NutritionFacts(
            productName: "Apple",
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 52,
                totalFat: 0.2,
                saturatedFat: 0.0,
                transFat: 0.0,
                carbohydrates: 14,
                sugar: 10,
                dietaryFiber: 2.4,
                protein: 0.3
            ),
            vitamins: [],
            minerals: [],
            allergens: [],
            ingredients: nil
        ))
    }
}
