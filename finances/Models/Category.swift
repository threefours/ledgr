import Foundation
import SwiftUI

// MARK: - Category

struct Category: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var type: TransactionType

    var color: Color {
        Color(hex: colorHex)
    }

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        type: TransactionType
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.type = type
    }
}

// MARK: - Default Categories

extension Category {
    static let defaultExpense: [Category] = [
        Category(name: "Food & Drinks", icon: "fork.knife", colorHex: "#FF6B6B", type: .expense),
        Category(name: "Transport", icon: "car.fill", colorHex: "#4ECDC4", type: .expense),
        Category(name: "Shopping", icon: "bag.fill", colorHex: "#45B7D1", type: .expense),
        Category(name: "Entertainment", icon: "film.fill", colorHex: "#96CEB4", type: .expense),
        Category(name: "Health", icon: "heart.fill", colorHex: "#FFEAA7", type: .expense),
        Category(name: "Bills", icon: "doc.text.fill", colorHex: "#DDA0DD", type: .expense),
        Category(name: "Education", icon: "book.fill", colorHex: "#98D8C8", type: .expense),
        Category(name: "Other", icon: "ellipsis.circle.fill", colorHex: "#B0BEC5", type: .expense),
    ]

    static let defaultIncome: [Category] = [
        Category(name: "Opening Balance", icon: "banknote.fill", colorHex: "#2ECC71", type: .income),
        Category(name: "Salary", icon: "dollarsign.circle.fill", colorHex: "#27AE60", type: .income),
        Category(name: "Freelance", icon: "laptopcomputer", colorHex: "#3498DB", type: .income),
        Category(name: "Investments", icon: "chart.line.uptrend.xyaxis", colorHex: "#9B59B6", type: .income),
        Category(name: "Gifts", icon: "gift.fill", colorHex: "#E74C3C", type: .income),
        Category(name: "Other", icon: "plus.circle.fill", colorHex: "#1ABC9C", type: .income),
    ]

    static var allDefaults: [Category] {
        defaultExpense + defaultIncome
    }
}
