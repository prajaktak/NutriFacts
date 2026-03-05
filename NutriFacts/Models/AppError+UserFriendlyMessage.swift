// AppError+UserFriendlyMessage.swift
// NutriFacts

import Foundation

extension AppError {
    /// A friendly, non-technical message suitable for display to the user.
    var userFriendlyMessage: String {
        switch self {
        case .productNotFound:
            return "We couldn't identify this food. Let's try to narrow it down."
        case .aiUnavailable:
            return "AI is currently unavailable. Please check your connection and try again."
        case .networkError:
            return "A network error occurred. Please check your connection and try again."
        case .invalidImage:
            return "The photo isn't clear enough. Try taking a clearer photo or use text search."
        case .parsingError:
            return "Something went wrong processing the result. Please try again."
        }
    }
}
