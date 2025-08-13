import Foundation

struct AppState: Codable {
    var hasCompletedOnboarding: Bool = false
    var isFirstLaunch: Bool = true
    
    static let userDefaultsKey = "AppState"
    
    static func load() -> AppState {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let state = try? JSONDecoder().decode(AppState.self, from: data) else {
            return AppState()
        }
        return state
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: AppState.userDefaultsKey)
    }
}

enum TabItem: String, CaseIterable {
    case calculator = "calculator"
    case analytics = "analytics"
    case history = "history"
    case comparison = "comparison"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .calculator:
            return "Calculator"
        case .analytics:
            return "Analytics"
        case .history:
            return "History"
        case .comparison:
            return "Compare"
        case .settings:
            return "Settings"
        }
    }
    
    var iconName: String {
        switch self {
        case .calculator:
            return "plus.forwardslash.minus"
        case .analytics:
            return "chart.bar"
        case .history:
            return "clock"
        case .comparison:
            return "scale.3d"
        case .settings:
            return "gear"
        }
    }
}

