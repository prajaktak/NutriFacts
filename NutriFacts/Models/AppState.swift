// AppState.swift
// NutriFacts

import Foundation

enum AppState {
    case idle
    case loading
    case success(NutritionFacts)
    case error(AppError)
}
