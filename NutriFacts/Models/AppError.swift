// AppError.swift
// NutriFacts

import Foundation

enum AppError: Error {
    case productNotFound(followUpQuestions: [String])
    case aiUnavailable
    case networkError(Error)
    case invalidImage
    case parsingError
}
