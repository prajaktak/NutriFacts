// EmptyStateView.swift
// NutriFacts

import SwiftUI

/// Shown on the home screen when no search has been made yet.
struct EmptyStateView: View {

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 80))
                .foregroundStyle(ThemeColor.accent.opacity(0.6))
                .accessibilityHidden(true)

            Text("Search for any food to see\nits nutrition facts.")
                .font(.body)
                .foregroundStyle(ThemeColor.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}

#Preview {
    EmptyStateView()
}
