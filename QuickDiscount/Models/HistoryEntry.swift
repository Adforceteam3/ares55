import Foundation

struct HistoryEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let calculation: CalculationModel
    let entryType: HistoryEntryType
    let comparisonData: ComparisonModel?
    
    init(calculation: CalculationModel, entryType: HistoryEntryType = .regular, comparisonData: ComparisonModel? = nil) {
        self.date = Date()
        self.calculation = calculation
        self.entryType = entryType
        self.comparisonData = comparisonData
    }
    
    var displayTitle: String {
        switch entryType {
        case .regular:
            return "Regular Calculation"
        case .comparisonA:
            return "Comparison A"
        case .comparisonB:
            return "Comparison B"
        }
    }
    
    var calculationBreakdown: String {
        var breakdown = "Original price: \(calculation.originalPrice.currencyFormatted)"
        
        if calculation.mainDiscount > 0 {
            breakdown += " → \(calculation.mainDiscount)% discount"
        }
        
        if calculation.additionalDiscount > 0 {
            breakdown += " → additional \(calculation.additionalDiscount)% discount"
        }
        
        if calculation.fixedDiscount > 0 {
            breakdown += " → minus \(calculation.fixedDiscount.currencyFormatted) coupon"
        }
        
        if calculation.fixedFee > 0 {
            breakdown += " → plus \(calculation.fixedFee.currencyFormatted) fee"
        }
        
        if calculation.tax > 0 {
            breakdown += " → \(calculation.tax)% tax"
        }
        
        breakdown += " → final: \(calculation.finalPrice.currencyFormatted)"
        
        return breakdown
    }
}

enum HistoryEntryType: String, Codable, CaseIterable {
    case regular = "regular"
    case comparisonA = "comparison_a"
    case comparisonB = "comparison_b"
}

struct HistoryFilter {
    var startDate: Date?
    var endDate: Date?
    var minFinalPrice: Double?
    var maxFinalPrice: Double?
    var minDiscountPercentage: Double?
    var maxDiscountPercentage: Double?
    
    func matches(_ entry: HistoryEntry) -> Bool {
        if let startDate = startDate, entry.date < startDate {
            return false
        }
        
        if let endDate = endDate, entry.date > endDate {
            return false
        }
        
        if let minPrice = minFinalPrice, entry.calculation.finalPrice < minPrice {
            return false
        }
        
        if let maxPrice = maxFinalPrice, entry.calculation.finalPrice > maxPrice {
            return false
        }
        
        if let minDiscount = minDiscountPercentage, entry.calculation.totalDiscountPercentage < minDiscount {
            return false
        }
        
        if let maxDiscount = maxDiscountPercentage, entry.calculation.totalDiscountPercentage > maxDiscount {
            return false
        }
        
        return true
    }
    
    var isActive: Bool {
        return startDate != nil || endDate != nil || minFinalPrice != nil || 
               maxFinalPrice != nil || minDiscountPercentage != nil || maxDiscountPercentage != nil
    }
    
    mutating func reset() {
        startDate = nil
        endDate = nil
        minFinalPrice = nil
        maxFinalPrice = nil
        minDiscountPercentage = nil
        maxDiscountPercentage = nil
    }
}

