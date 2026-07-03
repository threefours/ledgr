import Foundation

struct CurrencyFormatter {
    static func format(_ amount: Decimal, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.currencySymbol = Currency.symbol(for: currencyCode)
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "\(currencyCode) \(amount)"
    }

    /// Locale-independent decimal parser — works with both "." and "," separators
    static func parseDecimal(_ string: String) -> Decimal? {
        let cleaned = string
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Decimal(string: cleaned, locale: Locale(identifier: "en_US_POSIX"))
    }

    static func formatShort(_ amount: Decimal, currencyCode: String) -> String {
        let symbol = Currency.symbol(for: currencyCode)
        let doubleValue = NSDecimalNumber(decimal: amount).doubleValue

        if abs(doubleValue) >= 1_000_000 {
            return String(format: "%@%.1fM", symbol, doubleValue / 1_000_000)
        } else if abs(doubleValue) >= 1_000 {
            return String(format: "%@%.1fK", symbol, doubleValue / 1_000)
        } else {
            return format(amount, currencyCode: currencyCode)
        }
    }
}
