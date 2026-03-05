// HomeView.swift
// NutriFacts

import SwiftUI

/// Root screen of the app. Provides text, mic, and camera input controls,
/// and shows the appropriate state (idle, loading) based on the ViewModel.
struct HomeView: View {

    @Environment(NutritionViewModel.self) private var viewModel

    var body: some View {
        @Bindable var bindableViewModel = viewModel
        NavigationStack {
            VStack(spacing: 16) {
                SearchBarView(
                    searchText: $bindableViewModel.searchText,
                    isDisabled: viewModel.isLoading,
                    onSubmit: submitSearch
                )
                .padding(.horizontal, 16)

                inputButtonsRow

                Spacer()

                contentArea

                Spacer()
            }
            .navigationTitle("NutriFacts")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Subviews

    private var inputButtonsRow: some View {
        HStack(spacing: 32) {
            Button {
                // Speech input — wired in ISSUE-12
            } label: {
                Image(systemName: viewModel.isRecording ? "mic.fill" : "mic.fill")
                    .font(.title2)
                    .foregroundStyle(viewModel.isRecording ? ThemeColor.error : ThemeColor.accent)
                    .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true),
                               value: viewModel.isRecording)
            }
            .accessibilityLabel(viewModel.isRecording ? "Stop recording" : "Search by voice")
            .disabled(viewModel.isLoading)

            Button {
                // Photo input — wired in ISSUE-13
            } label: {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundStyle(ThemeColor.accent)
            }
            .accessibilityLabel("Search by photo")
            .disabled(viewModel.isLoading)
        }
    }

    @ViewBuilder
    private var contentArea: some View {
        switch viewModel.appState {
        case .idle:
            VStack(spacing: 24) {
                SuggestionChipsView(onChipSelected: selectChip)
                EmptyStateView()
            }
        case .loading:
            LoadingView(searchText: viewModel.searchText)
        case .success:
            // Navigation to ResultsView is handled in ContentView (ISSUE-04)
            EmptyView()
        case .error:
            // Navigation to ErrorView is handled in ContentView (ISSUE-04)
            EmptyView()
        }
    }

    // MARK: - Actions

    private func submitSearch() {
        Task {
            await viewModel.search()
        }
    }

    private func selectChip(_ chipValue: String) {
        viewModel.searchText = chipValue
        Task {
            await viewModel.search()
        }
    }
}

// MARK: - ViewModel convenience

private extension NutritionViewModel {
    var isLoading: Bool {
        if case .loading = appState { return true }
        return false
    }
}

#Preview {
    HomeView()
        .environment(NutritionViewModel(aiService: PreviewAIService()))
}
