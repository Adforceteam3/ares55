import SwiftUI

struct AdvancedParametersView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    let onDismiss: () -> Void
    
    @State private var showingResetConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        advancedInputSection
                        
                        if viewModel.canShowResults {
                            previewSection
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .bottom).combined(with: .opacity)
                                ))
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                customNavigationBar,
                alignment: .top
            )
        }
        .confirmationDialog("Reset Parameters", isPresented: $showingResetConfirmation) {
            Button("Reset All", role: .destructive) {
                viewModel.resetAdvancedParameters()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset all advanced parameters to zero.")
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.canShowResults)
    }
    
    private var customNavigationBar: some View {
        HStack {
            Button(action: onDismiss) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("Back")
                        .font(.jostMedium(16))
                }
                .foregroundColor(AppColors.white)
            }
            
            Spacer()
            
            Button(action: {
                showingResetConfirmation = true
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .background(
            Rectangle()
                .fill(LinearGradient.primaryBackground)
                .ignoresSafeArea(edges: .top)
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Advanced Parameters")
                .font(.jostBold(24))
                .foregroundColor(AppColors.white)
            
            Text("Main discount → Additional discount → Fixed discount → Fixed fee → Tax")
                .font(.jostLight(14))
                .foregroundColor(AppColors.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(.top, 50)
    }
    
    private var advancedInputSection: some View {
        VStack(spacing: 16) {
            InputCard(
                title: "Additional Discount",
                value: $viewModel.additionalDiscountText,
                placeholder: "0",
                suffix: "%",
                errorMessage: viewModel.getValidationError(for: .additionalDiscount),
                keyboardType: .decimalPad
            )
            
            InputCard(
                title: "Fixed Discount",
                value: $viewModel.fixedDiscountText,
                placeholder: "0.00",
                prefix: "$",
                errorMessage: viewModel.getValidationError(for: .fixedDiscount),
                keyboardType: .decimalPad
            )
            
            InputCard(
                title: "Fixed Fee",
                value: $viewModel.fixedFeeText,
                placeholder: "0.00",
                prefix: "$",
                errorMessage: viewModel.getValidationError(for: .fixedFee),
                keyboardType: .decimalPad
            )
        }
    }
    
    private var previewSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Calculation Preview")
                    .font(.jostSemiBold(18))
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Button(action: {
                    viewModel.applyAdvancedParameters()
                    onDismiss()
                }) {
                    HStack(spacing: 6) {
                        Text("Apply")
                            .font(.jostSemiBold(14))
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(AppColors.success)
                    .cornerRadius(16)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 12)
            
            Divider()
                .background(AppColors.mediumGray.opacity(0.3))
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                StepRow(
                    step: "1",
                    label: "Original Price",
                    value: viewModel.calculation.originalPrice.currencyFormatted,
                    isStarting: true
                )
                
                if viewModel.calculation.mainDiscount > 0 {
                    StepRow(
                        step: "2",
                        label: "Main Discount (\(viewModel.calculation.mainDiscount.asPercentage()))",
                        value: "-\(viewModel.calculation.mainDiscountAmount.currencyFormatted)",
                        result: viewModel.calculation.priceAfterMainDiscount.currencyFormatted
                    )
                }
                
                if viewModel.calculation.additionalDiscount > 0 {
                    StepRow(
                        step: "3",
                        label: "Additional Discount (\(viewModel.calculation.additionalDiscount.asPercentage()))",
                        value: "-\(viewModel.calculation.additionalDiscountAmount.currencyFormatted)",
                        result: viewModel.calculation.priceAfterAdditionalDiscount.currencyFormatted
                    )
                }
                
                if viewModel.calculation.fixedDiscount > 0 {
                    StepRow(
                        step: "4",
                        label: "Fixed Discount",
                        value: "-\(viewModel.calculation.fixedDiscount.currencyFormatted)",
                        result: viewModel.calculation.priceAfterFixedDiscount.currencyFormatted
                    )
                }
                
                if viewModel.calculation.fixedFee > 0 {
                    StepRow(
                        step: "5",
                        label: "Fixed Fee",
                        value: "+\(viewModel.calculation.fixedFee.currencyFormatted)",
                        result: viewModel.calculation.priceAfterFixedFee.currencyFormatted
                    )
                }
                
                if viewModel.calculation.tax > 0 {
                    StepRow(
                        step: "6",
                        label: "Tax (\(viewModel.calculation.tax.asPercentage()))",
                        value: "+\(viewModel.calculation.taxAmount.currencyFormatted)",
                        result: viewModel.calculation.finalPrice.currencyFormatted,
                        isFinal: true
                    )
                } else {
                    StepRow(
                        step: "",
                        label: "Final Price",
                        value: "",
                        result: viewModel.calculation.finalPrice.currencyFormatted,
                        isFinal: true
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppColors.primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct StepRow: View {
    let step: String
    let label: String
    let value: String
    var result: String = ""
    var isStarting: Bool = false
    var isFinal: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                if !step.isEmpty {
                    Text(step)
                        .font(.jostBold(14))
                        .foregroundColor(AppColors.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(isFinal ? AppColors.success : AppColors.primaryBlue)
                        )
                }
                
                Text(label)
                    .font(isFinal ? .jostSemiBold(16) : .jostRegular(15))
                    .foregroundColor(isFinal ? AppColors.primaryBlue : AppColors.secondaryText)
                
                Spacer()
                
                if !value.isEmpty {
                    Text(value)
                        .font(.jostMedium(15))
                        .foregroundColor(
                            value.hasPrefix("+") ? AppColors.success :
                            value.hasPrefix("-") ? AppColors.error :
                            AppColors.secondaryText
                        )
                }
            }
            
            if !result.isEmpty && !isStarting {
                HStack {
                    if !step.isEmpty {
                        Spacer()
                            .frame(width: 24)
                    }
                    
                    Image(systemName: "arrow.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.mutedText)
                    
                    Spacer()
                    
                    Text("= \(result)")
                        .font(isFinal ? .jostBold(18) : .jostMedium(15))
                        .foregroundColor(isFinal ? AppColors.primaryBlue : AppColors.secondaryText)
                }
            }
        }
        .padding(.vertical, isStarting || isFinal ? 8 : 4)
    }
}

struct CalculationOrderInfo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppColors.info)
                Text("Calculation Order")
                    .font(.jostSemiBold(16))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                OrderStep(number: "1", text: "Apply main percentage discount")
                OrderStep(number: "2", text: "Apply additional percentage discount")
                OrderStep(number: "3", text: "Subtract fixed discount amount")
                OrderStep(number: "4", text: "Add fixed fee")
                OrderStep(number: "5", text: "Calculate and add tax")
            }
        }
        .padding(16)
        .background(AppColors.info.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.info.opacity(0.3), lineWidth: 1)
        )
    }
}

struct OrderStep: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.jostBold(12))
                .foregroundColor(AppColors.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(AppColors.info))
            
            Text(text)
                .font(.jostRegular(14))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

#Preview {
    AdvancedParametersView(viewModel: CalculatorViewModel()) {
        print("Dismiss")
    }
}

