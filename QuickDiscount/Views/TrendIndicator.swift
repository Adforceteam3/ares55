import SwiftUI

struct TrendIndicator: View {
    let currentValue: Double
    let previousValue: Double
    let formatter: TrendFormatter
    
    private var trend: TrendDirection {
        if currentValue > previousValue {
            return .up
        } else if currentValue < previousValue {
            return .down
        } else {
            return .neutral
        }
    }
    
    private var changeAmount: Double {
        return abs(currentValue - previousValue)
    }
    
    private var changePercentage: Double {
        guard previousValue > 0 else { return 0 }
        return (changeAmount / previousValue) * 100
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Text(formatter.format(currentValue))
                .font(.jostBold(16))
                .foregroundColor(AppColors.secondaryText)
            
            HStack(spacing: 4) {
                Image(systemName: trend.iconName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(trend.color)
                
                Text(formatter.formatChange(changeAmount, percentage: changePercentage))
                    .font(.jostMedium(12))
                    .foregroundColor(trend.color)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(trend.color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

enum TrendDirection {
    case up
    case down
    case neutral
    
    var iconName: String {
        switch self {
        case .up:
            return "arrow.up"
        case .down:
            return "arrow.down"
        case .neutral:
            return "minus"
        }
    }
    
    var color: Color {
        switch self {
        case .up:
            return AppColors.success
        case .down:
            return AppColors.error
        case .neutral:
            return AppColors.mutedText
        }
    }
}

enum TrendFormatter {
    case currency
    case percentage
    case decimal
    
    func format(_ value: Double) -> String {
        switch self {
        case .currency:
            return value.currencyFormatted
        case .percentage:
            return value.asPercentage()
        case .decimal:
            return String(format: "%.1f", value)
        }
    }
    
    func formatChange(_ amount: Double, percentage: Double) -> String {
        switch self {
        case .currency:
            return "\(amount.currencyFormatted) (\(percentage.rounded(toPlaces: 1))%)"
        case .percentage:
            return "\(amount.rounded(toPlaces: 1))pp"
        case .decimal:
            return "\(amount.rounded(toPlaces: 1)) (\(percentage.rounded(toPlaces: 1))%)"
        }
    }
}

struct EnhancedAnalyticsCard: View {
    let title: String
    let currentValue: Double
    let previousValue: Double
    let icon: String
    let color: Color
    let formatter: TrendFormatter
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(color.opacity(0.3))
                            .frame(width: 3, height: 3)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                TrendIndicator(
                    currentValue: currentValue,
                    previousValue: previousValue,
                    formatter: formatter
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(title)
                    .font(.jostRegular(12))
                    .foregroundColor(AppColors.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(AppColors.white.opacity(0.05))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}

struct PriceMovementIndicator: View {
    let prices: [Double]
    let height: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            if prices.count >= 2 {
                let maxPrice = prices.max() ?? 0
                let minPrice = prices.min() ?? 0
                let priceRange = maxPrice - minPrice
                let stepWidth = geometry.size.width / CGFloat(prices.count - 1)
                
                Path { path in
                    for (index, price) in prices.enumerated() {
                        let x = CGFloat(index) * stepWidth
                        let normalizedPrice = priceRange > 0 ? (price - minPrice) / priceRange : 0.5
                        let y = height - (CGFloat(normalizedPrice) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [AppColors.lightBlue, AppColors.primaryBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
                
                ForEach(Array(prices.enumerated()), id: \.offset) { index, price in
                    let x = CGFloat(index) * stepWidth
                    let normalizedPrice = priceRange > 0 ? (price - minPrice) / priceRange : 0.5
                    let y = height - (CGFloat(normalizedPrice) * height)
                    
                    Circle()
                        .fill(AppColors.lightBlue)
                        .frame(width: 4, height: 4)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(height: height)
    }
}

struct AnalyticsSummaryCard: View {
    let totalCalculations: Int
    let totalSavings: Double
    let averageDiscount: Double
    let bestDiscount: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Summary")
                    .font(.jostSemiBold(18))
                    .foregroundColor(AppColors.white)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                SummaryItem(
                    value: "\(totalCalculations)",
                    label: "Calculations",
                    icon: "number",
                    color: AppColors.info
                )
                
                SummaryItem(
                    value: totalSavings.currencyFormatted,
                    label: "Total Saved",
                    icon: "dollarsign.circle.fill",
                    color: AppColors.success
                )
                
                SummaryItem(
                    value: averageDiscount.asPercentage(),
                    label: "Avg Discount",
                    icon: "percent",
                    color: AppColors.warning
                )
                
                SummaryItem(
                    value: bestDiscount.asPercentage(),
                    label: "Best Discount",
                    icon: "star.fill",
                    color: AppColors.error
                )
            }
        }
        .padding(20)
        .background(AppColors.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct SummaryItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.jostBold(16))
                .foregroundColor(AppColors.white)
            
            Text(label)
                .font(.jostRegular(10))
                .foregroundColor(AppColors.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview("Trend Indicator") {
    VStack(spacing: 20) {
        TrendIndicator(
            currentValue: 125.50,
            previousValue: 98.20,
            formatter: .currency
        )
        
        TrendIndicator(
            currentValue: 15.5,
            previousValue: 22.1,
            formatter: .percentage
        )
        
        EnhancedAnalyticsCard(
            title: "Average Price",
            currentValue: 125.50,
            previousValue: 98.20,
            icon: "dollarsign.circle.fill",
            color: AppColors.info,
            formatter: .currency
        )
    }
    .padding()
    .background(LinearGradient.primaryBackground)
}
