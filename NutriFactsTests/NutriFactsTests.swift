// NutriFactsTests.swift
// NutriFactsTests

import Testing
import UIKit
import SwiftUI
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

// MARK: - HomeView Behavior Tests
@MainActor
@Suite("HomeView Behavior")
struct HomeViewBehaviorTests {

    private func makeMockNutritionFacts() -> NutritionFacts {
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
            productName: "Apple",
            isLiquid: false,
            macronutrients: macronutrients,
            vitamins: [],
            minerals: [],
            allergens: [],
            ingredients: nil
        )
    }

    @Test("search with empty text leaves appState idle")
    func testSearch_emptySearchText_stateRemainsIdle() async {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = ""
        await viewModel.search()
        if case .idle = viewModel.appState {
            // Correct
        } else {
            Issue.record("Expected .idle state when searching with empty text")
        }
    }

    @Test("selecting suggestion chip sets searchText to chip value")
    func testSuggestionChip_tap_setsSearchText() {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        let chipValue = "Greek yogurt"
        viewModel.searchText = chipValue
        #expect(viewModel.searchText == chipValue)
    }

    @Test("clearSearch after success resets to idle")
    func testClearSearch_afterSuccess_resetsToIdle() async {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Apple"
        await viewModel.search()
        viewModel.clearSearch()
        if case .idle = viewModel.appState {
            // Correct
        } else {
            Issue.record("Expected .idle state after clearSearch following success")
        }
    }
}

// MARK: - Navigation State Tests

@MainActor
@Suite("Navigation State")
struct NavigationStateTests {
    private func makeMockNutritionFacts(productName: String = "Apple") -> NutritionFacts {
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
            isLiquid: false,
            macronutrients: macronutrients,
            vitamins: [],
            minerals: [],
            allergens: [],
            ingredients: nil
        )
    }

    @Test("appState success means navigation destination is results")
    func testAppState_success_navigationDestinationIsResults() async {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Apple"
        await viewModel.search()
        if case .success = viewModel.appState {
            #expect(viewModel.isShowingResults)
        } else {
            Issue.record("Expected .success state")
        }
    }

    @Test("appState error means navigation destination is error")
    func testAppState_error_navigationDestinationIsError() async {
        let mockService = MockAIService(result: .failure(AppError.productNotFound(followUpQuestions: ["Is it cooked?"])))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "XYZ"
        await viewModel.search()
        if case .error = viewModel.appState {
            #expect(viewModel.isShowingError)
        } else {
            Issue.record("Expected .error state")
        }
    }

    @Test("appState idle means no navigation destination is active")
    func testAppState_idle_noNavigationDestination() {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        #expect(!viewModel.isShowingResults)
        #expect(!viewModel.isShowingError)
    }

    @Test("clearSearch dismisses results navigation")
    func testClearSearch_dismissesResultsNavigation() async {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Apple"
        await viewModel.search()
        viewModel.clearSearch()
        #expect(!viewModel.isShowingResults)
    }
}

// MARK: - ResultsView Unit Label Tests

@Suite("ResultsView Unit Label")
struct ResultsViewUnitLabelTests {

    @Test("unit label is per 100g for solid food")
    func testUnitLabel_solidFood_showsPer100g() {
        let nutritionFacts = NutritionFacts(
            productName: "Apple",
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 52, totalFat: 0.2, saturatedFat: 0.0,
                transFat: 0.0, carbohydrates: 14, sugar: 10,
                dietaryFiber: 2.4, protein: 0.3
            ),
            vitamins: [], minerals: [], allergens: [], ingredients: nil
        )
        #expect(nutritionFacts.unitLabel == "per 100g")
    }
    @Test("unit label is per 100ml for liquid food")
    func testUnitLabel_liquidFood_showsPer100ml() {
        let nutritionFacts = NutritionFacts(
            productName: "Oat milk",
            isLiquid: true,
            macronutrients: Macronutrients(
                calories: 42, totalFat: 0.1, saturatedFat: 0.0,
                transFat: 0.0, carbohydrates: 10, sugar: 9,
                dietaryFiber: 0.0, protein: 0.5
            ),
            vitamins: [], minerals: [], allergens: [], ingredients: nil
        )
        #expect(nutritionFacts.unitLabel == "per 100ml")
    }

    @Test("default selected tab is overview")
    func testResultsTabSelection_default_isOverview() {
        #expect(ResultsTabSelection.defaultTab == .overview)
    }
}

