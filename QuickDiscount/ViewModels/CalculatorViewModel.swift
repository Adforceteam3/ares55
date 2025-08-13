import Foundation
import Combine

class CalculatorViewModel: ObservableObject {
    @Published var calculation = CalculationModel()
    @Published var showingAdvancedParameters = false
    @Published var validationErrors: [ValidationError] = []
    
    @Published var originalPriceText = ""
    @Published var mainDiscountText = ""
    @Published var additionalDiscountText = ""
    @Published var fixedDiscountText = ""
    @Published var fixedFeeText = ""
    @Published var taxText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $originalPriceText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.calculation.originalPrice = Double(text) ?? 0
                self?.validateInputs()
            }
            .store(in: &cancellables)
        
        $mainDiscountText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.calculation.mainDiscount = Double(text) ?? 0
                self?.validateInputs()
            }
            .store(in: &cancellables)
        
        $additionalDiscountText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.calculation.additionalDiscount = Double(text) ?? 0
                self?.validateInputs()
            }
            .store(in: &cancellables)
        
        $fixedDiscountText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.calculation.fixedDiscount = Double(text) ?? 0
                self?.validateInputs()
            }
            .store(in: &cancellables)
        
        $fixedFeeText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.calculation.fixedFee = Double(text) ?? 0
                self?.validateInputs()
            }
            .store(in: &cancellables)
        
        $taxText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.calculation.tax = Double(text) ?? 0
                self?.validateInputs()
            }
            .store(in: &cancellables)
    }
    
    private func validateInputs() {
        validationErrors.removeAll()
        
        if calculation.originalPrice < 0 {
            validationErrors.append(.negativePrice)
        }
        
        if calculation.mainDiscount > 100 {
            validationErrors.append(.discountTooHigh("Main discount cannot exceed 100%"))
        }
        
        if calculation.additionalDiscount > 100 {
            validationErrors.append(.discountTooHigh("Additional discount cannot exceed 100%"))
        }
        
        if calculation.tax > 100 {
            validationErrors.append(.taxTooHigh)
        }
        
        if calculation.fixedDiscount < 0 {
            validationErrors.append(.negativeFixedDiscount)
        }
        
        if calculation.fixedFee < 0 {
            validationErrors.append(.negativeFixedFee)
        }
    }
    
    func applyAdvancedParameters() {
        showingAdvancedParameters = false
    }
    
    func resetAdvancedParameters() {
        calculation.additionalDiscount = 0
        calculation.fixedDiscount = 0
        calculation.fixedFee = 0
        
        additionalDiscountText = ""
        fixedDiscountText = ""
        fixedFeeText = ""
        
        showingAdvancedParameters = false
    }
    
    func resetCalculation() {
        calculation = CalculationModel()
        
        originalPriceText = ""
        mainDiscountText = ""
        additionalDiscountText = ""
        fixedDiscountText = ""
        fixedFeeText = ""
        taxText = ""
        
        validationErrors.removeAll()
    }
    
    var canShowResults: Bool {
        return calculation.originalPrice > 0 && validationErrors.isEmpty
    }
    
    var canSaveCalculation: Bool {
        return canShowResults && calculation.isValid
    }
    
    func getValidationError(for field: ValidationField) -> String? {
        return validationErrors.first { error in
            switch (error, field) {
            case (.negativePrice, .originalPrice):
                return true
            case (.discountTooHigh(let message), .mainDiscount):
                return message.contains("Main")
            case (.discountTooHigh(let message), .additionalDiscount):
                return message.contains("Additional")
            case (.taxTooHigh, .tax):
                return true
            case (.negativeFixedDiscount, .fixedDiscount):
                return true
            case (.negativeFixedFee, .fixedFee):
                return true
            default:
                return false
            }
        }?.localizedDescription
    }
}

enum ValidationError: Error {
    case negativePrice
    case discountTooHigh(String)
    case taxTooHigh
    case negativeFixedDiscount
    case negativeFixedFee
    
    var localizedDescription: String {
        switch self {
        case .negativePrice:
            return "Price cannot be negative"
        case .discountTooHigh(let message):
            return message
        case .taxTooHigh:
            return "Tax cannot exceed 100%"
        case .negativeFixedDiscount:
            return "Fixed discount cannot be negative"
        case .negativeFixedFee:
            return "Fixed fee cannot be negative"
        }
    }
}

enum ValidationField {
    case originalPrice
    case mainDiscount
    case additionalDiscount
    case fixedDiscount
    case fixedFee
    case tax
}

