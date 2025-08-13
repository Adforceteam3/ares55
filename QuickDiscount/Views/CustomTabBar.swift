import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabBarButton(
                    tab: tab,
                    selectedTab: $selectedTab,
                    animation: animation
                )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(AppColors.white)
                .shadow(color: AppColors.primaryBlue.opacity(0.15), radius: 20, x: 0, y: 5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let tab: TabItem
    @Binding var selectedTab: TabItem
    let animation: Namespace.ID
    
    @State private var isPressed = false
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.lightBlue, AppColors.primaryBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 28)
                            .matchedGeometryEffect(id: "selectedTab", in: animation)
                    }
                    
                    Image(systemName: tab.iconName)
                        .font(.system(size: isSelected ? 16 : 15, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? AppColors.white : AppColors.mediumGray)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: isPressed)
                }
                
                Text(tab.title)
                    .font(.jostMedium(isSelected ? 12 : 10))
                    .foregroundColor(isSelected ? AppColors.primaryBlue : AppColors.mediumGray)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

struct AnimatedTabBar: View {
    @Binding var selectedTab: TabItem
    @State private var animationOffset: CGFloat = 0
    
    private let tabs = TabItem.allCases
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(AppColors.white)
                    .shadow(color: AppColors.primaryBlue.opacity(0.1), radius: 15, x: 0, y: 8)
                
                HStack {
                    Spacer()
                        .frame(width: animationOffset)
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.lightBlue, AppColors.primaryBlue],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 8, height: 8)
                        .offset(y: -25)
                    
                    Spacer()
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: selectedTab)
                
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.rawValue) { tab in
                        AnimatedTabButton(
                            tab: tab,
                            isSelected: selectedTab == tab
                        ) {
                            selectedTab = tab
                            updateIndicatorPosition(for: tab, geometry: geometry)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
            }
        }
        .frame(height: 70)
        .onAppear {
            updateIndicatorPosition(for: selectedTab, geometry: nil)
        }
    }
    
    private func updateIndicatorPosition(for tab: TabItem, geometry: GeometryProxy?) {
        guard let geometry = geometry else { return }
        
        let tabWidth = geometry.size.width / CGFloat(tabs.count)
        let tabIndex = tabs.firstIndex(of: tab) ?? 0
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            animationOffset = CGFloat(tabIndex) * tabWidth + tabWidth / 2 - 4
        }
    }
}

struct AnimatedTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: tab.iconName)
                    .font(.system(size: isSelected ? 18 : 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? AppColors.primaryBlue : AppColors.mediumGray)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(tab.title)
                    .font(.jostMedium(10))
                    .foregroundColor(isSelected ? AppColors.primaryBlue : AppColors.mediumGray)
                    .opacity(isSelected ? 1.0 : 0.7)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: TabItem
    @Namespace private var animation
    
    private let tabs = TabItem.allCases
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs, id: \.rawValue) { tab in
                FloatingTabButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(AppColors.white)
                .shadow(color: AppColors.primaryBlue.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
}

struct FloatingTabButton: View {
    let tab: TabItem
    let isSelected: Bool
    let animation: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? AppColors.white : AppColors.primaryBlue)
                
                if isSelected {
                    Text(tab.title)
                        .font(.jostMedium(14))
                        .foregroundColor(AppColors.white)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.lightBlue, AppColors.primaryBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .matchedGeometryEffect(id: "selectedTab", in: animation)
                    }
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
    }
}

#Preview("Custom Tab Bar") {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.calculator))
    }
    .background(LinearGradient.primaryBackground)
}

#Preview("Animated Tab Bar") {
    VStack {
        Spacer()
        AnimatedTabBar(selectedTab: .constant(.analytics))
            .padding()
    }
    .background(LinearGradient.primaryBackground)
}

#Preview("Floating Tab Bar") {
    VStack {
        Spacer()
        FloatingTabBar(selectedTab: .constant(.history))
    }
    .background(LinearGradient.primaryBackground)
}

