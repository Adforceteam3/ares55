import SwiftUI

struct HistoryFiltersView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempStartDate = Date()
    @State private var tempEndDate = Date()
    @State private var tempMinPrice = ""
    @State private var tempMaxPrice = ""
    @State private var tempMinDiscount = ""
    @State private var tempMaxDiscount = ""
    @State private var useDateFilter = false
    @State private var usePriceFilter = false
    @State private var useDiscountFilter = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.secondaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        dateFilterSection
                        
                        priceFilterSection
                        
                        discountFilterSection
                        
                        if viewModel.filter.isActive {
                            activeFiltersSection
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Filter History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        resetAllFilters()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFilters()
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryBlue)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadCurrentFilters()
            }
        }
    }
    
    private var dateFilterSection: some View {
        FilterSection(
            title: "Date Range",
            isEnabled: $useDateFilter,
            icon: "calendar"
        ) {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("From Date")
                        .font(.jostMedium(14))
                        .foregroundColor(AppColors.secondaryText)
                    
                    DatePicker("Start Date", selection: $tempStartDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .disabled(!useDateFilter)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("To Date")
                        .font(.jostMedium(14))
                        .foregroundColor(AppColors.secondaryText)
                    
                    DatePicker("End Date", selection: $tempEndDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .disabled(!useDateFilter)
                }
            }
        }
    }
    
    private var priceFilterSection: some View {
        FilterSection(
            title: "Final Price Range",
            isEnabled: $usePriceFilter,
            icon: "dollarsign.circle"
        ) {
            HStack(spacing: 12) {
                FilterInputField(
                    title: "Min Price",
                    value: $tempMinPrice,
                    placeholder: "0.00",
                    prefix: "$",
                    isEnabled: usePriceFilter
                )
                
                Text("to")
                    .font(.jostRegular(14))
                    .foregroundColor(AppColors.mutedText)
                
                FilterInputField(
                    title: "Max Price",
                    value: $tempMaxPrice,
                    placeholder: "999.99",
                    prefix: "$",
                    isEnabled: usePriceFilter
                )
            }
        }
    }
    
    private var discountFilterSection: some View {
        FilterSection(
            title: "Discount Range",
            isEnabled: $useDiscountFilter,
            icon: "percent"
        ) {
            HStack(spacing: 12) {
                FilterInputField(
                    title: "Min Discount",
                    value: $tempMinDiscount,
                    placeholder: "0",
                    suffix: "%",
                    isEnabled: useDiscountFilter
                )
                
                Text("to")
                    .font(.jostRegular(14))
                    .foregroundColor(AppColors.mutedText)
                
                FilterInputField(
                    title: "Max Discount",
                    value: $tempMaxDiscount,
                    placeholder: "100",
                    suffix: "%",
                    isEnabled: useDiscountFilter
                )
            }
        }
    }
    
    private var activeFiltersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Filters")
                .font(.jostSemiBold(16))
                .foregroundColor(AppColors.secondaryText)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))], spacing: 8) {
                if let startDate = viewModel.filter.startDate, let endDate = viewModel.filter.endDate {
                    FilterChip(
                        text: "Date: \(formatDate(startDate)) - \(formatDate(endDate))",
                        onRemove: {
                            viewModel.filter.startDate = nil
                            viewModel.filter.endDate = nil
                            useDateFilter = false
                        }
                    )
                }
                
                if let minPrice = viewModel.filter.minFinalPrice {
                    FilterChip(
                        text: "Min Price: \(minPrice.currencyFormatted)",
                        onRemove: {
                            viewModel.filter.minFinalPrice = nil
                            if viewModel.filter.maxFinalPrice == nil {
                                usePriceFilter = false
                            }
                        }
                    )
                }
                
                if let maxPrice = viewModel.filter.maxFinalPrice {
                    FilterChip(
                        text: "Max Price: \(maxPrice.currencyFormatted)",
                        onRemove: {
                            viewModel.filter.maxFinalPrice = nil
                            if viewModel.filter.minFinalPrice == nil {
                                usePriceFilter = false
                            }
                        }
                    )
                }
                
                if let minDiscount = viewModel.filter.minDiscountPercentage {
                    FilterChip(
                        text: "Min Discount: \(minDiscount.asPercentage())",
                        onRemove: {
                            viewModel.filter.minDiscountPercentage = nil
                            if viewModel.filter.maxDiscountPercentage == nil {
                                useDiscountFilter = false
                            }
                        }
                    )
                }
                
                if let maxDiscount = viewModel.filter.maxDiscountPercentage {
                    FilterChip(
                        text: "Max Discount: \(maxDiscount.asPercentage())",
                        onRemove: {
                            viewModel.filter.maxDiscountPercentage = nil
                            if viewModel.filter.minDiscountPercentage == nil {
                                useDiscountFilter = false
                            }
                        }
                    )
                }
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
    
    private func loadCurrentFilters() {
        let filter = viewModel.filter
        
        if let startDate = filter.startDate {
            tempStartDate = startDate
            useDateFilter = true
        }
        if let endDate = filter.endDate {
            tempEndDate = endDate
            useDateFilter = true
        }
        
        if let minPrice = filter.minFinalPrice {
            tempMinPrice = String(minPrice)
            usePriceFilter = true
        }
        if let maxPrice = filter.maxFinalPrice {
            tempMaxPrice = String(maxPrice)
            usePriceFilter = true
        }
        
        if let minDiscount = filter.minDiscountPercentage {
            tempMinDiscount = String(minDiscount)
            useDiscountFilter = true
        }
        if let maxDiscount = filter.maxDiscountPercentage {
            tempMaxDiscount = String(maxDiscount)
            useDiscountFilter = true
        }
    }
    
    private func applyFilters() {
        if useDateFilter {
            viewModel.filter.startDate = tempStartDate
            viewModel.filter.endDate = tempEndDate
        } else {
            viewModel.filter.startDate = nil
            viewModel.filter.endDate = nil
        }
        
        if usePriceFilter {
            viewModel.filter.minFinalPrice = tempMinPrice.isEmpty ? nil : Double(tempMinPrice)
            viewModel.filter.maxFinalPrice = tempMaxPrice.isEmpty ? nil : Double(tempMaxPrice)
        } else {
            viewModel.filter.minFinalPrice = nil
            viewModel.filter.maxFinalPrice = nil
        }
        
        if useDiscountFilter {
            viewModel.filter.minDiscountPercentage = tempMinDiscount.isEmpty ? nil : Double(tempMinDiscount)
            viewModel.filter.maxDiscountPercentage = tempMaxDiscount.isEmpty ? nil : Double(tempMaxDiscount)
        } else {
            viewModel.filter.minDiscountPercentage = nil
            viewModel.filter.maxDiscountPercentage = nil
        }
        
        viewModel.updateFilterFromUI()
    }
    
    private func resetAllFilters() {
        useDateFilter = false
        usePriceFilter = false
        useDiscountFilter = false
        
        tempStartDate = Date()
        tempEndDate = Date()
        tempMinPrice = ""
        tempMaxPrice = ""
        tempMinDiscount = ""
        tempMaxDiscount = ""
        
        viewModel.resetFilters()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    @Binding var isEnabled: Bool
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isEnabled ? AppColors.primaryBlue : AppColors.mutedText)
                    
                    Text(title)
                        .font(.jostSemiBold(16))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .tint(AppColors.primaryBlue)
            }
            
            if isEnabled {
                content
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: AppColors.primaryBlue.opacity(0.05), radius: 4, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.3), value: isEnabled)
    }
}

struct FilterInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    var prefix: String = ""
    var suffix: String = ""
    let isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.jostMedium(12))
                .foregroundColor(isEnabled ? AppColors.secondaryText : AppColors.mutedText)
            
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
                    .disabled(!isEnabled)
                    .onChange(of: value) { newValue in
                        if prefix.contains("$") {
                            value = InputValidator.formatCurrencyInput(newValue)
                        } else if suffix.contains("%") {
                            value = InputValidator.formatPercentageInput(newValue)
                        }
                    }
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.jostMedium(14))
                        .foregroundColor(AppColors.mutedText)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isEnabled ? AppColors.white : AppColors.lightGray)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.primaryBorder.opacity(0.3), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
    }
}

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.jostRegular(12))
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(1)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.mutedText)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.primaryBorder.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    HistoryFiltersView(viewModel: HistoryViewModel())
}