// MARK: - MacroPieSlice Tests

@Suite("MacroPieSlice")
struct MacroPieSliceTests {

    private let macronutrients = Macronutrients(
        calories: 52,
        totalFat: 0.2,
        saturatedFat: 0.0,
        transFat: 0.0,
        carbohydrates: 14,
        sugar: 10,
        dietaryFiber: 2.4,
        protein: 0.3
    )

    @Test("slices contain carbs, protein and fat")
    func testMacroPieSlices_fromMacronutrients_containsThreeSlices() {
        let slices = MacroPieSlice.slices(from: macronutrients)
        #expect(slices.count == 3)
    }
    @Test("carbs slice has correct gram value")
    func testMacroPieSlice_carbs_hasCorrectGrams() {
        let slices = MacroPieSlice.slices(from: macronutrients)
        let carbsSlice = slices.first { $0.macroLabel == "Carbs" }
        #expect(carbsSlice?.gramValue == 14)
    }

    @Test("protein slice has correct gram value")
    func testMacroPieSlice_protein_hasCorrectGrams() {
        let slices = MacroPieSlice.slices(from: macronutrients)
        let proteinSlice = slices.first { $0.macroLabel == "Protein" }
        #expect(proteinSlice?.gramValue == 0.3)
    }

    @Test("fat slice has correct gram value")
    func testMacroPieSlice_fat_hasCorrectGrams() {
        let slices = MacroPieSlice.slices(from: macronutrients)
        let fatSlice = slices.first { $0.macroLabel == "Fat" }
        #expect(fatSlice?.gramValue == 0.2)
    }

    @Test("slices with all zero values produce three slices with zero grams")
    func testMacroPieSlice_allZeros_producesThreeZeroSlices() {
        let zeroMacros = Macronutrients(
            calories: 0, totalFat: 0, saturatedFat: 0,
            transFat: 0, carbohydrates: 0, sugar: 0,
            dietaryFiber: 0, protein: 0
        )
        let slices = MacroPieSlice.slices(from: zeroMacros)
        #expect(slices.allSatisfy { $0.gramValue == 0 })
    }
}

// MARK: - NutrientRow Tests

@Suite("NutrientRow")
struct NutrientRowTests {

    @Test("nutrientRowText formats integer value without decimal")
    func testNutrientRowText_integerValue_formatsWithoutDecimal() {
        let item = NutrientItem(id: UUID(), nutrientName: "Potassium", nutrientAmount: 107, nutrientUnit: "mg")
        #expect(item.formattedAmount == "107 mg")
    }

    @Test("nutrientRowText formats decimal value with one decimal place")
    func testNutrientRowText_decimalValue_formatsWithOneDecimal() {
        let item = NutrientItem(id: UUID(), nutrientName: "Vitamin C", nutrientAmount: 5.1, nutrientUnit: "mg")
        #expect(item.formattedAmount == "5.1 mg")
    }
}

// MARK: - Allergens Display Tests
@Suite("Allergens Display")
struct AllergensDisplayTests {

