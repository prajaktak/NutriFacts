// ResultsTabSelection.swift
// NutriFacts

import Foundation

/// The two tabs available on the Results screen.
enum ResultsTabSelection: Int, CaseIterable {
    case overview
    case fullDetails

    /// The default tab shown when ResultsView first appears.
    static let defaultTab: ResultsTabSelection = .overview

    /// The display title shown in the segmented control.
    var tabTitle: String {
        switch self {
        case .overview:
            return "Overview"
        case .fullDetails:
            return "Full Details"
        }
    }
}
