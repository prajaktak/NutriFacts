// APIKeyProvider.swift
// NutriFacts

import Foundation

/// Reads API keys from the app's Info.plist.
/// Keys are injected at build time via Secrets.xcconfig (excluded from source control).
enum APIKeyProvider {
    /// The OpenAI API key. Returns an empty string if not configured.
    static var openAIKey: String {
        Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
    }
}
