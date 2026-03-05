// NutritionFacts+UnitLabel.swift
// NutriFacts

import Foundation

extension NutritionFacts {
    /// The serving unit label displayed on the Results screen.
    /// Returns "per 100ml" for liquids, "per 100g" for solids.
    var unitLabel: String {
        isLiquid ? "per 100ml" : "per 100g"
    }
}
