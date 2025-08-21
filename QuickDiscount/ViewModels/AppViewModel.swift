import Foundation
import StoreKit
import Combine

class AppViewModel: ObservableObject {
    @Published var appState = AppState.load()
    @Published var selectedTab: TabItem = .calculator
    @Published var showingSplash = true
    @Published var showingOnboarding = false
    
    @Published var calculatorViewModel = CalculatorViewModel()
    @Published var historyViewModel = HistoryViewModel()
    @Published var comparisonViewModel = ComparisonViewModel()
    
    lazy var analyticsViewModel = AnalyticsViewModel(historyViewModel: historyViewModel)
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAppFlow()
    }
    
    private func setupAppFlow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showingSplash = false
            
            if self.appState.isFirstLaunch || !self.appState.hasCompletedOnboarding {
                self.showingOnboarding = true
            }
        }
    }
    
    func completeOnboarding() {
        appState.hasCompletedOnboarding = true
        appState.isFirstLaunch = false
        appState.save()
        
        showingOnboarding = false
        selectedTab = .calculator
    }
    
    func saveCalculation() {
        guard calculatorViewModel.canSaveCalculation else { return }
        historyViewModel.addCalculation(calculatorViewModel.calculation)
        
        DispatchQueue.main.async {
            self.analyticsViewModel.updateAnalytics()
        }
    }
    
    func saveComparison() {
        guard comparisonViewModel.canSaveComparison else { return }
        historyViewModel.addComparison(comparisonViewModel.comparison)
        
        DispatchQueue.main.async {
            self.analyticsViewModel.updateAnalytics()
        }
    }
    
    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    func openTermsAndConditions() {
        openURL("https://sites.google.com/adforcegroup.com/id6751346756")
    }
    
    func openPrivacyPolicy() {
        openURL("https://sites.google.com/adforcegroup.com/id-6751346756")
    }
    
    func contactSupport() {
        openURL("https://forms.gle/7SYSe7SP3bzsvsWM8")
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    func selectTab(_ tab: TabItem) {
        selectedTab = tab
        
        if tab == .analytics {
            DispatchQueue.main.async {
                self.analyticsViewModel.updateAnalytics()
            }
        }
    }
    
    func resetAllData() {
        calculatorViewModel.resetCalculation()
        comparisonViewModel.resetComparison()
        analyticsViewModel.resetToDefaults()
        
    }
    
    func onAppear() {
        analyticsViewModel.updateAnalytics()
    }
    
    func onDisappear() {
        appState.save()
    }
}
