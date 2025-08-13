import SwiftUI

@main
struct QuickDiscountApp: App {
    init() {
        FontManager.registerFonts()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppColors.primaryBlue)
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .preferredColorScheme(.light) 
        }
    }
}
