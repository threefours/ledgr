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
        Currency(code: "USD", symbol: "$", name: "US Dollar"),
        Currency(code: "EUR", symbol: "€", name: "Euro"),
        Currency(code: "GBP", symbol: "£", name: "British Pound"),
        Currency(code: "JPY", symbol: "¥", name: "Japanese Yen"),
        Currency(code: "CHF", symbol: "Fr", name: "Swiss Franc"),
        Currency(code: "CAD", symbol: "C$", name: "Canadian Dollar"),
        Currency(code: "AUD", symbol: "A$", name: "Australian Dollar"),
        Currency(code: "CNY", symbol: "¥", name: "Chinese Yuan"),
        Currency(code: "INR", symbol: "₹", name: "Indian Rupee"),
        Currency(code: "RUB", symbol: "₽", name: "Russian Ruble"),
        Currency(code: "BRL", symbol: "R$", name: "Brazilian Real"),
        Currency(code: "KRW", symbol: "₩", name: "South Korean Won"),
        Currency(code: "SGD", symbol: "S$", name: "Singapore Dollar"),
        Currency(code: "HKD", symbol: "HK$", name: "Hong Kong Dollar"),
        Currency(code: "TRY", symbol: "₺", name: "Turkish Lira"),
        Currency(code: "MXN", symbol: "Mex$", name: "Mexican Peso"),
        Currency(code: "SEK", symbol: "kr", name: "Swedish Krona"),
        Currency(code: "NOK", symbol: "kr", name: "Norwegian Krone"),
        Currency(code: "DKK", symbol: "kr", name: "Danish Krone"),
        Currency(code: "PLN", symbol: "zł", name: "Polish Zloty"),
        Currency(code: "CZK", symbol: "Kč", name: "Czech Koruna"),
        Currency(code: "THB", symbol: "฿", name: "Thai Baht"),
        Currency(code: "AED", symbol: "د.إ", name: "UAE Dirham"),
        Currency(code: "SAR", symbol: "﷼", name: "Saudi Riyal"),
        Currency(code: "ZAR", symbol: "R", name: "South African Rand"),
    ]

    static func symbol(for code: String) -> String {
        available.first { $0.code == code }?.symbol ?? code
    }

    static func name(for code: String) -> String {
        available.first { $0.code == code }?.name ?? code
    }
}
