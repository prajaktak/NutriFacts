// SpeechRecognitionServiceProtocol.swift
// NutriFacts

/// Protocol for speech-to-text transcription services.
/// Implementations stream transcription updates via an AsyncStream.
protocol SpeechRecognitionServiceProtocol {
    /// Requests authorization and starts recording. Yields transcription strings as they arrive.
    func startRecording() async throws -> AsyncStream<String>
    /// Stops the active recording session.
    func stopRecording()
}
