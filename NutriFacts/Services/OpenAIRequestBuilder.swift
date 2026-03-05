// OpenAIRequestBuilder.swift
// NutriFacts

import Foundation

/// Builds URLRequests for the OpenAI chat completions endpoint.
/// Handles both text queries and image (base64) queries.
struct OpenAIRequestBuilder {

    private static let endpointURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    private static let modelName = "gpt-4o"

    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    // MARK: - Text Request

    /// Builds a POST request asking the model to return nutrition facts for a food query.
    func buildTextRequest(query: String) throws -> URLRequest {
        let systemPrompt = Self.nutritionSystemPrompt
        let userPrompt = """
        Food or product: \(query)
        """
        let body = buildRequestBody(messages: [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ])
        return try makeRequest(body: body)
    }

    // MARK: - Image Request

    /// Builds a POST request sending a base64-encoded image for food identification or label OCR.
    func buildImageRequest(imageData: Data) throws -> URLRequest {
        let base64Image = imageData.base64EncodedString()
        let userContent: [[String: Any]] = [
            ["type": "text", "text": Self.nutritionSystemPrompt],
            ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
        ]
        let body = buildRequestBody(messages: [
            ["role": "user", "content": userContent]
        ])
        return try makeRequest(body: body)
    }

    // MARK: - Private Helpers

    private func makeRequest(body: [String: Any]) throws -> URLRequest {
        var request = URLRequest(url: Self.endpointURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func buildRequestBody(messages: [[String: Any]]) -> [String: Any] {
        [
            "model": Self.modelName,
            "messages": messages,
            "response_format": ["type": "json_object"],
            "temperature": 0.2
        ]
    }

    // MARK: - Prompt

    private static let nutritionSystemPrompt = """
    You are a nutrition expert. The user has provided a food or product name.
    Return the nutrition facts per 100g (or per 100ml if liquid) in the following JSON format:
    {
      "productName": "string",
      "isLiquid": false,
      "macronutrients": {
        "calories": 0.0,
        "totalFat": 0.0,
        "saturatedFat": 0.0,
        "transFat": 0.0,
        "carbohydrates": 0.0,
        "sugar": 0.0,
        "dietaryFiber": 0.0,
        "protein": 0.0
      },
      "vitamins": [{ "id": "uuid-string", "nutrientName": "string", "nutrientAmount": 0.0, "nutrientUnit": "string" }],
      "minerals": [{ "id": "uuid-string", "nutrientName": "string", "nutrientAmount": 0.0, "nutrientUnit": "string" }],
      "allergens": ["string"],
      "ingredients": "string or null"
    }
    If you cannot identify the product, return ONLY this JSON (no other text):
    { "error": true, "followUpQuestions": ["question 1", "question 2"] }
    Do not guess or hallucinate values. If a nutrient value is unknown, omit that field or use 0.
    """
}
