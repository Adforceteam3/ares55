import SwiftUI

struct SettingsView: View {
    let onRateApp: () -> Void
    let onTermsAndConditions: () -> Void
    let onPrivacyPolicy: () -> Void
    let onContactSupport: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    appInfoSection
                    
                    actionButtonsSection
                    
                    legalSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Settings")
                .font(.jostBold(28))
                .foregroundColor(AppColors.white)
            
            Text("App preferences and information")
                .font(.jostLight(16))
                .foregroundColor(AppColors.white.opacity(0.8))
        }
        .padding(.top, 10)
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.white.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "plus.forwardslash.minus")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.white)
                }
                
                VStack(spacing: 4) {
                    Text("QuickDiscount Calculator")
                        .font(.jostSemiBold(20))
                        .foregroundColor(AppColors.white)
 
                }
            }
        }
        .padding(20)
        .background(AppColors.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "star.fill",
                title: "Rate This App",
                subtitle: "Help us improve with your feedback",
                iconColor: AppColors.warning,
                action: onRateApp
            )
            
            Divider()
                .background(AppColors.white.opacity(0.1))
                .padding(.leading, 60)
            
            SettingsRow(
                icon: "envelope.fill",
                title: "Contact Support",
                subtitle: "Get help or send feedback",
                iconColor: AppColors.info,
                action: onContactSupport
            )
        }
        .background(AppColors.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var legalSection: some View {
        VStack(spacing: 0) {
            SettingsRow(
                icon: "doc.text.fill",
                title: "Terms & Conditions",
                subtitle: "User agreement and terms of use",
                iconColor: AppColors.mutedText,
                action: onTermsAndConditions
            )
            
            Divider()
                .background(AppColors.white.opacity(0.1))
                .padding(.leading, 60)
            
            SettingsRow(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                subtitle: "Data protection and privacy statement",
                iconColor: AppColors.mutedText,
                action: onPrivacyPolicy
            )
        }
        .background(AppColors.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.jostMedium(16))
                        .foregroundColor(AppColors.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(subtitle)
                        .font(.jostRegular(13))
                        .foregroundColor(AppColors.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isPressed ? AppColors.white.opacity(0.1) : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

struct AlternativeSettingsView: View {
    let onRateApp: () -> Void
    let onTermsAndConditions: () -> Void
    let onPrivacyPolicy: () -> Void
    let onContactSupport: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Settings")
                        .font(.jostBold(28))
                        .foregroundColor(AppColors.white)
                        .padding(.top, 10)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        SettingsCard(
                            icon: "star.fill",
                            title: "Rate App",
                            color: AppColors.warning,
                            action: onRateApp
                        )
                        
                        SettingsCard(
                            icon: "envelope.fill",
                            title: "Contact Us",
                            color: AppColors.info,
                            action: onContactSupport
                        )
                        
                        SettingsCard(
                            icon: "doc.text.fill",
                            title: "Terms",
                            color: AppColors.mutedText,
                            action: onTermsAndConditions
                        )
                        
                        SettingsCard(
                            icon: "lock.shield.fill",
                            title: "Privacy",
                            color: AppColors.mutedText,
                            action: onPrivacyPolicy
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    VStack(spacing: 8) {
                        Text("QuickDiscount Calculator")
                            .font(.jostMedium(16))
                            .foregroundColor(AppColors.white.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }
}

struct SettingsCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.jostMedium(14))
                    .foregroundColor(AppColors.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(AppColors.white.opacity(isPressed ? 0.15 : 0.05))
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

#Preview("Settings") {
    SettingsView(
        onRateApp: { print("Rate app") },
        onTermsAndConditions: { print("Terms") },
        onPrivacyPolicy: { print("Privacy") },
        onContactSupport: { print("Contact") }
    )
}

#Preview("Alternative Settings") {
    AlternativeSettingsView(
        onRateApp: { print("Rate app") },
        onTermsAndConditions: { print("Terms") },
        onPrivacyPolicy: { print("Privacy") },
        onContactSupport: { print("Contact") }
    )
}

