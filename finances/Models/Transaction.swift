import Foundation

// MARK: - Transaction Type

enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
    case transfer

    var label: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        case .transfer: return "Transfer"
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
    var destAccountId: UUID?
    var currencyCode: String
    var note: String
    var date: Date

    init(
        id: UUID = UUID(),
        amount: Decimal,
        type: TransactionType,
        categoryId: UUID,
        accountId: UUID,
        destAccountId: UUID? = nil,
        currencyCode: String,
        note: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.accountId = accountId
        self.destAccountId = destAccountId
        self.currencyCode = currencyCode
        self.note = note
        self.date = date
    }

    var isTransfer: Bool { type == .transfer }
}
