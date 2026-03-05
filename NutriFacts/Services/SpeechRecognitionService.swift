// SpeechRecognitionService.swift
// NutriFacts

import Speech
import AVFoundation

/// Records microphone audio and streams live transcription updates using SFSpeechRecognizer.
final class SpeechRecognitionService: SpeechRecognitionServiceProtocol {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func startRecording() async throws -> AsyncStream<String> {
        try await requestAuthorization()
        stopRecording()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            throw AppError.aiUnavailable
        }

        return AsyncStream { [weak self] continuation in
            self?.recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                if let transcription = result?.bestTranscription.formattedString {
                    continuation.yield(transcription)
                }
                if result?.isFinal == true || error != nil {
                    continuation.finish()
                }
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }

    private func requestAuthorization() async throws {
        let authStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard authStatus == .authorized else {
            throw AppError.aiUnavailable
        }
    }
}
