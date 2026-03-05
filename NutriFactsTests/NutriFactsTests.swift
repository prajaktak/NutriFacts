// NutriFactsTests.swift
// NutriFactsTests

import Testing
import UIKit
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

// MARK: - NutritionViewModel Tests

@MainActor
@Suite("NutritionViewModel")
struct NutritionViewModelTests {

    // MARK: - Helpers

    private func makeMockNutritionFacts(productName: String = "Apple", isLiquid: Bool = false) -> NutritionFacts {
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
        return NutritionFacts(
            productName: productName,
            isLiquid: isLiquid,
            macronutrients: macronutrients,
            vitamins: [],
            minerals: [],
            allergens: [],
            ingredients: nil
        )
    }

    // MARK: - clearSearch tests

    @Test("clearSearch resets searchText to empty")
    func testClearSearch_resetsSearchText() {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Banana"
        viewModel.clearSearch()
        #expect(viewModel.searchText.isEmpty)
    }

    @Test("clearSearch sets appState to idle")
    func testClearSearch_setsStateToIdle() {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.clearSearch()
        if case .idle = viewModel.appState {
            // Correct
        } else {
            Issue.record("Expected .idle state after clearSearch")
        }
    }

    // MARK: - search tests

    @Test("search sets appState to success when service returns NutritionFacts")
    func testSearch_onSuccess_setsStateToSuccess() async {
        let nutritionFacts = makeMockNutritionFacts(productName: "Apple")
        let mockService = MockAIService(result: .success(nutritionFacts))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Apple"
        await viewModel.search()
        if case .success(let result) = viewModel.appState {
            #expect(result.productName == "Apple")
        } else {
            Issue.record("Expected .success state after search")
        }
    }

    @Test("search sets appState to error when service throws")
    func testSearch_onError_setsStateToError() async {
        let mockService = MockAIService(result: .failure(AppError.aiUnavailable))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Unknown food"
        await viewModel.search()
        if case .error = viewModel.appState {
            // Correct
        } else {
            Issue.record("Expected .error state after failed search")
        }
    }

    // MARK: - analyzePhoto tests

    @Test("analyzePhoto sets appState to success when service returns NutritionFacts")
    func testAnalyzePhoto_onSuccess_setsStateToSuccess() async {
        let nutritionFacts = makeMockNutritionFacts(productName: "Banana")
        let mockService = MockAIService(result: .success(nutritionFacts))
        let viewModel = NutritionViewModel(aiService: mockService)
        let image = UIImage()
        await viewModel.analyzePhoto(image)
        if case .success(let result) = viewModel.appState {
            #expect(result.productName == "Banana")
        } else {
            Issue.record("Expected .success state after analyzePhoto")
        }
    }

    @Test("analyzePhoto sets appState to error when service throws")
    func testAnalyzePhoto_onError_setsStateToError() async {
        let mockService = MockAIService(result: .failure(AppError.invalidImage))
        let viewModel = NutritionViewModel(aiService: mockService)
        let image = UIImage()
        await viewModel.analyzePhoto(image)
        if case .error = viewModel.appState {
            // Correct
        } else {
            Issue.record("Expected .error state after failed analyzePhoto")
        }
    }
}

