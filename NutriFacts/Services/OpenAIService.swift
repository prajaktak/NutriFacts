// OpenAIService.swift
// NutriFacts

import UIKit

/// Online AI service using OpenAI GPT-4o.
/// Conforms to AIServiceProtocol — used when the device has internet connectivity.
final class OpenAIService: AIServiceProtocol {

    private let requestBuilder: OpenAIRequestBuilder
    private let responseParser: OpenAIResponseParser
    private let urlSession: NetworkSession

    init(
        apiKey: String = APIKeyProvider.openAIKey,
        urlSession: NetworkSession = URLSession.shared
    ) {
        self.requestBuilder = OpenAIRequestBuilder(apiKey: apiKey)
        self.responseParser = OpenAIResponseParser()
        self.urlSession = urlSession
    }

    // MARK: - AIServiceProtocol

    func lookupNutrition(query: String) async throws -> NutritionFacts {
        let request = try requestBuilder.buildTextRequest(query: query)
        return try await performRequest(request)
    }

    func lookupNutrition(image: UIImage) async throws -> NutritionFacts {
        let resizedImage = image.resized(toMaxDimension: 1024)
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            throw AppError.invalidImage
        }
        let request = try requestBuilder.buildImageRequest(imageData: imageData)
        return try await performRequest(request)
    }

    // MARK: - Private

    private func performRequest(_ request: URLRequest) async throws -> NutritionFacts {
        let (responseData, urlResponse): (Data, URLResponse)
        do {
            (responseData, urlResponse) = try await urlSession.data(for: request)
        } catch {
            throw AppError.networkError(error)
        }

        guard let httpResponse = urlResponse as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AppError.networkError(URLError(.badServerResponse))
        }

        return try responseParser.parse(responseData: responseData)
    }
}
