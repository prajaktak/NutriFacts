// ContentView.swift
// NutriFacts

import SwiftUI

/// Root container view. Injects NutritionViewModel into the environment
/// and hosts HomeView as the entry point.
struct ContentView: View {

    @State private var viewModel = NutritionViewModel(aiService: PreviewAIService())

    var body: some View {
        HomeView()
            .environment(viewModel)
    }
}

#Preview {
    ContentView()
}
