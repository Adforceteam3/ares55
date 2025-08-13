import Foundation
import Combine

class ComparisonViewModel: ObservableObject {
    @Published var variantA = CalculationModel()
    @Published var variantB = CalculationModel()
    @Published var validationErrorsA: [ValidationError] = []
    @Published var validationErrorsB: [ValidationError] = []
    
    @Published var originalPriceTextA = ""
    @Published var mainDiscountTextA = ""
    @Published var additionalDiscountTextA = ""
    @Published var fixedDiscountTextA = ""
    @Published var fixedFeeTextA = ""
    @Published var taxTextA = ""
    
    @Published var originalPriceTextB = ""
    @Published var mainDiscountTextB = ""
    @Published var additionalDiscountTextB = ""
    @Published var fixedDiscountTextB = ""
    @Published var fixedFeeTextB = ""
    @Published var taxTextB = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $originalPriceTextA
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantA.originalPrice = Double(text) ?? 0
                self?.validateVariantA()
            }
            .store(in: &cancellables)
        
        $mainDiscountTextA
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantA.mainDiscount = Double(text) ?? 0
                self?.validateVariantA()
            }
            .store(in: &cancellables)
        
        $additionalDiscountTextA
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantA.additionalDiscount = Double(text) ?? 0
                self?.validateVariantA()
            }
            .store(in: &cancellables)
        
        $fixedDiscountTextA
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantA.fixedDiscount = Double(text) ?? 0
                self?.validateVariantA()
            }
            .store(in: &cancellables)
        
        $fixedFeeTextA
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantA.fixedFee = Double(text) ?? 0
                self?.validateVariantA()
            }
            .store(in: &cancellables)
        
        $taxTextA
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantA.tax = Double(text) ?? 0
                self?.validateVariantA()
            }
            .store(in: &cancellables)
        
        $originalPriceTextB
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantB.originalPrice = Double(text) ?? 0
                self?.validateVariantB()
            }
            .store(in: &cancellables)
        
        $mainDiscountTextB
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantB.mainDiscount = Double(text) ?? 0
                self?.validateVariantB()
            }
            .store(in: &cancellables)
        
        $additionalDiscountTextB
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantB.additionalDiscount = Double(text) ?? 0
                self?.validateVariantB()
            }
            .store(in: &cancellables)
        
        $fixedDiscountTextB
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantB.fixedDiscount = Double(text) ?? 0
                self?.validateVariantB()
            }
            .store(in: &cancellables)
        
        $fixedFeeTextB
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantB.fixedFee = Double(text) ?? 0
                self?.validateVariantB()
            }
            .store(in: &cancellables)
        
        $taxTextB
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.variantB.tax = Double(text) ?? 0
                self?.validateVariantB()
            }
            .store(in: &cancellables)
    }
    
    private func validateVariantA() {
        validationErrorsA = validateCalculation(variantA)
    }
    
    private func validateVariantB() {
        validationErrorsB = validateCalculation(variantB)
    }
    
    private func validateCalculation(_ calculation: CalculationModel) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        if calculation.originalPrice < 0 {
            errors.append(.negativePrice)
        }
        
        if calculation.mainDiscount > 100 {
            errors.append(.discountTooHigh("Main discount cannot exceed 100%"))
        }
        
        if calculation.additionalDiscount > 100 {
            errors.append(.discountTooHigh("Additional discount cannot exceed 100%"))
        }
        
        if calculation.tax > 100 {
            errors.append(.taxTooHigh)
        }
        
        if calculation.fixedDiscount < 0 {
            errors.append(.negativeFixedDiscount)
        }
        
        if calculation.fixedFee < 0 {
            errors.append(.negativeFixedFee)
        }
        
        return errors
    }
    
    var comparison: ComparisonModel {
        return ComparisonModel(variantA: variantA, variantB: variantB)
    }
    
    var canShowComparison: Bool {
        return variantA.originalPrice > 0 && variantB.originalPrice > 0 &&
               validationErrorsA.isEmpty && validationErrorsB.isEmpty
    }
    
    var canSaveComparison: Bool {
        return canShowComparison && variantA.isValid && variantB.isValid
    }
    
    var variantAIsValid: Bool {
        return variantA.originalPrice > 0 && validationErrorsA.isEmpty
    }
    
    var variantBIsValid: Bool {
        return variantB.originalPrice > 0 && validationErrorsB.isEmpty
    }
    
    func resetComparison() {
        variantA = CalculationModel()
        variantB = CalculationModel()
        
        originalPriceTextA = ""
        mainDiscountTextA = ""
        additionalDiscountTextA = ""
        fixedDiscountTextA = ""
        fixedFeeTextA = ""
        taxTextA = ""
        
        originalPriceTextB = ""
        mainDiscountTextB = ""
        additionalDiscountTextB = ""
        fixedDiscountTextB = ""
        fixedFeeTextB = ""
        taxTextB = ""
        
        validationErrorsA.removeAll()
        validationErrorsB.removeAll()
    }
    
    func copyVariantAToB() {
        variantB = variantA
        originalPriceTextB = originalPriceTextA
        mainDiscountTextB = mainDiscountTextA
        additionalDiscountTextB = additionalDiscountTextA
        fixedDiscountTextB = fixedDiscountTextA
        fixedFeeTextB = fixedFeeTextA
        taxTextB = taxTextA
    }
    
    func copyVariantBToA() {
        variantA = variantB
        originalPriceTextA = originalPriceTextB
        mainDiscountTextA = mainDiscountTextB
        additionalDiscountTextA = additionalDiscountTextB
        fixedDiscountTextA = fixedDiscountTextB
        fixedFeeTextA = fixedFeeTextB
        taxTextA = taxTextB
    }
    
    func getValidationError(for field: ValidationField, variant: ComparisonVariant) -> String? {
        let errors = variant == .a ? validationErrorsA : validationErrorsB
        
        return errors.first { error in
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

enum ComparisonVariant {
    case a
    case b
}

