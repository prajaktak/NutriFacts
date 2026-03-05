// ThemeColor.swift
// NutriFacts

import SwiftUI

/// Centralized color palette for the app.
/// All views must use these colors — no hardcoded Color values in views.
enum ThemeColor {
    /// Primary accent — buttons, active states.
    static let accent = Color.accentColor

    /// Carbohydrates segment in the macro pie chart.
    static let carbohydrates = Color.orange

    /// Protein segment in the macro pie chart.
    static let protein = Color.green

    /// Fat segment in the macro pie chart.
    static let fat = Color.pink

    /// Error and warning states.
    static let error = Color.red

    /// Primary text.
    static let label = Color.primary

    /// Secondary text — units, subtitles.
    static let secondaryLabel = Color.secondary

    /// Primary background.
    static let background = Color(uiColor: .systemBackground)

    /// Secondary grouped background — section and card backgrounds.
    static let secondaryBackground = Color(uiColor: .secondarySystemGroupedBackground)
}
