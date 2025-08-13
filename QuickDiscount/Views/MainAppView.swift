import SwiftUI

struct MainAppView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            if appViewModel.showingSplash {
                AlternativeSplashView()
                    .transition(.opacity)
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

struct AlternativeMainAppView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        ZStack {
            if appViewModel.showingSplash {
                AlternativeSplashView()
                    .transition(.opacity)
            } else if appViewModel.showingOnboarding {
                OnboardingView {
                    appViewModel.completeOnboarding()
                }
                .transition(.slide)
            } else {
                ZStack {
                    LinearGradient.primaryBackground
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        Group {
                            switch appViewModel.selectedTab {
                            case .calculator:
                                CalculatorView(viewModel: appViewModel.calculatorViewModel) {
                                    appViewModel.saveCalculation()
                                }
                            case .analytics:
                                AnalyticsView(viewModel: appViewModel.analyticsViewModel)
                            case .history:
                                HistoryView(viewModel: appViewModel.historyViewModel)
                            case .comparison:
                                ComparisonView(viewModel: appViewModel.comparisonViewModel) {
                                    appViewModel.saveComparison()
                                }
                            case .settings:
                                AlternativeSettingsView(
                                    onRateApp: appViewModel.rateApp,
                                    onTermsAndConditions: appViewModel.openTermsAndConditions,
                                    onPrivacyPolicy: appViewModel.openPrivacyPolicy,
                                    onContactSupport: appViewModel.contactSupport
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        FloatingTabBar(selectedTab: $appViewModel.selectedTab)
                    }
                }
                .transition(.slide)
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
}

struct MinimalMainAppView: View {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        Group {
            if appViewModel.showingSplash {
                SplashView()
            } else if appViewModel.showingOnboarding {
                OnboardingView {
                    appViewModel.completeOnboarding()
                }
            } else {
                TabView(selection: $appViewModel.selectedTab) {
                    CalculatorView(viewModel: appViewModel.calculatorViewModel) {
                        appViewModel.saveCalculation()
                    }
                    .tabItem {
                        Image(systemName: "plus.forwardslash.minus")
                        Text("Calculator")
                    }
                    .tag(TabItem.calculator)
                    
                    AnalyticsView(viewModel: appViewModel.analyticsViewModel)
                        .tabItem {
                            Image(systemName: "chart.bar")
                            Text("Analytics")
                        }
                        .tag(TabItem.analytics)
                    
                    HistoryView(viewModel: appViewModel.historyViewModel)
                        .tabItem {
                            Image(systemName: "clock")
                            Text("History")
                        }
                        .tag(TabItem.history)
                    
                    ComparisonView(viewModel: appViewModel.comparisonViewModel) {
                        appViewModel.saveComparison()
                    }
                    .tabItem {
                        Image(systemName: "scale.3d")
                        Text("Compare")
                    }
                    .tag(TabItem.comparison)
                    
                    SettingsView(
                        onRateApp: appViewModel.rateApp,
                        onTermsAndConditions: appViewModel.openTermsAndConditions,
                        onPrivacyPolicy: appViewModel.openPrivacyPolicy,
                        onContactSupport: appViewModel.contactSupport
                    )
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .tag(TabItem.settings)
                }
                .accentColor(AppColors.primaryBlue)
            }
        }
        .onAppear {
            FontManager.registerFonts()
            appViewModel.onAppear()
        }
    }
}


