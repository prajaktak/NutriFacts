// SuggestionChipsView.swift
// NutriFacts

import SwiftUI

/// A horizontally scrollable row of tappable food suggestion chips.
/// Tapping a chip sets the search text and submits the query immediately.
struct SuggestionChipsView: View {

    let onChipSelected: (String) -> Void

    private let suggestions = ["Apple", "Oat milk", "Greek yogurt", "Salmon", "Brown rice", "Avocado"]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        onChipSelected(suggestion)
                    } label: {
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundStyle(ThemeColor.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(ThemeColor.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .accessibilityLabel("Search for \(suggestion)")
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    SuggestionChipsView(onChipSelected: { _ in })
}
