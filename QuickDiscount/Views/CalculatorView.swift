import SwiftUI

struct CalculatorView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    @State private var showingAdvancedParameters = false
    @State private var showingSaveSuccess = false
    
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    inputSection
                    
                    if viewModel.canShowResults {
                        resultsSection
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
        .sheet(isPresented: $showingAdvancedParameters) {
            AdvancedParametersView(viewModel: viewModel) {
                showingAdvancedParameters = false
            }
        }
        .overlay(
            saveSuccessOverlay
        )
        .animation(.easeInOut(duration: 0.3), value: viewModel.canShowResults)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Discount Calculator")
                .font(.jostBold(28))
                .foregroundColor(AppColors.white)
            
            Text("Price → Discount → Tax")
                .font(.jostLight(16))
                .foregroundColor(AppColors.white.opacity(0.8))
        }
        .padding(.top, 10)
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            InputCard(
                title: "Original Price",
                value: $viewModel.originalPriceText,
                placeholder: "0.00",
                prefix: "$",
                errorMessage: viewModel.getValidationError(for: .originalPrice),
                keyboardType: .decimalPad
            )
            
            InputCard(
                title: "Discount",
                value: $viewModel.mainDiscountText,
                placeholder: "0",
                suffix: "%",
                errorMessage: viewModel.getValidationError(for: .mainDiscount),
                keyboardType: .decimalPad
            )
            
            InputCard(
                title: "Tax",
                value: $viewModel.taxText,
                placeholder: "0",
                suffix: "%",
                errorMessage: viewModel.getValidationError(for: .tax),
                keyboardType: .decimalPad
            )
        }
    }
    
    private var resultsSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Text("Calculation Results")
                        .font(.jostSemiBold(18))
                        .foregroundColor(AppColors.secondaryText)
                    Spacer()
                }
                
                Divider()
                    .background(AppColors.mediumGray.opacity(0.3))
                
                if viewModel.calculation.hasAdvancedParameters {
                    advancedResultsBreakdown
                } else {
                    basicResultsBreakdown
                }
                
                Divider()
                    .background(AppColors.mediumGray.opacity(0.3))
                
                HStack {
                    Text("Final Price")
                        .font(.jostSemiBold(20))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    Text(viewModel.calculation.finalPrice.currencyFormatted)
                        .font(.priceDisplay)
                        .foregroundColor(AppColors.primaryBlue)
                }
                
                Text("Rounding to cents applied to discount and tax")
                    .font(.caption2)
                    .foregroundColor(AppColors.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .padding(20)
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: AppColors.primaryBlue.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    private var basicResultsBreakdown: some View {
        VStack(spacing: 8) {
            ResultRow(
                label: "Discount Amount",
                value: "-\(viewModel.calculation.mainDiscountAmount.currencyFormatted)",
                valueColor: AppColors.error
            )
            
            ResultRow(
                label: "Price After Discount",
                value: viewModel.calculation.priceAfterMainDiscount.currencyFormatted,
                valueColor: AppColors.secondaryText
            )
            
            ResultRow(
                label: "Tax Amount",
                value: "+\(viewModel.calculation.taxAmount.currencyFormatted)",
                valueColor: AppColors.success
            )
        }
    }
    
    private var advancedResultsBreakdown: some View {
        VStack(spacing: 8) {
            if viewModel.calculation.mainDiscount > 0 {
                ResultRow(
                    label: "Main Discount",
                    value: "-\(viewModel.calculation.mainDiscountAmount.currencyFormatted)",
                    valueColor: AppColors.error
                )
            }
            
            if viewModel.calculation.additionalDiscount > 0 {
                ResultRow(
                    label: "Additional Discount",
                    value: "-\(viewModel.calculation.additionalDiscountAmount.currencyFormatted)",
                    valueColor: AppColors.error
                )
            }
            
            if viewModel.calculation.fixedDiscount > 0 {
                ResultRow(
                    label: "Fixed Discount",
                    value: "-\(viewModel.calculation.fixedDiscount.currencyFormatted)",
                    valueColor: AppColors.error
                )
            }
            
            ResultRow(
                label: "After All Discounts",
                value: viewModel.calculation.priceAfterFixedDiscount.currencyFormatted,
                valueColor: AppColors.secondaryText
            )
            
            if viewModel.calculation.fixedFee > 0 {
                ResultRow(
                    label: "Fixed Fee",
                    value: "+\(viewModel.calculation.fixedFee.currencyFormatted)",
                    valueColor: AppColors.warning
                )
            }
            
            ResultRow(
                label: "Tax Base",
                value: viewModel.calculation.priceAfterFixedFee.currencyFormatted,
                valueColor: AppColors.secondaryText
            )
            
            if viewModel.calculation.tax > 0 {
                ResultRow(
                    label: "Tax Amount",
                    value: "+\(viewModel.calculation.taxAmount.currencyFormatted)",
                    valueColor: AppColors.success
                )
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            Button(action: {
                showingAdvancedParameters = true
            }) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                    Text("Advanced Parameters")
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
                    Text("Save Calculation")
                        .font(.jostSemiBold(16))
                }
                .foregroundColor(AppColors.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient.buttonGradient
                )
                .cornerRadius(12)
            }
            .disabled(!viewModel.canSaveCalculation)
            .opacity(viewModel.canSaveCalculation ? 1.0 : 0.6)
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
                        Text("Calculation saved!")
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

struct InputCard: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    var prefix: String = ""
    var suffix: String = ""
    let errorMessage: String?
    let keyboardType: UIKeyboardType
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.jostMedium(16))
                .foregroundColor(AppColors.white)
            
            HStack(spacing: 8) {
                if !prefix.isEmpty {
                    Text(prefix)
                        .font(.jostMedium(18))
                        .foregroundColor(AppColors.mutedText)
                }
                
                TextField(placeholder, text: $value)
                    .font(.jostRegular(18))
                    .foregroundColor(AppColors.secondaryText)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
                    .onChange(of: value) { newValue in
                        if prefix.contains("$") {
                            value = InputValidator.formatCurrencyInput(newValue)
                        } else if suffix.contains("%") {
                            value = InputValidator.formatPercentageInput(newValue)
                        }
                    }
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.jostMedium(18))
                        .foregroundColor(AppColors.mutedText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColors.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        errorMessage != nil ? AppColors.error : 
                        isFocused ? AppColors.primaryBlue : 
                        AppColors.primaryBorder.opacity(0.3),
                        lineWidth: errorMessage != nil ? 2 : 1
                    )
            )
            
            if let error = errorMessage {
                Text(error)
                    .font(.caption1)
                    .foregroundColor(AppColors.error)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct ResultRow: View {
    let label: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.jostRegular(16))
                .foregroundColor(AppColors.secondaryText)
            
            Spacer()
            
            Text(value)
                .font(.jostMedium(16))
                .foregroundColor(valueColor)
        }
    }
}

#Preview {
    CalculatorView(viewModel: CalculatorViewModel()) {
        print("Save calculation")
    }
}

