// SearchBarView.swift
// NutriFacts

import SwiftUI

/// Full-width search field with a magnifying glass icon and a clear button.
/// Submits when the user taps the keyboard Return key or the Search button.
struct SearchBarView: View {

    @Binding var searchText: String
    let isDisabled: Bool
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ThemeColor.secondaryLabel)
                .accessibilityHidden(true)

            TextField("Search food or product", text: $searchText)
                .submitLabel(.search)
                .disabled(isDisabled)
                .onSubmit(onSubmit)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(ThemeColor.secondaryLabel)
                }
                .accessibilityLabel("Clear search")
                .disabled(isDisabled)
            }
        }
        .padding(12)
        .background(ThemeColor.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    @Previewable @State var searchText = ""
    SearchBarView(searchText: $searchText, isDisabled: false, onSubmit: {})
        .padding()
}
