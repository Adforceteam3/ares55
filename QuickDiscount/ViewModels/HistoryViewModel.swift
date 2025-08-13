import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var entries: [HistoryEntry] = []
    @Published var filteredEntries: [HistoryEntry] = []
    @Published var filter = HistoryFilter()
    @Published var selectedEntry: HistoryEntry?
    @Published var showingFilters = false
    
    @Published var startDateText = ""
    @Published var endDateText = ""
    @Published var minPriceText = ""
    @Published var maxPriceText = ""
    @Published var minDiscountText = ""
    @Published var maxDiscountText = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsKey = "HistoryEntries"
    
    init() {
        loadEntries()
        setupFilterBindings()
        applyFilter()
    }
    
    private func setupFilterBindings() {
        Publishers.CombineLatest3(
            $filter,
            $entries,
            $showingFilters
        )
        .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
        .sink { [weak self] _, _, _ in
            self?.applyFilter()
        }
        .store(in: &cancellables)
    }
    
    func addEntry(_ entry: HistoryEntry) {
        entries.insert(entry, at: 0)
        saveEntries()
        applyFilter()
    }
    
    func addCalculation(_ calculation: CalculationModel) {
        let entry = HistoryEntry(calculation: calculation, entryType: .regular)
        addEntry(entry)
    }
    
    func addComparison(_ comparison: ComparisonModel) {
        let entryA = HistoryEntry(
            calculation: comparison.variantA,
            entryType: .comparisonA,
            comparisonData: comparison
        )
        let entryB = HistoryEntry(
            calculation: comparison.variantB,
            entryType: .comparisonB,
            comparisonData: comparison
        )
        
        addEntry(entryA)
        addEntry(entryB)
    }
    
    func deleteEntry(_ entry: HistoryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
        applyFilter()
    }
    
    func deleteEntry(at indexSet: IndexSet) {
        for index in indexSet {
            if index < filteredEntries.count {
                let entry = filteredEntries[index]
                deleteEntry(entry)
            }
        }
    }
    
    private func applyFilter() {
        if filter.isActive {
            filteredEntries = entries.filter { filter.matches($0) }
        } else {
            filteredEntries = entries
        }
    }
    
    func resetFilters() {
        filter.reset()
        startDateText = ""
        endDateText = ""
        minPriceText = ""
        maxPriceText = ""
        minDiscountText = ""
        maxDiscountText = ""
        applyFilter()
    }
    
    func updateFilterFromUI() {
        applyFilter()
    }
    
    private func saveEntries() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: userDefaultsKey)
    }
    
    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let loadedEntries = try? JSONDecoder().decode([HistoryEntry].self, from: data) else {
            return
        }
        entries = loadedEntries
    }
    
    func getEntriesForPeriod(_ period: AnalyticsPeriod, customStart: Date? = nil, customEnd: Date? = nil) -> [HistoryEntry] {
        let dateRange = period.dateRange(customStart: customStart, customEnd: customEnd)
        return entries.filter { entry in
            entry.date >= dateRange.start && entry.date <= dateRange.end
        }
    }
    
    var isEmpty: Bool {
        return entries.isEmpty
    }
    
    var filteredIsEmpty: Bool {
        return filteredEntries.isEmpty
    }
    
    var totalSavings: Double {
        return entries.reduce(0) { total, entry in
            total + entry.calculation.totalDiscountAmount
        }
    }
    
    var averageFinalPrice: Double {
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.calculation.finalPrice }
        return total / Double(entries.count)
    }
}

