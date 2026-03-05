// ErrorView.swift
// NutriFacts

import SwiftUI

/// Shown when the AI cannot identify the food.
/// Displays follow-up questions to help narrow down the product.
/// Full implementation: ISSUE-08.
struct ErrorView: View {

    let appError: AppError

    @Environment(NutritionViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 72))
                .foregroundStyle(ThemeColor.secondaryLabel)
                .accessibilityHidden(true)

            Text("We couldn't identify this food.\nLet's try to narrow it down.")
                .font(.body)
                .foregroundStyle(ThemeColor.label)
                .multilineTextAlignment(.center)

            Button {
                viewModel.clearSearch()
            } label: {
                Text("Try Again")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ThemeColor.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .accessibilityLabel("Try again with a new search")
        }
        .padding()
        .navigationTitle("Not Found")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ErrorView(appError: .productNotFound(followUpQuestions: ["Is it cooked?", "Do you know the brand?"]))
            .environment(NutritionViewModel(aiService: PreviewAIService()))
    }
}
