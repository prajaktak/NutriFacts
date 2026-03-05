// LoadingView.swift
// NutriFacts

import SwiftUI

/// Shown while the AI is processing a lookup request.
struct LoadingView: View {

    let searchText: String

    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(ThemeColor.accent)

            Text("Looking up nutrition facts\nfor \"\(searchText)\"...")
                .font(.body)
                .foregroundStyle(ThemeColor.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }
}

#Preview {
    LoadingView(searchText: "Apple")
}