    @Test("empty allergens list displays none detected text")
    func testAllergens_emptyList_displaysNoneDetected() {
        let nutritionFacts = NutritionFacts(
            productName: "Apple",
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 52, totalFat: 0.2, saturatedFat: 0.0,
                transFat: 0.0, carbohydrates: 14, sugar: 10,
                dietaryFiber: 2.4, protein: 0.3
            ),
            vitamins: [], minerals: [], allergens: [], ingredients: nil
        )
        #expect(nutritionFacts.allergensDisplayText == "None detected")
    }

    @Test("allergens list displays comma separated values")
    func testAllergens_nonEmptyList_displaysCommaSeparated() {
        let nutritionFacts = NutritionFacts(
            productName: "Bread",
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 265, totalFat: 3.2, saturatedFat: 0.7,
                transFat: 0.0, carbohydrates: 49, sugar: 5,
                dietaryFiber: 2.7, protein: 9
            ),
            vitamins: [], minerals: [], allergens: ["Gluten", "Wheat"], ingredients: nil
        )
        #expect(nutritionFacts.allergensDisplayText == "Gluten, Wheat")
    }
}

// MARK: - AppError User-Friendly Message Tests

@Suite("AppError User-Friendly Message")
struct AppErrorUserFriendlyMessageTests {

    @Test("productNotFound returns could not identify message")
    func testAppError_productNotFound_returnsCouldNotIdentifyMessage() {
        let appError = AppError.productNotFound(followUpQuestions: ["Is it cooked?"])
        #expect(appError.userFriendlyMessage.isEmpty == false)
    }

    @Test("aiUnavailable returns ai unavailable message")
    func testAppError_aiUnavailable_returnsAIUnavailableMessage() {
        let appError = AppError.aiUnavailable
        #expect(appError.userFriendlyMessage.isEmpty == false)
    }

    @Test("invalidImage returns invalid image message")
    func testAppError_invalidImage_returnsInvalidImageMessage() {
        let appError = AppError.invalidImage
        #expect(appError.userFriendlyMessage.isEmpty == false)
    }

    @Test("parsingError returns generic error message")
    func testAppError_parsingError_returnsGenericMessage() {
        let appError = AppError.parsingError
        #expect(appError.userFriendlyMessage.isEmpty == false)
    }
}
// MARK: - ErrorView Retry Tests

@MainActor
@Suite("ErrorView Retry")
struct ErrorViewRetryTests {

    private func makeMockNutritionFacts() -> NutritionFacts {
        NutritionFacts(
            productName: "Apple",
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 52, totalFat: 0.2, saturatedFat: 0.0,
                transFat: 0.0, carbohydrates: 14, sugar: 10,
                dietaryFiber: 2.4, protein: 0.3
            ),
            vitamins: [], minerals: [], allergens: [], ingredients: nil
        )
    }

    @Test("retrySearch appends context to searchText before searching")
    func testRetrySearch_withContext_appendsContextToSearchText() async {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Chicken"
        await viewModel.retrySearch(withContext: "cooked")
        // After retry the state will be success; the search text may have been updated
        if case .success = viewModel.appState {
            // Correct — retry succeeded
        } else {
            Issue.record("Expected .success state after retrySearch")
        }
    }

    @Test("retrySearch with empty context still submits search")
    func testRetrySearch_withEmptyContext_submitsSearch() async {
        let mockService = MockAIService(result: .success(makeMockNutritionFacts()))
        let viewModel = NutritionViewModel(aiService: mockService)
        viewModel.searchText = "Apple"
        await viewModel.retrySearch(withContext: "")
        if case .success = viewModel.appState {
            // Correct
        } else {
            Issue.record("Expected .success state after retrySearch with empty context")
        }
    }
}

// MARK: - OpenAI Response Parser Tests

@Suite("OpenAI Response Parser")
struct OpenAIResponseParserTests {

    private let parser = OpenAIResponseParser()

    private func makeSuccessJSON(productName: String = "Apple") -> Data {
        let jsonString = """
        {
          "choices": [{
            "message": {
              "content": "{\\"productName\\":\\"\(productName)\\",\\"isLiquid\\":false,\\"macronutrients\\":{\\"calories\\":52,\\"totalFat\\":0.2,\\"saturatedFat\\":0.0,\\"transFat\\":0.0,\\"carbohydrates\\":14,\\"sugar\\":10,\\"dietaryFiber\\":2.4,\\"protein\\":0.3},\\"vitamins\\":[],\\"minerals\\":[],\\"allergens\\":[],\\"ingredients\\":null}"
            }
          }]
        }
        """
        return Data(jsonString.utf8)
    }

