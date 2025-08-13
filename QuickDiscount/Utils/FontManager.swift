import SwiftUI

struct FontManager {
    static func registerFonts() {
        let fontNames = [
            "Jost-Regular",
            "Jost-Light",
            "Jost-Medium",
            "Jost-SemiBold",
            "Jost-Bold"
        ]
        
        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf"),
                  let fontData = NSData(contentsOf: fontURL),
                  let provider = CGDataProvider(data: fontData),
                  let font = CGFont(provider) else {
                print("Failed to register font: \(fontName)")
                continue
            }
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                print("Error registering font \(fontName): \(error.debugDescription)")
            }
        }
    }
    
    static func jostFont(size: CGFloat, weight: JostWeight = .regular) -> Font {
        return Font.custom(weight.fontName, size: size)
    }
    
    enum JostWeight {
        case light
        case regular
        case medium
        case semiBold
        case bold
        
        var fontName: String {
            switch self {
            case .light:
                return "Jost-Light"
            case .regular:
                return "Jost-Regular"
            case .medium:
                return "Jost-Medium"
            case .semiBold:
                return "Jost-SemiBold"
            case .bold:
                return "Jost-Bold"
            }
        }
    }
}

extension Font {
    static func jostLight(_ size: CGFloat) -> Font {
        return FontManager.jostFont(size: size, weight: .light)
    }
    
    static func jostRegular(_ size: CGFloat) -> Font {
        return FontManager.jostFont(size: size, weight: .regular)
    }
    
    static func jostMedium(_ size: CGFloat) -> Font {
        return FontManager.jostFont(size: size, weight: .medium)
    }
    
    static func jostSemiBold(_ size: CGFloat) -> Font {
        return FontManager.jostFont(size: size, weight: .semiBold)
    }
    
    static func jostBold(_ size: CGFloat) -> Font {
        return FontManager.jostFont(size: size, weight: .bold)
    }
}

extension Font {
    static let largeTitle = Font.jostBold(34)
    static let title1 = Font.jostBold(28)
    static let title2 = Font.jostSemiBold(22)
    static let title3 = Font.jostSemiBold(20)
    static let headline = Font.jostSemiBold(17)
    
    static let body = Font.jostRegular(17)
    static let bodyMedium = Font.jostMedium(17)
    static let callout = Font.jostRegular(16)
    static let subheadline = Font.jostRegular(15)
    static let footnote = Font.jostRegular(13)
    static let caption1 = Font.jostRegular(12)
    static let caption2 = Font.jostRegular(11)
    
    static let priceDisplay = Font.jostBold(32)
    static let currencyLarge = Font.jostSemiBold(24)
    static let currencyMedium = Font.jostMedium(18)
    static let currencySmall = Font.jostRegular(16)
    static let tabBarTitle = Font.jostMedium(10)
}

