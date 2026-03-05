// ErrorView.swift
// NutriFacts

import SwiftUI

/// Shown when the AI cannot identify the food.
/// For productNotFound errors: displays AI-generated follow-up questions and a retry button.
/// For other errors: displays a friendly message and a try-again button.
struct ErrorView: View {

    let appError: AppError

    @Environment(NutritionViewModel.self) private var viewModel
    @State private var followUpAnswers: [String] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                errorIllustration
                errorMessageText

                if case .productNotFound(let questions) = appError, !questions.isEmpty {
                    followUpQuestionsSection(questions: questions)
                }

                retryButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .navigationTitle("Not Found")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            initializeAnswers()
        }
    }

    // MARK: - Subviews

    private var errorIllustration: some View {
        Image(systemName: "questionmark.circle")
            .font(.system(size: 72))
            .foregroundStyle(ThemeColor.secondaryLabel)
            .accessibilityHidden(true)
    }

    private var errorMessageText: some View {
        Text(appError.userFriendlyMessage)
            .font(.body)
            .foregroundStyle(ThemeColor.label)
            .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private func followUpQuestionsSection(questions: [String]) -> some View {
        VStack(spacing: 16) {
            ForEach(Array(questions.enumerated()), id: \.offset) { questionIndex, question in
                VStack(alignment: .leading, spacing: 8) {
                    Text(question)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(ThemeColor.label)

                    if followUpAnswers.indices.contains(questionIndex) {
                        TextField("Your answer", text: $followUpAnswers[questionIndex])
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(16)
                .background(ThemeColor.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var retryButton: some View {
        Button {
            submitRetry()
        } label: {
            Text("Try Again")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ThemeColor.accent)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityLabel("Try again with updated information")
    }

    // MARK: - Actions

    private func initializeAnswers() {
        if case .productNotFound(let questions) = appError {
            followUpAnswers = Array(repeating: "", count: questions.count)
        }
    }

    private func submitRetry() {
        let context = followUpAnswers
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        Task {
            await viewModel.retrySearch(withContext: context)
        }
    }
}

#Preview {
    NavigationStack {
        ErrorView(appError: .productNotFound(followUpQuestions: [
            "Is it raw or cooked?",
            "Do you know the brand name?"
        ]))
        .environment(NutritionViewModel(aiService: PreviewAIService()))
    }
}