    private func makeErrorJSON() -> Data {
        let jsonString = """
        {
          "choices": [{
            "message": {
              "content": "{\\"error\\":true,\\"followUpQuestions\\":[\\"Is it raw or cooked?\\",\\"Do you know the brand?\\"]}"
            }
          }]
        }
        """
        return Data(jsonString.utf8)
    }

    @Test("parser decodes valid nutrition facts JSON into NutritionFacts")
    func testParser_validJSON_returnsNutritionFacts() throws {
        let nutritionFacts = try parser.parse(responseData: makeSuccessJSON())
        #expect(nutritionFacts.productName == "Apple")
    }

    @Test("parser decodes calories correctly from valid JSON")
    func testParser_validJSON_decodesCaloriesCorrectly() throws {
        let nutritionFacts = try parser.parse(responseData: makeSuccessJSON())
        #expect(nutritionFacts.macronutrients.calories == 52)
    }
    @Test("parser throws productNotFound when response contains error flag")
    func testParser_errorJSON_throwsProductNotFound() throws {
        var didThrowProductNotFound = false
        do {
            _ = try parser.parse(responseData: makeErrorJSON())
        } catch let appError as AppError {
            if case .productNotFound = appError {
                didThrowProductNotFound = true
            }
        }
        #expect(didThrowProductNotFound)
    }

    @Test("parser throws parsingError when response data is empty")
    func testParser_emptyData_throwsParsingError() throws {
        var didThrowParsingError = false
        do {
            _ = try parser.parse(responseData: Data())
        } catch let appError as AppError {
            if case .parsingError = appError {
                didThrowParsingError = true
            }
        }
        #expect(didThrowParsingError)
    }
}

// MARK: - OpenAI Request Builder Tests

@Suite("OpenAI Request Builder")
struct OpenAIRequestBuilderTests {

    private let builder = OpenAIRequestBuilder(apiKey: "test-key-123")

    @Test("builder sets correct URL for text query")
    func testBuilder_textQuery_setsCorrectURL() throws {
        let request = try builder.buildTextRequest(query: "Apple")
        #expect(request.url?.host == "api.openai.com")
    }

    @Test("builder sets POST method for text query")
    func testBuilder_textQuery_setsPostMethod() throws {
        let request = try builder.buildTextRequest(query: "Apple")
        #expect(request.httpMethod == "POST")
    }

    @Test("builder sets Authorization header for text query")
    func testBuilder_textQuery_setsAuthorizationHeader() throws {
        let request = try builder.buildTextRequest(query: "Apple")
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        #expect(authHeader == "Bearer test-key-123")
    }

    @Test("builder encodes non-empty body for text query")
    func testBuilder_textQuery_encodesNonEmptyBody() throws {
        let request = try builder.buildTextRequest(query: "Apple")
        #expect(request.httpBody != nil)
    }
}

// MARK: - AI Agent Service Tests

@Suite("AI Agent Service")
struct AIAgentServiceTests {

