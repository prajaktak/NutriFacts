// OpenAIResponseModels.swift
// NutriFacts

import Foundation

/// Top-level OpenAI chat completion response envelope.
struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChoice]
}

/// A single choice item in the OpenAI response.
struct OpenAIChoice: Decodable {
    let message: OpenAIMessage
}

/// The message content returned by the model.
struct OpenAIMessage: Decodable {
    let content: String
}

/// The structured content the model returns when it cannot identify the product.
struct OpenAIErrorResponse: Decodable {
    let error: Bool
    let followUpQuestions: [String]
}
