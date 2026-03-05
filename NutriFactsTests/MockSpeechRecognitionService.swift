// MockSpeechRecognitionService.swift
// NutriFactsTests

@testable import NutriFacts

/// A test double for SpeechRecognitionServiceProtocol.
/// Yields an optional transcription string then keeps the stream open until stopRecording() is called.
final class MockSpeechRecognitionService: SpeechRecognitionServiceProtocol {

    private let transcribedText: String
    private var streamContinuation: AsyncStream<String>.Continuation?

    init(transcribedText: String = "") {
        self.transcribedText = transcribedText
    }

    func startRecording() async throws -> AsyncStream<String> {
        let text = transcribedText
        return AsyncStream { [weak self] continuation in
            self?.streamContinuation = continuation
            if !text.isEmpty {
                continuation.yield(text)
            }
            // Stream stays open until stopRecording() calls finish()
        }
    }

    func stopRecording() {
        streamContinuation?.finish()
        streamContinuation = nil
    }
}