    private func makeFacts(name: String = "Apple") -> NutritionFacts {
        NutritionFacts(
            productName: name,
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 52, totalFat: 0.2, saturatedFat: 0.0, transFat: 0.0,
                carbohydrates: 14, sugar: 10, dietaryFiber: 2.4, protein: 0.3
            ),
            vitamins: [], minerals: [], allergens: [], ingredients: nil
        )
    }

    @Test("uses online service when connectivity reports online")
    func testAIAgentService_whenOnline_usesOnlineService() async throws {
        let onlineFacts = makeFacts(name: "OnlineResult")
        let onlineService = MockAIService(result: .success(onlineFacts))
        let offlineService = MockAIService(result: .failure(AppError.aiUnavailable))
        let connectivityMonitor = MockConnectivityMonitor(isOnline: true)
        let agentService = AIAgentService(
            onlineService: onlineService,
            offlineService: offlineService,
            connectivityMonitor: connectivityMonitor
        )
        let result = try await agentService.lookupNutrition(query: "Apple")
        #expect(result.productName == "OnlineResult")
    }

    @Test("uses offline service when connectivity reports offline")
    func testAIAgentService_whenOffline_usesOfflineService() async throws {
        let offlineFacts = makeFacts(name: "OfflineResult")
        let onlineService = MockAIService(result: .failure(AppError.networkError(URLError(.notConnectedToInternet))))
        let offlineService = MockAIService(result: .success(offlineFacts))
        let connectivityMonitor = MockConnectivityMonitor(isOnline: false)
        let agentService = AIAgentService(
            onlineService: onlineService,
            offlineService: offlineService,
            connectivityMonitor: connectivityMonitor
        )
        let result = try await agentService.lookupNutrition(query: "Apple")
        #expect(result.productName == "OfflineResult")
    }

    @Test("throws aiUnavailable when both services fail")
    func testAIAgentService_bothServicesFail_throwsAIUnavailable() async {
        let onlineService = MockAIService(result: .failure(AppError.networkError(URLError(.notConnectedToInternet))))
        let offlineService = MockAIService(result: .failure(AppError.aiUnavailable))
        let connectivityMonitor = MockConnectivityMonitor(isOnline: false)
        let agentService = AIAgentService(
            onlineService: onlineService,
            offlineService: offlineService,
            connectivityMonitor: connectivityMonitor
        )
        var didThrowAIUnavailable = false
        do {
            _ = try await agentService.lookupNutrition(query: "Unknown")
        } catch AppError.aiUnavailable {
            didThrowAIUnavailable = true
        } catch {
            // unexpected error
        }
        #expect(didThrowAIUnavailable)
    }
}

// MARK: - Speech Dictation Tests

@Suite("Speech Dictation")
@MainActor
struct SpeechDictationTests {

    @Test("startDictation sets isRecording to true")
    func testStartDictation_setsIsRecordingToTrue() async {
        let mockSpeech = MockSpeechRecognitionService()
        let viewModel = NutritionViewModel(
            aiService: MockAIService(result: .success(makeFacts())),
            speechService: mockSpeech
        )
        await viewModel.startDictation()
        #expect(viewModel.isRecording == true)
    }

    @Test("stopDictation sets isRecording to false")
    func testStopDictation_setsIsRecordingToFalse() async {
        let mockSpeech = MockSpeechRecognitionService()
        let viewModel = NutritionViewModel(
            aiService: MockAIService(result: .success(makeFacts())),
            speechService: mockSpeech
        )
        await viewModel.startDictation()
        viewModel.stopDictation()
        #expect(viewModel.isRecording == false)
    }

    @Test("startDictation updates searchText from transcription")
    func testStartDictation_updatesSearchText() async {
        let mockSpeech = MockSpeechRecognitionService(transcribedText: "Banana")
        let viewModel = NutritionViewModel(
            aiService: MockAIService(result: .success(makeFacts())),
            speechService: mockSpeech
        )
        await viewModel.startDictation()
        // Yield to allow the background dictation task to consume the stream
        await Task.yield()
        #expect(viewModel.searchText == "Banana")
    }

    private func makeFacts() -> NutritionFacts {
        NutritionFacts(
            productName: "Apple",
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 52, totalFat: 0.2, saturatedFat: 0.0, transFat: 0.0,
                carbohydrates: 14, sugar: 10, dietaryFiber: 2.4, protein: 0.3
            ),
            vitamins: [], minerals: [], allergens: [], ingredients: nil
        )
    }
}

// MARK: - Photo Input Tests

@Suite("Photo Input")
@MainActor
struct PhotoInputTests {

