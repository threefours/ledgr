import Foundation

// MARK: - Transaction Type

enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense

    var label: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        }
    }
}

// MARK: - Transaction

struct Transaction: Codable, Identifiable, Equatable {
    let id: UUID
    var amount: Decimal
    var type: TransactionType
    var categoryId: UUID
    var accountId: UUID
    var currencyCode: String
    var note: String
    var date: Date
    var transferId: UUID?

    init(
        id: UUID = UUID(),
        amount: Decimal,
        type: TransactionType,
        categoryId: UUID,
        accountId: UUID,
        currencyCode: String,
        note: String = "",
        date: Date = Date(),
        transferId: UUID? = nil
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.accountId = accountId
        self.currencyCode = currencyCode
        self.note = note
        self.date = date
        self.transferId = transferId
    }

    var isTransfer: Bool { transferId != nil }
}
