// PermissionStrings.swift
// NutriFacts

/// String constants for permission-denied alert messages shown in HomeView.
enum PermissionStrings {
    static let microphoneDeniedTitle = "Microphone Access Required"
    static let microphoneDeniedMessage = "NutriFacts needs microphone access to transcribe your spoken food name. Enable it in Settings."

    static let cameraDeniedTitle = "Camera Access Required"
    static let cameraDeniedMessage = "NutriFacts uses your camera to identify food or read nutrition labels. Enable it in Settings."

    static let photoLibraryDeniedTitle = "Photo Library Access Required"
    static let photoLibraryDeniedMessage = "NutriFacts accesses your photo library so you can choose a food photo. Enable it in Settings."

    static let speechRecognitionDeniedTitle = "Speech Recognition Required"
    static let speechRecognitionDeniedMessage = "NutriFacts uses speech recognition to convert your voice into text. Enable it in Settings."

    static let goToSettingsButtonLabel = "Go to Settings"
    static let cancelButtonLabel = "Cancel"
}
