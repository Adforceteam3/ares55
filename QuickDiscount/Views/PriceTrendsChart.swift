import SwiftUI

struct PriceTrendsChart: View {
    let data: AnalyticsData
    let onCandlestickTap: (CandlestickData) -> Void
    
    @State private var animatedValues: [Double] = []
    @State private var showAnimation = false
    
    var body: some View {
        GeometryReader { geometry in
            if data.candlestickData.isEmpty {
                emptyChartView
            } else {
                VStack(spacing: 12) {
                    chartView(geometry: geometry)
                    
                    chartLegend
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 30, weight: .light))
                .foregroundColor(AppColors.white.opacity(0.4))
            
            Text("No data points yet")
                .font(.jostRegular(14))
                .foregroundColor(AppColors.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func chartView(geometry: GeometryProxy) -> some View {
        let chartData = data.candlestickData
        let chartWidth = geometry.size.width - 40
        let chartHeight = geometry.size.height - 60
        let candlestickWidth = max(8, min(chartWidth / CGFloat(chartData.count) - 4, 20))
        
        let priceRange = calculatePriceRange(chartData)
        let priceSpan = priceRange.max - priceRange.min
        
        return VStack(spacing: 8) {
            HStack {
                VStack {
                    Text(priceRange.max.currencyFormatted)
                        .font(.jostRegular(10))
                        .foregroundColor(AppColors.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(((priceRange.max + priceRange.min) / 2).currencyFormatted)
                        .font(.jostRegular(10))
                        .foregroundColor(AppColors.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text(priceRange.min.currencyFormatted)
                        .font(.jostRegular(10))
                        .foregroundColor(AppColors.white.opacity(0.7))
                }
                .frame(width: 60)
                
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(AppColors.white.opacity(0.1))
                                .frame(height: 0.5)
                            Spacer()
                        }
                        Rectangle()
                            .fill(AppColors.white.opacity(0.1))
                            .frame(height: 0.5)
                    }
                    
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(Array(chartData.enumerated()), id: \.element.id) { index, candlestick in
                            CandlestickView(
                                candlestick: candlestick,
                                maxHeight: chartHeight,
                                priceRange: priceRange,
                                width: candlestickWidth,
                                animationProgress: showAnimation ? (animatedValues.count > index ? animatedValues[index] : 0) : 0,
                                onTap: {
                                    onCandlestickTap(candlestick)
                                }
                            )
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(height: chartHeight)
            }
            
            HStack {
                Spacer()
                    .frame(width: 60)
                
                HStack(spacing: 2) {
                    ForEach(Array(chartData.enumerated()), id: \.element.id) { index, candlestick in
                        Text(formatDate(candlestick.date))
                            .font(.jostRegular(9))
                            .foregroundColor(AppColors.white.opacity(0.6))
                            .frame(width: candlestickWidth + 2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var chartLegend: some View {
        HStack(spacing: 16) {
            LegendItem(color: AppColors.chartGreen, label: "Higher")
            LegendItem(color: AppColors.chartRed, label: "Lower")
            LegendItem(color: AppColors.chartNeutral, label: "Same")
            
            Spacer()
            
            Text("\(data.candlestickData.count) data points")
                .font(.jostRegular(11))
                .foregroundColor(AppColors.white.opacity(0.7))
        }
    }
    
    private func calculatePriceRange(_ candlesticks: [CandlestickData]) -> (min: Double, max: Double) {
        guard !candlesticks.isEmpty else { return (0, 100) }
        
        let allPrices = candlesticks.flatMap { [$0.low, $0.high] }
        let minPrice = allPrices.min() ?? 0
        let maxPrice = allPrices.max() ?? 100
        
        let padding = max((maxPrice - minPrice) * 0.1, 10)
        return (min: max(0, minPrice - padding), max: maxPrice + padding)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = data.aggregationType == .daily ? "M/d" : "M/d"
        return formatter.string(from: date)
    }
    
    private func startAnimation() {
        animatedValues = Array(repeating: 0, count: data.candlestickData.count)
        showAnimation = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: 1.5)) {
                showAnimation = true
                animatedValues = Array(repeating: 1.0, count: data.candlestickData.count)
            }
        }
    }
}

struct CandlestickView: View {
    let candlestick: CandlestickData
    let maxHeight: CGFloat
    let priceRange: (min: Double, max: Double)
    let width: CGFloat
    let animationProgress: Double
    let onTap: () -> Void
    
    private var normalizedHigh: CGFloat {
        let normalized = (candlestick.high - priceRange.min) / (priceRange.max - priceRange.min)
        return CGFloat(normalized) * maxHeight * animationProgress
    }
    
    private var normalizedLow: CGFloat {
        let normalized = (candlestick.low - priceRange.min) / (priceRange.max - priceRange.min)
        return CGFloat(normalized) * maxHeight * animationProgress
    }
    
    private var normalizedOpen: CGFloat {
        let normalized = (candlestick.open - priceRange.min) / (priceRange.max - priceRange.min)
        return CGFloat(normalized) * maxHeight * animationProgress
    }
    
    private var normalizedClose: CGFloat {
        let normalized = (candlestick.close - priceRange.min) / (priceRange.max - priceRange.min)
        return CGFloat(normalized) * maxHeight * animationProgress
    }
    
    private var candlestickColor: Color {
        switch candlestick.color {
        case .green:
            return AppColors.chartGreen
        case .red:
            return AppColors.chartRed
        case .neutral:
            return AppColors.chartNeutral
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(candlestickColor)
                    .frame(width: 1, height: normalizedHigh - normalizedLow)
                    .offset(y: -(normalizedLow))
                
                let bodyHeight = abs(normalizedClose - normalizedOpen)
                let bodyOffset = min(normalizedOpen, normalizedClose)
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(candlestickColor)
                    .frame(width: width * 0.8, height: max(bodyHeight, 2))
                    .offset(y: -bodyOffset)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.jostRegular(11))
                .foregroundColor(AppColors.white.opacity(0.8))
        }
    }
}

struct CandlestickDetailView: View {
    let candlestick: CandlestickData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(candlestick.date, style: .date)
                                .font(.jostBold(24))
                                .foregroundColor(AppColors.white)
                            
                            Text("\(candlestick.volume) calculations")
                                .font(.jostRegular(16))
                                .foregroundColor(AppColors.white.opacity(0.8))
                        }
                        
                        VStack(spacing: 16) {
                            PriceDetailRow(label: "High", value: candlestick.high, color: AppColors.success)
                            PriceDetailRow(label: "Low", value: candlestick.low, color: AppColors.error)
                            PriceDetailRow(label: "Open", value: candlestick.open, color: AppColors.info)
                            PriceDetailRow(label: "Close", value: candlestick.close, color: AppColors.warning)
                        }
                        .padding(20)
                        .background(AppColors.cardBackground)
                        .cornerRadius(16)
                        
                        if let example = candlestick.exampleEntry {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Example Calculation")
                                    .font(.jostSemiBold(18))
                                    .foregroundColor(AppColors.white)
                                
                                Text(example.calculationBreakdown)
                                    .font(.jostRegular(15))
                                    .foregroundColor(AppColors.white.opacity(0.9))
                                    .lineSpacing(2)
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
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Price Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.white)
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct PriceDetailRow: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text(label)
                    .font(.jostMedium(16))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Text(value.currencyFormatted)
                .font(.jostBold(16))
                .foregroundColor(AppColors.secondaryText)
        }
    }
}

#Preview {
    let mockEntries = [
        HistoryEntry(calculation: CalculationModel(), entryType: .regular),
        HistoryEntry(calculation: CalculationModel(), entryType: .regular)
    ]
    let mockData = AnalyticsData(entries: mockEntries, period: .days30, aggregationType: .daily)
    
    return PriceTrendsChart(data: mockData) { _ in }
        .frame(height: 200)
        .background(LinearGradient.primaryBackground)
}
