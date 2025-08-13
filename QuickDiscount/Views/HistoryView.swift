import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @State private var showingFilters = false
    @State private var showingEntryDetail = false
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                if viewModel.isEmpty {
                    emptyStateView
                } else if viewModel.filteredIsEmpty {
                    filteredEmptyStateView
                } else {
                    historyListView
                }
                
                Spacer(minLength: 100)
            }
        }
        .sheet(isPresented: $showingFilters) {
            HistoryFiltersView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEntryDetail) {
            if let entry = viewModel.selectedEntry {
                HistoryDetailView(entry: entry) {
                    viewModel.deleteEntry(entry)
                    viewModel.selectedEntry = nil
                    showingEntryDetail = false
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calculation History")
                        .font(.jostBold(24))
                        .foregroundColor(AppColors.white)
                    
                    Text("Saved Results")
                        .font(.jostLight(16))
                        .foregroundColor(AppColors.white.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {
                    showingFilters = true
                }) {
                    ZStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(AppColors.white)
                        
                        if viewModel.filter.isActive {
                            Circle()
                                .fill(AppColors.error)
                                .frame(width: 8, height: 8)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
            
            if !viewModel.isEmpty {
                VStack(spacing: 12) {
                    quickStatsSection
                    
                    if viewModel.filter.isActive {
                        HStack {
                            Text("Showing \(viewModel.filteredEntries.count) of \(viewModel.entries.count) calculations")
                                .font(.jostRegular(14))
                                .foregroundColor(AppColors.white.opacity(0.8))
                            
                            Spacer()
                            
                            Button("Clear Filters") {
                                viewModel.resetFilters()
                            }
                            .font(.jostMedium(12))
                            .foregroundColor(AppColors.lightBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.white.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(AppColors.white.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var quickStatsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Savings",
                value: viewModel.totalSavings.currencyFormatted,
                icon: "minus.circle.fill",
                color: AppColors.success
            )
            
            StatCard(
                title: "Avg. Final Price",
                value: viewModel.averageFinalPrice.currencyFormatted,
                icon: "chart.line.uptrend.xyaxis",
                color: AppColors.info
            )
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(AppColors.white.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Calculations Yet")
                    .font(.jostSemiBold(22))
                    .foregroundColor(AppColors.white)
                
                Text("Start using the calculator to see your saved calculations here")
                    .font(.jostRegular(16))
                    .foregroundColor(AppColors.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var filteredEmptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(AppColors.white.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(.jostSemiBold(20))
                    .foregroundColor(AppColors.white)
                
                Text("Try adjusting your filters")
                    .font(.jostRegular(16))
                    .foregroundColor(AppColors.white.opacity(0.8))
            }
            
            Button("Clear Filters") {
                viewModel.resetFilters()
            }
            .font(.jostMedium(16))
            .foregroundColor(AppColors.primaryBlue)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(AppColors.white)
            .cornerRadius(20)
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredEntries) { entry in
                    HistoryRowView(entry: entry) {
                        viewModel.selectedEntry = entry
                        showingEntryDetail = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.jostBold(18))
                    .foregroundColor(AppColors.white)
                
                Text(title)
                    .font(.jostRegular(12))
                    .foregroundColor(AppColors.white.opacity(0.8))
            }
        }
        .padding(12)
        .background(AppColors.white.opacity(0.1))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct HistoryRowView: View {
    let entry: HistoryEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack {
                    Image(systemName: entry.entryType == .regular ? "plus.forwardslash.minus" : "scale.3d")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryBlue)
                        .frame(width: 32, height: 32)
                        .background(AppColors.lightBlue.opacity(0.2))
                        .cornerRadius(8)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(entry.displayTitle)
                            .font(.jostMedium(14))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Spacer()
                        
                        Text(entry.date, style: .date)
                            .font(.jostRegular(12))
                            .foregroundColor(AppColors.mutedText)
                    }
                    
                    HStack {
                        Text(entry.calculation.originalPrice.currencyFormatted)
                            .font(.jostSemiBold(16))
                            .foregroundColor(AppColors.secondaryText)
                        
                        if entry.calculation.totalDiscountPercentage > 0 {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.mutedText)
                            
                            Text("-\(entry.calculation.totalDiscountPercentage.asPercentage())")
                                .font(.jostMedium(14))
                                .foregroundColor(AppColors.error)
                        }
                        
                        if entry.calculation.tax > 0 {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppColors.mutedText)
                            
                            Text("\(entry.calculation.tax.asPercentage()) tax")
                                .font(.jostRegular(12))
                                .foregroundColor(AppColors.mutedText)
                        }
                        
                        Spacer()
                        
                        Text(entry.calculation.finalPrice.currencyFormatted)
                            .font(.jostBold(16))
                            .foregroundColor(AppColors.primaryBlue)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.mutedText)
            }
            .padding(16)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: AppColors.primaryBlue.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HistoryDetailView: View {
    let entry: HistoryEntry
    let onDelete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        summaryCard
                        
                        breakdownCard
                        
                        if let comparison = entry.comparisonData {
                            comparisonCard(comparison)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Calculation Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppColors.error)
                    }
                }
            }
        }
        .confirmationDialog("Delete Calculation", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This calculation will be permanently deleted.")
        }
    }
    
    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text(entry.displayTitle)
                    .font(.jostSemiBold(18))
                    .foregroundColor(AppColors.secondaryText)
                
                Spacer()
                
                Text(entry.date, style: .date)
                    .font(.jostRegular(14))
                    .foregroundColor(AppColors.mutedText)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Original Price")
                        .font(.jostRegular(14))
                        .foregroundColor(AppColors.mutedText)
                    Text(entry.calculation.originalPrice.currencyFormatted)
                        .font(.jostSemiBold(20))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Final Price")
                        .font(.jostRegular(14))
                        .foregroundColor(AppColors.mutedText)
                    Text(entry.calculation.finalPrice.currencyFormatted)
                        .font(.jostBold(24))
                        .foregroundColor(AppColors.primaryBlue)
                }
            }
        }
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calculation Breakdown")
                .font(.jostSemiBold(18))
                .foregroundColor(AppColors.secondaryText)
            
            Text(entry.calculationBreakdown)
                .font(.jostRegular(15))
                .foregroundColor(AppColors.secondaryText)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    private func comparisonCard(_ comparison: ComparisonModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comparison Results")
                .font(.jostSemiBold(18))
                .foregroundColor(AppColors.secondaryText)
            
            HStack {
                Text(comparison.betterOption.description)
                    .font(.jostMedium(16))
                    .foregroundColor(AppColors.primaryBlue)
                
                Spacer()
                
                Text("Difference: \(comparison.priceDifference.currencyFormatted)")
                    .font(.jostRegular(14))
                    .foregroundColor(AppColors.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppColors.info.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.info.opacity(0.3), lineWidth: 1)
        )
    }
}


#Preview {
    HistoryView(viewModel: HistoryViewModel())
}

