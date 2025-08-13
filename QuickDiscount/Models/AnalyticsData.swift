import Foundation

struct AnalyticsData {
    let entries: [HistoryEntry]
    let period: AnalyticsPeriod
    let aggregationType: CandlestickAggregation
    
    var averageFinalPrice: Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.calculation.finalPrice }
        return (total / Double(entries.count)).rounded(toPlaces: 2)
    }
    
    var averageDiscountPercentage: Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.calculation.totalDiscountPercentage }
        return (total / Double(entries.count)).rounded(toPlaces: 2)
    }
    
    var averageTaxPercentage: Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.calculation.tax }
        return (total / Double(entries.count)).rounded(toPlaces: 2)
    }
    
    var maxDiscountPercentage: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { $0.calculation.totalDiscountPercentage }.max() ?? 0
    }
    
    var maxDiscountAmount: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.map { $0.calculation.totalDiscountAmount }.max() ?? 0
    }
    
    var topDiscountEntries: [HistoryEntry] {
        return entries
            .sorted { $0.calculation.totalDiscountPercentage > $1.calculation.totalDiscountPercentage }
            .prefix(5)
            .map { $0 }
    }
    
    var candlestickData: [CandlestickData] {
        let groupedEntries = groupEntriesByPeriod()
        return groupedEntries.compactMap { (date, entries) in
            guard !entries.isEmpty else { return nil }
            
            let sortedEntries = entries.sorted { $0.date < $1.date }
            let prices = sortedEntries.map { $0.calculation.finalPrice }
            
            let open = prices.first ?? 0
            let close = prices.last ?? 0
            let high = prices.max() ?? 0
            let low = prices.min() ?? 0
            
            return CandlestickData(
                date: date,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: entries.count,
                entries: sortedEntries
            )
        }.sorted { $0.date < $1.date }
    }
    
    private func groupEntriesByPeriod() -> [(Date, [HistoryEntry])] {
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: entries) { entry in
            switch aggregationType {
            case .daily:
                return calendar.startOfDay(for: entry.date)
            case .weekly:
                let weekOfYear = calendar.component(.weekOfYear, from: entry.date)
                let year = calendar.component(.year, from: entry.date)
                return calendar.date(from: DateComponents(year: year, weekOfYear: weekOfYear)) ?? entry.date
            }
        }
        
        return grouped.map { ($0.key, $0.value) }
    }
}

struct CandlestickData: Identifiable {
    let id = UUID()
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
    let entries: [HistoryEntry]
    
    var color: CandlestickColor {
        if close > open {
            return .green
        } else if close < open {
            return .red
        } else {
            return .neutral
        }
    }
    
    var priceRange: String {
        return "\(low.currencyFormatted) - \(high.currencyFormatted)"
    }
    
    var exampleEntry: HistoryEntry? {
        return entries.first
    }
}

enum CandlestickColor {
    case green
    case red
    case neutral
}

enum AnalyticsPeriod: String, CaseIterable {
    case week7 = "7_days"
    case days30 = "30_days"
    case days90 = "90_days"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .week7:
            return "7 Days"
        case .days30:
            return "30 Days"
        case .days90:
            return "90 Days"
        case .custom:
            return "Custom"
        }
    }
    
    var daysCount: Int? {
        switch self {
        case .week7:
            return 7
        case .days30:
            return 30
        case .days90:
            return 90
        case .custom:
            return nil
        }
    }
    
    func dateRange(customStart: Date? = nil, customEnd: Date? = nil) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .custom:
            return (start: customStart ?? now, end: customEnd ?? now)
        default:
            let start = calendar.date(byAdding: .day, value: -(daysCount ?? 0), to: now) ?? now
            return (start: start, end: now)
        }
    }
}

enum CandlestickAggregation: String, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    
    var displayName: String {
        switch self {
        case .daily:
            return "Day"
        case .weekly:
            return "Week"
        }
    }
}

