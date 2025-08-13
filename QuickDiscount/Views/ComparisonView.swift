import SwiftUI

struct ComparisonView: View {
    @ObservedObject var viewModel: ComparisonViewModel
    let onSave: () -> Void
    
    @State private var showingSaveSuccess = false
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    HStack(alignment: .top, spacing: 16) {
                        VariantInputSection(
                            title: "Variant A",
                            viewModel: viewModel,
                            variant: .a
                        )
                        
                        VariantInputSection(
                            title: "Variant B",
                            viewModel: viewModel,
                            variant: .b
                        )
                    }
                    
                    if viewModel.canShowComparison {
                        comparisonResultsSection
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .move(edge: .bottom).combined(with: .opacity)
                            ))
                    }
                    
                    actionButtonsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .overlay(saveSuccessOverlay)
        .animation(.easeInOut(duration: 0.3), value: viewModel.canShowComparison)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Price Comparison")
                .font(.jostBold(28))
                .foregroundColor(AppColors.white)
            
            Text("Two variants — One choice")
                .font(.jostLight(16))
                .foregroundColor(AppColors.white.opacity(0.8))
        }
        .padding(.top, 10)
    }
    
    private var comparisonResultsSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(viewModel.comparison.betterOption.description)
                    .font(.jostBold(22))
                    .foregroundColor(AppColors.primaryBlue)
                
                if viewModel.comparison.priceDifference > 0 {
                    Text("Savings: \(viewModel.comparison.priceDifference.currencyFormatted)")
                        .font(.jostMedium(18))
                        .foregroundColor(AppColors.success)
                }
            }
            .padding(20)
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColors.primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
            
            HStack(spacing: 12) {
                ComparisonResultCard(
                    title: "Variant A",
                    finalPrice: viewModel.variantA.finalPrice,
                    isWinner: viewModel.comparison.betterOption == .variantA
                )
                
                ComparisonResultCard(
                    title: "Variant B",
                    finalPrice: viewModel.variantB.finalPrice,
                    isWinner: viewModel.comparison.betterOption == .variantB
                )
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.resetComparison()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                    Text("Reset Comparison")
                        .font(.jostMedium(16))
                }
                .foregroundColor(AppColors.primaryBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(AppColors.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primaryBlue.opacity(0.3), lineWidth: 1)
                )
            }
            
            Button(action: {
                onSave()
                showingSaveSuccess = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showingSaveSuccess = false
                }
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    Text("Save Comparison")
                        .font(.jostSemiBold(16))
                }
                .foregroundColor(AppColors.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(LinearGradient.buttonGradient)
                .cornerRadius(12)
            }
            .disabled(!viewModel.canSaveComparison)
            .opacity(viewModel.canSaveComparison ? 1.0 : 0.6)
        }
        .padding(.top, 8)
    }
    
    private var saveSuccessOverlay: some View {
        Group {
            if showingSaveSuccess {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                        Text("Comparison saved!")
                            .font(.jostMedium(16))
                            .foregroundColor(AppColors.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppColors.black.opacity(0.8))
                    .cornerRadius(25)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer()
                        .frame(height: 120)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingSaveSuccess)
            }
        }
    }
}

struct VariantInputSection: View {
    let title: String
    @ObservedObject var viewModel: ComparisonViewModel
    let variant: ComparisonVariant
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.jostSemiBold(18))
                .foregroundColor(AppColors.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                CompactInputCard(
                    title: "Price",
                    value: variant == .a ? $viewModel.originalPriceTextA : $viewModel.originalPriceTextB,
                    placeholder: "0.00",
                    prefix: "$"
                )
                
                CompactInputCard(
                    title: "Discount",
                    value: variant == .a ? $viewModel.mainDiscountTextA : $viewModel.mainDiscountTextB,
                    placeholder: "0",
                    suffix: "%"
                )
                
                CompactInputCard(
                    title: "Tax",
                    value: variant == .a ? $viewModel.taxTextA : $viewModel.taxTextB,
                    placeholder: "0",
                    suffix: "%"
                )
            }
            
            if (variant == .a && viewModel.variantAIsValid) || (variant == .b && viewModel.variantBIsValid) {
                let calculation = variant == .a ? viewModel.variantA : viewModel.variantB
                
                VStack(spacing: 8) {
                    Text("Final Price")
                        .font(.jostRegular(14))
                        .foregroundColor(AppColors.mutedText)
                    
                    Text(calculation.finalPrice.currencyFormatted)
                        .font(.jostBold(20))
                        .foregroundColor(AppColors.white)
                }
                .padding(12)
                .background(AppColors.white.opacity(0.1))
                .cornerRadius(8)
                .transition(.opacity)
            }
        }
        .padding(16)
        .background(AppColors.white.opacity(0.05))
        .cornerRadius(16)
        .frame(maxWidth: .infinity)
    }
}

struct CompactInputCard: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    var prefix: String = ""
    var suffix: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.jostMedium(12))
                .foregroundColor(AppColors.white.opacity(0.8))
            
            HStack(spacing: 6) {
                if !prefix.isEmpty {
                    Text(prefix)
                        .font(.jostMedium(14))
                        .foregroundColor(AppColors.mutedText)
                }
                
                TextField(placeholder, text: $value)
                    .font(.jostRegular(14))
                    .foregroundColor(AppColors.secondaryText)
                    .keyboardType(.decimalPad)
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.jostMedium(14))
                        .foregroundColor(AppColors.mutedText)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppColors.white)
            .cornerRadius(8)
        }
    }
}

struct ComparisonResultCard: View {
    let title: String
    let finalPrice: Double
    let isWinner: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.jostMedium(16))
                .foregroundColor(AppColors.secondaryText)
            
            Text(finalPrice.currencyFormatted)
                .font(.jostBold(20))
                .foregroundColor(isWinner ? AppColors.success : AppColors.secondaryText)
            
            if isWinner {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Better Deal")
                        .font(.jostMedium(12))
                }
                .foregroundColor(AppColors.success)
            }
        }
        .padding(16)
        .frame(maxHeight: .infinity)
        .background(isWinner ? AppColors.success.opacity(0.1) : AppColors.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isWinner ? AppColors.success : Color.clear, lineWidth: 2)
        )
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ComparisonView(viewModel: ComparisonViewModel()) {
        print("Save comparison")
    }
}

