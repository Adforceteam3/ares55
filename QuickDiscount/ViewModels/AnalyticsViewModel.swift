import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var analyticsData: AnalyticsData?
    @Published var selectedPeriod: AnalyticsPeriod = .days30
    @Published var aggregationType: CandlestickAggregation = .daily
    @Published var customStartDate: Date = Date()
    @Published var customEndDate: Date = Date()
    @Published var minFinalPrice: Double?
    @Published var maxFinalPrice: Double?
    @Published var selectedCandlestick: CandlestickData?
    @Published var showingCandlestickDetail = false
    
    private let historyViewModel: HistoryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(historyViewModel: HistoryViewModel) {
        self.historyViewModel = historyViewModel
        setupBindings()
        updateAnalytics()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest4(
            $selectedPeriod,
            $aggregationType,
            $customStartDate,
            $customEndDate
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] _, _, _, _ in
            self?.updateAnalytics()
        }
        .store(in: &cancellables)
        
        historyViewModel.$entries
            .sink { [weak self] _ in
                self?.updateAnalytics()
            }
            .store(in: &cancellables)
        
        historyViewModel.$filteredEntries
            .sink { [weak self] _ in
                self?.updateAnalytics()
            }
            .store(in: &cancellables)
    }
    
    func updateAnalytics() {
        let entries: [HistoryEntry]
        
        if selectedPeriod == .custom {
            entries = historyViewModel.getEntriesForPeriod(
                selectedPeriod,
                customStart: customStartDate,
                customEnd: customEndDate
            )
        } else {
            entries = historyViewModel.getEntriesForPeriod(selectedPeriod)
        }
        
        let filteredEntries = entries.filter { entry in
            if let minPrice = minFinalPrice, entry.calculation.finalPrice < minPrice {
                return false
            }
            if let maxPrice = maxFinalPrice, entry.calculation.finalPrice > maxPrice {
                return false
            }
            return true
        }
        
        analyticsData = AnalyticsData(
            entries: filteredEntries,
            period: selectedPeriod,
            aggregationType: aggregationType
        )
    }
    
    func selectCandlestick(_ candlestick: CandlestickData) {
        selectedCandlestick = candlestick
        showingCandlestickDetail = true
    }
    
    func clearPriceFilters() {
        minFinalPrice = nil
        maxFinalPrice = nil
        updateAnalytics()
    }
    
    var hasData: Bool {
        return analyticsData?.entries.isEmpty == false
    }
    
    var periodDisplayText: String {
        guard let data = analyticsData else { return "No Data" }
        
        switch selectedPeriod {
        case .custom:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "\(formatter.string(from: customStartDate)) - \(formatter.string(from: customEndDate))"
        default:
            return "\(data.entries.count) calculations in \(selectedPeriod.displayName.lowercased())"
        }
    }
    
    var candlestickChartTitle: String {
        return "Price Trends (\(aggregationType.displayName))"
    }
    
    var totalCalculations: Int {
        return analyticsData?.entries.count ?? 0
    }
    
    var totalSavingsAmount: Double {
        guard let data = analyticsData else { return 0 }
        return data.entries.reduce(0) { total, entry in
            total + entry.calculation.totalDiscountAmount
        }
    }
    
    var averageOriginalPrice: Double {
        guard let data = analyticsData, !data.entries.isEmpty else { return 0 }
        let total = data.entries.reduce(0) { $0 + $1.calculation.originalPrice }
        return (total / Double(data.entries.count)).rounded(toPlaces: 2)
    }
    
    var priceRange: (min: Double, max: Double) {
        guard let data = analyticsData, !data.entries.isEmpty else { return (0, 0) }
        let prices = data.entries.map { $0.calculation.finalPrice }
        return (min: prices.min() ?? 0, max: prices.max() ?? 0)
    }
    
    var chartYAxisRange: (min: Double, max: Double) {
        guard let data = analyticsData, !data.candlestickData.isEmpty else { return (0, 100) }
        
        let allPrices = data.candlestickData.flatMap { [$0.low, $0.high] }
        let minPrice = allPrices.min() ?? 0
        let maxPrice = allPrices.max() ?? 100
        
        let padding = (maxPrice - minPrice) * 0.1 
        return (min: max(0, minPrice - padding), max: maxPrice + padding)
    }
    
    func resetToDefaults() {
        selectedPeriod = .days30
        aggregationType = .daily
        customStartDate = Date()
        customEndDate = Date()
        clearPriceFilters()
    }
}

