// NutritionViewModel.swift
// NutriFacts

import UIKit
import Observation

/// Single source of truth for the app's state.
/// Drives all views — views read from this ViewModel and call its methods.
@Observable
final class NutritionViewModel {

    // MARK: - Public State

    private(set) var appState: AppState = .idle
    var searchText: String = ""
    var isRecording: Bool = false

    // MARK: - Navigation Computed Properties

    /// True when the app state is `.success` — drives navigation to ResultsView.
    var isShowingResults: Bool {
        if case .success = appState { return true }
        return false
    }

    /// True when the app state is `.error` — drives navigation to ErrorView.
    var isShowingError: Bool {
        if case .error = appState { return true }
        return false
    }

    // MARK: - Private Dependencies

    private let aiService: AIServiceProtocol

    // MARK: - Init

    init(aiService: AIServiceProtocol) {
        self.aiService = aiService
    }

    // MARK: - Search

    /// Submits the current searchText to the AI service and updates appState.
    @MainActor
    func search() async {
        guard !searchText.isEmpty else { return }
        appState = .loading
        do {
            let nutritionFacts = try await aiService.lookupNutrition(query: searchText)
            appState = .success(nutritionFacts)
        } catch {
            appState = .error(error as? AppError ?? .parsingError)
        }
    }

    /// Clears the search text and resets the app to the idle state.
    @MainActor
    func clearSearch() {
        searchText = ""
        appState = .idle
    }

    /// Retries the search, optionally appending additional context to the original query.
    /// Used by ErrorView when the user answers follow-up questions.
    @MainActor
    func retrySearch(withContext context: String) async {
        if !context.isEmpty {
            searchText = "\(searchText), \(context)"
        }
        await search()
    }

    /// Sends a photo to the AI service for food identification or label extraction.
    @MainActor
    func analyzePhoto(_ selectedImage: UIImage) async {
        appState = .loading
        do {
            let nutritionFacts = try await aiService.lookupNutrition(image: selectedImage)
            appState = .success(nutritionFacts)
        } catch {
            appState = .error(error as? AppError ?? .parsingError)
        }
    }
}
