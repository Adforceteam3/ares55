import Foundation

struct CalculationModel: Codable, Identifiable {
    let id = UUID()
    var originalPrice: Double = 0.0
    var mainDiscount: Double = 0.0
    var additionalDiscount: Double = 0.0
    var fixedDiscount: Double = 0.0
    var fixedFee: Double = 0.0
    var tax: Double = 0.0
    
    var mainDiscountAmount: Double {
        return (originalPrice * mainDiscount / 100.0).rounded(toPlaces: 2)
    }
    
    var priceAfterMainDiscount: Double {
        return max(0, originalPrice - mainDiscountAmount)
    }
    
    var additionalDiscountAmount: Double {
        return (priceAfterMainDiscount * additionalDiscount / 100.0).rounded(toPlaces: 2)
    }
    
    var priceAfterAdditionalDiscount: Double {
        return max(0, priceAfterMainDiscount - additionalDiscountAmount)
    }
    
    var priceAfterFixedDiscount: Double {
        return max(0, priceAfterAdditionalDiscount - fixedDiscount)
    }
    
    var priceAfterFixedFee: Double {
        return priceAfterFixedDiscount + fixedFee
    }
    
    var taxAmount: Double {
        return (priceAfterFixedFee * tax / 100.0).rounded(toPlaces: 2)
    }
    
    var finalPrice: Double {
        return priceAfterFixedFee + taxAmount
    }
    
    var totalDiscountAmount: Double {
        return mainDiscountAmount + additionalDiscountAmount + fixedDiscount
    }
    
    var totalDiscountPercentage: Double {
        guard originalPrice > 0 else { return 0 }
        return ((originalPrice - finalPrice + taxAmount) / originalPrice * 100.0).rounded(toPlaces: 2)
    }
    
    var isValid: Bool {
        return originalPrice > 0 && 
               mainDiscount >= 0 && mainDiscount <= 100 &&
               additionalDiscount >= 0 && additionalDiscount <= 100 &&
               tax >= 0 && tax <= 100 &&
               fixedDiscount >= 0 &&
               fixedFee >= 0
    }
    
    var hasAdvancedParameters: Bool {
        return additionalDiscount > 0 || fixedDiscount > 0 || fixedFee > 0
    }
}

struct ComparisonModel: Codable {
    var variantA: CalculationModel
    var variantB: CalculationModel
    
    var betterOption: ComparisonResult {
        if variantA.finalPrice < variantB.finalPrice {
            return .variantA
        } else if variantB.finalPrice < variantA.finalPrice {
            return .variantB
        } else {
            return .equal
        }
    }
    
    var priceDifference: Double {
        return abs(variantA.finalPrice - variantB.finalPrice)
    }
    
    var isValid: Bool {
        return variantA.isValid && variantB.isValid
    }
}

enum ComparisonResult: Codable {
    case variantA
    case variantB
    case equal
    
    var description: String {
        switch self {
        case .variantA:
            return "Better: Variant A"
        case .variantB:
            return "Better: Variant B"
        case .equal:
            return "Equal"
        }
    }
}

extension Double {
    var currencyFormatted: String {
        return String(format: "$%.2f", self)
    }
}
