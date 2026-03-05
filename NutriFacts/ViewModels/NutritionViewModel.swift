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
    private let speechService: SpeechRecognitionServiceProtocol
    private var dictationTask: Task<Void, Never>?

    // MARK: - Init

    init(
        aiService: AIServiceProtocol,
        speechService: SpeechRecognitionServiceProtocol = SpeechRecognitionService()
    ) {
        self.aiService = aiService
        self.speechService = speechService
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

    // MARK: - Dictation

    /// Starts a speech recognition session. Sets isRecording to true immediately, then consumes the
    /// transcription stream in the background, updating searchText with each new result.
    @MainActor
    func startDictation() async {
        guard !isRecording else { return }
        do {
            let transcriptionStream = try await speechService.startRecording()
            isRecording = true
            dictationTask = Task { @MainActor [weak self] in
                for await transcription in transcriptionStream {
                    guard let self, !Task.isCancelled else { break }
                    self.searchText = transcription
                }
                self?.isRecording = false
            }
        } catch {
            // Permission denied or recognizer unavailable — stop silently
            isRecording = false
        }
    }

    /// Stops the active speech recognition session.
    @MainActor
    func stopDictation() {
        dictationTask?.cancel()
        dictationTask = nil
        speechService.stopRecording()
        isRecording = false
    }
}