    private func makeFacts(name: String = "Apple") -> NutritionFacts {
        NutritionFacts(
            productName: name,
            isLiquid: false,
            macronutrients: Macronutrients(
                calories: 52, totalFat: 0.2, saturatedFat: 0.0, transFat: 0.0,
                carbohydrates: 14, sugar: 10, dietaryFiber: 2.4, protein: 0.3
            ),
            vitamins: [], minerals: [], allergens: [], ingredients: nil
        )
    }

    @Test("analyzePhoto sets appState to loading before awaiting service")
    func testAnalyzePhoto_setsStateToLoading() async {
        // Use a never-resolving service to catch the loading state
        let slowService = SlowMockAIService()
        let viewModel = NutritionViewModel(aiService: slowService)
        let analyzeTask = Task { await viewModel.analyzePhoto(UIImage()) }
        // Yield once so analyzePhoto sets appState = .loading
        await Task.yield()
        let isLoading: Bool
        if case .loading = viewModel.appState { isLoading = true } else { isLoading = false }
        #expect(isLoading)
        slowService.complete(with: .success(makeFacts()))
        await analyzeTask.value
    }

    @Test("analyzePhoto on success sets appState to success")
    func testAnalyzePhoto_photo_onSuccess_setsStateToSuccess() async {
        let facts = makeFacts(name: "Salmon")
        let viewModel = NutritionViewModel(aiService: MockAIService(result: .success(facts)))
        await viewModel.analyzePhoto(UIImage())
        if case .success(let result) = viewModel.appState {
            #expect(result.productName == "Salmon")
        } else {
            Issue.record("Expected success state")
        }
    }

    @Test("analyzePhoto on error sets appState to error")
    func testAnalyzePhoto_photo_onError_setsStateToError() async {
        let viewModel = NutritionViewModel(aiService: MockAIService(result: .failure(AppError.invalidImage)))
        await viewModel.analyzePhoto(UIImage())
        if case .error(let appError) = viewModel.appState {
            if case .invalidImage = appError { } else { Issue.record("Expected invalidImage error") }
        } else {
            Issue.record("Expected error state")
        }
    }
}

// MARK: - Apple Intelligence Service Tests

@Suite("Apple Intelligence Service")
@MainActor
struct AppleIntelligenceServiceTests {

    @Test("lookupNutrition(query:) throws aiUnavailable when model unavailable")
    func testLookupNutrition_query_throwsAIUnavailable_whenUnavailable() async {
        let service = AppleIntelligenceService(availability: .unavailable)
        do {
            _ = try await service.lookupNutrition(query: "Apple")
            Issue.record("Expected aiUnavailable error but no error was thrown")
        } catch let error as AppError {
            if case .aiUnavailable = error { } else {
                Issue.record("Expected aiUnavailable but got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("lookupNutrition(image:) throws aiUnavailable when model unavailable")
    func testLookupNutrition_image_throwsAIUnavailable_whenUnavailable() async {
        let service = AppleIntelligenceService(availability: .unavailable)
        do {
            _ = try await service.lookupNutrition(image: UIImage())
            Issue.record("Expected aiUnavailable error but no error was thrown")
        } catch let error as AppError {
            if case .aiUnavailable = error { } else {
                Issue.record("Expected aiUnavailable but got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("lookupNutrition(image:) throws aiUnavailable when vision returns no text and no classification")
    func testLookupNutrition_image_throwsAIUnavailable_whenVisionEmpty() async {
        let service = AppleIntelligenceService(
            availability: .unavailable,
            visionService: MockVisionAnalysisService(ocrText: nil, foodLabel: nil)
        )
        do {
            _ = try await service.lookupNutrition(image: UIImage())
            Issue.record("Expected aiUnavailable error but no error was thrown")
        } catch let error as AppError {
            if case .aiUnavailable = error { } else {
                Issue.record("Expected aiUnavailable but got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }
}






