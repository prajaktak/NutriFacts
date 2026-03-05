// OpenAIResponseParser.swift
// NutriFacts

import Foundation

/// Parses the raw Data from an OpenAI chat completion response into NutritionFacts.
/// Throws AppError if the response indicates the product was not found or is malformed.
struct OpenAIResponseParser {

    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        return decoder
    }()

    /// Decodes the OpenAI response envelope, extracts the content string,
    /// then decodes it as NutritionFacts or throws AppError.
    func parse(responseData: Data) throws -> NutritionFacts {
        guard !responseData.isEmpty else {
            throw AppError.parsingError
        }

        let chatResponse: OpenAIChatResponse
        do {
            chatResponse = try jsonDecoder.decode(OpenAIChatResponse.self, from: responseData)
        } catch {
            throw AppError.parsingError
        }

        guard let contentString = chatResponse.choices.first?.message.content,
              let contentData = contentString.data(using: .utf8) else {
            throw AppError.parsingError
        }

        // Attempt to decode as error response first
        if let errorResponse = try? jsonDecoder.decode(OpenAIErrorResponse.self, from: contentData),
           errorResponse.error {
            throw AppError.productNotFound(followUpQuestions: errorResponse.followUpQuestions)
        }

        // Attempt to decode as NutritionFacts
        do {
            return try jsonDecoder.decode(NutritionFacts.self, from: contentData)
        } catch {
            throw AppError.parsingError
        }
    }
}
