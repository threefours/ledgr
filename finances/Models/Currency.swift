import Foundation

// MARK: - Currency

struct Currency: Codable, Identifiable, Equatable, Hashable {
    let code: String
    let symbol: String
    let name: String

    var id: String { code }
}

// MARK: - Available Currencies

extension Currency {
    static let available: [Currency] = [
        Currency(code: "RUB", symbol: "₽",   name: "Russian Ruble"),
        Currency(code: "USD", symbol: "$",   name: "US Dollar"),
        Currency(code: "EUR", symbol: "€",   name: "Euro"),
        Currency(code: "GBP", symbol: "£",   name: "British Pound"),
        Currency(code: "CHF", symbol: "Fr",  name: "Swiss Franc"),
        Currency(code: "JPY", symbol: "¥",   name: "Japanese Yen"),
        Currency(code: "CNY", symbol: "¥",   name: "Chinese Yuan"),
        Currency(code: "AED", symbol: "د.إ", name: "UAE Dirham"),
        Currency(code: "TRY", symbol: "₺",   name: "Turkish Lira"),
        Currency(code: "INR", symbol: "₹",   name: "Indian Rupee"),
        Currency(code: "BRL", symbol: "R$",  name: "Brazilian Real"),
        Currency(code: "BTC", symbol: "₿",   name: "Bitcoin"),
        Currency(code: "ETH", symbol: "Ξ",   name: "Ethereum"),
    ]

    /// Shorter list for quick pickers (onboarding, etc.)
    static let popular: [Currency] = [
        Currency(code: "RUB", symbol: "₽",   name: "Russian Ruble"),
        Currency(code: "USD", symbol: "$",   name: "US Dollar"),
        Currency(code: "EUR", symbol: "€",   name: "Euro"),
        Currency(code: "GBP", symbol: "£",   name: "British Pound"),
        Currency(code: "BTC", symbol: "₿",   name: "Bitcoin"),
    ]

    static func symbol(for code: String) -> String {
        available.first { $0.code == code }?.symbol ?? code
    }

    static func name(for code: String) -> String {
        available.first { $0.code == code }?.name ?? code
    }
}
