import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let onComplete: () -> Void
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            VStack {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? AppColors.white : AppColors.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                VStack(spacing: 20) {
                    if currentPage == pages.count - 1 {
                        Button(action: onComplete) {
                            HStack {
                                Text("Get Started")
                                    .font(.jostSemiBold(18))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(AppColors.primaryBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AppColors.white)
                            .cornerRadius(27)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    } else {
                        HStack {
                            Button("Skip") {
                                onComplete()
                            }
                            .font(.jostRegular(16))
                            .foregroundColor(AppColors.white.opacity(0.8))
                            
                            Spacer()
                            
                            Button(action: nextPage) {
                                HStack(spacing: 8) {
                                    Text("Next")
                                        .font(.jostSemiBold(16))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(AppColors.primaryBlue)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(AppColors.white)
                                .cornerRadius(20)
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func nextPage() {
        withAnimation(.easeInOut(duration: 0.5)) {
            if currentPage < pages.count - 1 {
                currentPage += 1
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppColors.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateContent ? 1.0 : 0.8)
                    .opacity(animateContent ? 1 : 0)
                
                Image(systemName: page.iconName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(AppColors.white)
                    .scaleEffect(animateContent ? 1.0 : 0.5)
                    .opacity(animateContent ? 1 : 0)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: animateContent)
            
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.jostBold(28))
                    .foregroundColor(AppColors.white)
                    .multilineTextAlignment(.center)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: animateContent)
                
                Text(page.description)
                    .font(.jostRegular(17))
                    .foregroundColor(AppColors.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: animateContent)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            animateContent = true
        }
        .onDisappear {
            animateContent = false
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let iconName: String
    
    static let allPages = [
        OnboardingPage(
            title: "Quick Discount Calculator",
            description: "Calculate final prices in seconds. Enter the base price, set a discount, and add tax — the app instantly shows the final amount.",
            iconName: "plus.forwardslash.minus"
        ),
        OnboardingPage(
            title: "Advanced Controls",
            description: "Need more control? Apply extra percentage discounts, fixed coupons, or handling fees before tax.",
            iconName: "slider.horizontal.3"
        ),
        OnboardingPage(
            title: "Compare & Save",
            description: "Save your results, compare two options side by side, and review clean analytics to understand how your final prices change over time.",
            iconName: "chart.bar.fill"
        ),
        OnboardingPage(
            title: "Simple & Fast",
            description: "Simple, accurate, and fast for shopping, work, or everyday budgeting. Let's get started!",
            iconName: "bolt.fill"
        )
    ]
}

struct OnboardingBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.deepBlue],
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(AppColors.white.opacity(0.05))
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...400),
                        y: CGFloat.random(in: 0...800)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.5),
                        value: animateGradient
                    )
            }
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding completed")
    }
}

