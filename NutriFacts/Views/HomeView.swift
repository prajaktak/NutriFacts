// HomeView.swift
// NutriFacts

import SwiftUI
import UIKit

/// Root screen of the app. Provides text, mic, and camera input controls,
/// and navigates to ResultsView on success or ErrorView on error.
struct HomeView: View {

    @Environment(NutritionViewModel.self) private var viewModel

    @State private var isMicrophoneAlertPresented = false
    @State private var isCameraAlertPresented = false
    @State private var isPhotoLibraryAlertPresented = false
    @State private var isSpeechRecognitionAlertPresented = false

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
            .navigationDestination(isPresented: isShowingResultsBinding) {
                resultsDestination
            }
            .navigationDestination(isPresented: isShowingErrorBinding) {
                errorDestination
            }
            .alert(PermissionStrings.microphoneDeniedTitle, isPresented: $isMicrophoneAlertPresented) {
                permissionAlertButtons
            } message: {
                Text(PermissionStrings.microphoneDeniedMessage)
            }
            .alert(PermissionStrings.cameraDeniedTitle, isPresented: $isCameraAlertPresented) {
                permissionAlertButtons
            } message: {
                Text(PermissionStrings.cameraDeniedMessage)
            }
            .alert(PermissionStrings.photoLibraryDeniedTitle, isPresented: $isPhotoLibraryAlertPresented) {
                permissionAlertButtons
            } message: {
                Text(PermissionStrings.photoLibraryDeniedMessage)
            }
            .alert(PermissionStrings.speechRecognitionDeniedTitle, isPresented: $isSpeechRecognitionAlertPresented) {
                permissionAlertButtons
            } message: {
                Text(PermissionStrings.speechRecognitionDeniedMessage)
            }
        }
    }

    // MARK: - Navigation Bindings

    /// Binding that reads from viewModel.isShowingResults and clears state on dismiss.
    private var isShowingResultsBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isShowingResults },
            set: { isPresented in
                if !isPresented { viewModel.clearSearch() }
            }
        )
    }

    /// Binding that reads from viewModel.isShowingError and clears state on dismiss.
    private var isShowingErrorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isShowingError },
            set: { isPresented in
                if !isPresented { viewModel.clearSearch() }
            }
        )
    }

    // MARK: - Navigation Destinations

    @ViewBuilder
    private var resultsDestination: some View {
        if case .success(let nutritionFacts) = viewModel.appState {
            ResultsView(nutritionFacts: nutritionFacts)
        }
    }

    @ViewBuilder
    private var errorDestination: some View {
        if case .error(let appError) = viewModel.appState {
            ErrorView(appError: appError)
        }
    }

    // MARK: - Subviews

    private var inputButtonsRow: some View {
        HStack(spacing: 32) {
            Button {
                // Speech input — wired in ISSUE-12
                // Shows permission-denied alert if microphone or speech recognition access is denied
                isMicrophoneAlertPresented = true
            } label: {
                Image(systemName: "mic.fill")
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
                // Shows permission-denied alert if camera or photo library access is denied
                isCameraAlertPresented = true
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
    private var permissionAlertButtons: some View {
        Button(PermissionStrings.goToSettingsButtonLabel) {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        Button(PermissionStrings.cancelButtonLabel, role: .cancel) {}
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
        case .success, .error:
            // Handled by navigationDestination above
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
