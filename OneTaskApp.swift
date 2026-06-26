import SwiftUI

@main
struct OneTaskApp: App {
    @StateObject private var viewModel = MainViewModel()

    var body: some Scene {
        WindowGroup {
            RootView(viewModel: viewModel)
        }
    }
}

struct RootView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showOnboarding = false

    var body: some View {
        MainView(viewModel: viewModel)
            .tint(viewModel.theme.accentColor)
            .preferredColorScheme(viewModel.theme.appearance.colorScheme)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingView {
                    viewModel.completeOnboarding()
                    showOnboarding = false
                }
            }
            .onAppear { showOnboarding = viewModel.needsOnboarding }
    }
}
