import SwiftUI

struct AnalyticsView: View {
    @ObservedObject var viewModel: AnalyticsViewModel
    
    var body: some View {
        ZStack {
            LinearGradient.primaryBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if viewModel.hasData {
                        periodSelector
                        
                        statsCardsSection
                        
                        chartSection
                        
                        topDiscountsSection
                    } else {
                        emptyStateView
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .onAppear {
            viewModel.updateAnalytics()
        }
        .refreshable {
            viewModel.updateAnalytics()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Analytics")
                .font(.jostBold(28))
                .foregroundColor(AppColors.white)
            
            Text("Price trends and savings insights")
                .font(.jostLight(16))
                .foregroundColor(AppColors.white.opacity(0.8))
        }
        .padding(.top, 10)
    }
    
    private var periodSelector: some View {
        HStack(spacing: 8) {
            ForEach(AnalyticsPeriod.allCases.filter { $0 != .custom }, id: \.rawValue) { period in
                Button(action: {
                    viewModel.selectedPeriod = period
                }) {
                    Text(period.displayName)
                        .font(.jostMedium(14))
                        .foregroundColor(viewModel.selectedPeriod == period ? AppColors.primaryBlue : AppColors.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedPeriod == period ? 
                            AppColors.white : AppColors.white.opacity(0.1)
                        )
                        .cornerRadius(16)
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    private var statsCardsSection: some View {
        VStack(spacing: 16) {
            if let data = viewModel.analyticsData {
                AnalyticsSummaryCard(
                    totalCalculations: data.entries.count,
                    totalSavings: data.entries.reduce(0) { $0 + $1.calculation.totalDiscountAmount },
                    averageDiscount: data.averageDiscountPercentage,
                    bestDiscount: data.maxDiscountPercentage
                )
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    AnalyticsCard(
                        title: "Avg Final Price",
                        value: viewModel.analyticsData?.averageFinalPrice.currencyFormatted ?? "$0.00",
                        icon: "dollarsign.circle.fill",
                        color: AppColors.info
                    )
                    
                    AnalyticsCard(
                        title: "Avg Discount",
                        value: viewModel.analyticsData?.averageDiscountPercentage.asPercentage() ?? "0%",
                        icon: "percent",
                        color: AppColors.success
                    )
                }
                
                HStack(spacing: 12) {
                    AnalyticsCard(
                        title: "Avg Tax",
                        value: viewModel.analyticsData?.averageTaxPercentage.asPercentage() ?? "0%",
                        icon: "plus.circle.fill",
                        color: AppColors.warning
                    )
                    
                    AnalyticsCard(
                        title: "Max Discount",
                        value: viewModel.analyticsData?.maxDiscountPercentage.asPercentage() ?? "0%",
                        icon: "arrow.down.circle.fill",
                        color: AppColors.error
                    )
                }
            }
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Price Trends")
                    .font(.jostSemiBold(18))
                    .foregroundColor(AppColors.white)
                
                Spacer()
                
                Picker("Aggregation", selection: $viewModel.aggregationType) {
                    Text("Daily").tag(CandlestickAggregation.daily)
                    Text("Weekly").tag(CandlestickAggregation.weekly)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 120)
            }
            
            if let data = viewModel.analyticsData, !data.entries.isEmpty {
                PriceTrendsChart(
                    data: data,
                    onCandlestickTap: { candlestick in
                        viewModel.selectCandlestick(candlestick)
                    }
                )
                .frame(height: 200)
                .padding(16)
                .background(AppColors.white.opacity(0.05))
                .cornerRadius(16)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(AppColors.white.opacity(0.6))
                    
                    Text("No data for chart")
                        .font(.jostRegular(16))
                        .foregroundColor(AppColors.white.opacity(0.7))
                    
                    Text("Save more calculations to see trends")
                        .font(.jostRegular(14))
                        .foregroundColor(AppColors.white.opacity(0.5))
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(AppColors.white.opacity(0.05))
                .cornerRadius(16)
            }
        }
        .sheet(isPresented: $viewModel.showingCandlestickDetail) {
            if let candlestick = viewModel.selectedCandlestick {
                CandlestickDetailView(candlestick: candlestick)
            }
        }
    }
    
    private var topDiscountsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Top Discounts")
                .font(.jostSemiBold(18))
                .foregroundColor(AppColors.white)
            
            VStack(spacing: 8) {
                ForEach(viewModel.analyticsData?.topDiscountEntries.prefix(3) ?? [], id: \.id) { entry in
                    TopDiscountRow(entry: entry)
                }
            }
            .padding(16)
            .background(AppColors.white.opacity(0.05))
            .cornerRadius(16)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "chart.bar")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(AppColors.white.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Data Available")
                    .font(.jostSemiBold(22))
                    .foregroundColor(AppColors.white)
                
                Text("Save some calculations to see analytics")
                    .font(.jostRegular(16))
                    .foregroundColor(AppColors.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

struct AnalyticsCard: View {
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.jostBold(20))
                    .foregroundColor(AppColors.white)
                
                Text(title)
                    .font(.jostRegular(12))
                    .foregroundColor(AppColors.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(AppColors.white.opacity(0.05))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}

struct TopDiscountRow: View {
    let entry: HistoryEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.date, style: .date)
                    .font(.jostMedium(14))
                    .foregroundColor(AppColors.white)
                
                Text(entry.calculation.originalPrice.currencyFormatted)
                    .font(.jostRegular(12))
                    .foregroundColor(AppColors.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.calculation.totalDiscountPercentage.asPercentage())")
                    .font(.jostBold(14))
                    .foregroundColor(AppColors.success)
                
                Text(entry.calculation.finalPrice.currencyFormatted)
                    .font(.jostRegular(12))
                    .foregroundColor(AppColors.white.opacity(0.7))
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AnalyticsView(viewModel: AnalyticsViewModel(historyViewModel: HistoryViewModel()))
}

