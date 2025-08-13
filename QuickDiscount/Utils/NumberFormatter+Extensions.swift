import Foundation

extension NumberFormatter {
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let percentage: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1
        return formatter
    }()
    
    static let decimal: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let percentageInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimum = 0
        formatter.maximum = 100
        return formatter
    }()
    
    static let currencyInput: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimum = 0
        return formatter
    }()
}

extension String {
    var isValidCurrency: Bool {
        guard !isEmpty else { return false }
        return Double(self) != nil && (Double(self) ?? -1) >= 0
    }
    
    var isValidPercentage: Bool {
        guard !isEmpty else { return false }
        guard let value = Double(self) else { return false }
        return value >= 0 && value <= 100
    }
    
    var currencyValue: Double {
        return Double(self) ?? 0.0
    }
    
    var percentageValue: Double {
        return Double(self) ?? 0.0
    }
    
    func formattedAsCurrency() -> String {
        guard let value = Double(self) else { return "$0.00" }
        return NumberFormatter.currency.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    func formattedAsPercentage() -> String {
        guard let value = Double(self) else { return "0%" }
        return "\(value)%"
    }
    
    var numericOnly: String {
        return components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
    }
    
    func limitedToDecimalPlaces(_ places: Int) -> String {
        guard let dotIndex = firstIndex(of: ".") else { return self }
        let maxIndex = index(dotIndex, offsetBy: places + 1, limitedBy: endIndex) ?? endIndex
        return String(self[..<maxIndex])
    }
}

extension Double {
    func asCurrency() -> String {
        return NumberFormatter.currency.string(from: NSNumber(value: self)) ?? "$0.00"
    }
    
    func asPercentage() -> String {
        return "\(self.rounded(toPlaces: 2))%"
    }
    
    func asDecimal() -> String {
        return NumberFormatter.decimal.string(from: NSNumber(value: self)) ?? "0"
    }
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct InputValidator {
    static func validateCurrencyInput(_ input: String) -> (isValid: Bool, errorMessage: String?) {
        if input.isEmpty {
            return (true, nil)
        }
        
        guard let value = Double(input) else {
            return (false, "Invalid number format")
        }
        
        if value < 0 {
            return (false, "Value cannot be negative")
        }
        
        if value > 999999.99 {
            return (false, "Value too large")
        }
        
        return (true, nil)
    }
    
    static func validatePercentageInput(_ input: String) -> (isValid: Bool, errorMessage: String?) {
        if input.isEmpty {
            return (true, nil)
        }
        
        guard let value = Double(input) else {
            return (false, "Invalid number format")
        }
        
        if value < 0 {
            return (false, "Percentage cannot be negative")
        }
        
        if value > 100 {
            return (false, "Percentage cannot exceed 100%")
        }
        
        return (true, nil)
    }
    
    static func formatCurrencyInput(_ input: String) -> String {
        let cleaned = input.numericOnly
        
        if cleaned.contains(".") {
            return cleaned.limitedToDecimalPlaces(2)
        }
        
        return cleaned
    }
    
    static func formatPercentageInput(_ input: String) -> String {
        let cleaned = input.numericOnly
        
        if cleaned.contains(".") {
            let formatted = cleaned.limitedToDecimalPlaces(2)
            if let value = Double(formatted), value > 100 {
                return "100"
            }
            return formatted
        }
        
        if let value = Double(cleaned), value > 100 {
            return "100"
        }
        
        return cleaned
    }
}

