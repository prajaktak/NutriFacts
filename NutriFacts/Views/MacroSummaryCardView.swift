// MacroSummaryCardView.swift
// NutriFacts

import SwiftUI

/// A single macro summary card showing a bold value and a label.
/// Used in a 2×2 grid on the Overview tab.
struct MacroSummaryCardView: View {

    let cardTitle: String
    let cardValue: String
    let cardUnit: String

    var body: some View {
        VStack(spacing: 4) {
            Text(cardValue)
                .font(.title2.bold())
                .foregroundStyle(ThemeColor.label)

            Text(cardUnit)
                .font(.caption)
                .foregroundStyle(ThemeColor.secondaryLabel)

            Text(cardTitle)
                .font(.caption)
                .foregroundStyle(ThemeColor.secondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(ThemeColor.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MacroSummaryCardView(cardTitle: "Calories", cardValue: "52", cardUnit: "kcal")
        .frame(width: 160)
        .padding()
}
