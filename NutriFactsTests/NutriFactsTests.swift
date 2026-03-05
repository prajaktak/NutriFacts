// NutriFactsTests.swift
// NutriFactsTests

import Testing
@testable import NutriFacts

// MARK: - NutritionFacts Model Tests

@Suite("NutritionFacts Model")
struct NutritionFactsModelTests {

    @Test("isLiquid is false when set to false")
    func testNutritionFacts_isLiquid_isFalseByDefault() {
        let macronutrients = Macronutrients(
            calories: 52,
            totalFat: 0.2,
            saturatedFat: 0.0,
            transFat: 0.0,
            carbohydrates: 14,
            sugar: 10,
            dietaryFiber: 2.4,
            protein: 0.3
        )
        let nutritionFacts = NutritionFacts(
            productName: "Apple",
            isLiquid: false,
            macronutrients: macronutrients,
            vitamins: [],
            minerals: [],
            allergens: [],
            ingredients: nil
        )
        #expect(nutritionFacts.isLiquid == false)
    }

    @Test("isLiquid is true when set to true")
    func testNutritionFacts_isLiquid_isTrueWhenSet() {
        let macronutrients = Macronutrients(
            calories: 42,
            totalFat: 0.1,
            saturatedFat: 0.0,
            transFat: 0.0,
            carbohydrates: 10,
            sugar: 9,
            dietaryFiber: 0.0,
            protein: 0.5
        )
        let nutritionFacts = NutritionFacts(
            productName: "Orange juice",
            isLiquid: true,
            macronutrients: macronutrients,
            vitamins: [],
            minerals: [],
            allergens: [],
            ingredients: nil
        )
        #expect(nutritionFacts.isLiquid == true)
    }
}

// MARK: - AppState Tests

@Suite("AppState")
struct AppStateTests {

    @Test("success state holds the expected NutritionFacts")
    func testAppState_success_holdsNutritionFacts() {
        let macronutrients = Macronutrients(
            calories: 52,
            totalFat: 0.2,
            saturatedFat: 0.0,
            transFat: 0.0,
            carbohydrates: 14,
            sugar: 10,
            dietaryFiber: 2.4,
            protein: 0.3
        )
        let nutritionFacts = NutritionFacts(
            productName: "Apple",
            isLiquid: false,
            macronutrients: macronutrients,
            vitamins: [],
            minerals: [],
            allergens: [],
            ingredients: nil
        )
        let state = AppState.success(nutritionFacts)
        if case .success(let result) = state {
            #expect(result.productName == "Apple")
        } else {
            Issue.record("Expected .success state")
        }
    }

    @Test("error state holds the expected AppError")
    func testAppState_error_holdsAppError() {
        let state = AppState.error(AppError.aiUnavailable)
        if case .error(let error) = state {
            if case .aiUnavailable = error {
                // Correct
            } else {
                Issue.record("Expected AppError.aiUnavailable")
            }
        } else {
            Issue.record("Expected .error state")
        }
    }
}
