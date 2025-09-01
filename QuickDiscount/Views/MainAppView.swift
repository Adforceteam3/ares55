import SwiftUI
import StoreKit

struct MainAppView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            if appViewModel.showingSplash {
                AlternativeSplashView()
                    .transition(.opacity)
            } else if appViewModel.screen {
                DuckView()
                    .onAppear {
                        if UserDefaults.standard.integer(forKey: "counter") == 2 {
                            requestReview()
                        }
                    }
            } else if appViewModel.showingOnboarding {
                OnboardingView {
                    appViewModel.completeOnboarding()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .leading)
                ))
            } else {
                mainContent
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            }
        }
        .alert(isPresented: $appViewModel.showAlert) {
            Alert(title: Text("Try logging in later"), dismissButton: .cancel())
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
        .onAppear {
            FontManager.registerFonts()
            appViewModel.onAppear()
        }
        .onDisappear {
            appViewModel.onDisappear()
        }
        .animation(.easeInOut(duration: 0.5), value: appViewModel.showingSplash)
        .animation(.easeInOut(duration: 0.5), value: appViewModel.showingOnboarding)
    }
    
    func requestReview() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private var mainContent: some View {
        ZStack {
            TabView(selection: $appViewModel.selectedTab) {
                CalculatorView(viewModel: appViewModel.calculatorViewModel) {
                    appViewModel.saveCalculation()
                }
                .tag(TabItem.calculator)
                
                AnalyticsView(viewModel: appViewModel.analyticsViewModel)
                    .tag(TabItem.analytics)
                
                HistoryView(viewModel: appViewModel.historyViewModel)
                    .tag(TabItem.history)
                
                ComparisonView(viewModel: appViewModel.comparisonViewModel) {
                    appViewModel.saveComparison()
                }
                .tag(TabItem.comparison)
                
                SettingsView(
                    onRateApp: appViewModel.rateApp,
                    onTermsAndConditions: appViewModel.openTermsAndConditions,
                    onPrivacyPolicy: appViewModel.openPrivacyPolicy,
                    onContactSupport: appViewModel.contactSupport
                )
                .tag(TabItem.settings)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $appViewModel.selectedTab)
                    .onChange(of: appViewModel.selectedTab) { newTab in
                        appViewModel.selectTab(newTab)
                    }
            }
        }
        .ignoresSafeArea()
    }
}


