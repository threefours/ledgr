import Foundation

// MARK: - Account Type

enum AccountType: String, Codable, CaseIterable {
    case cash
    case bankCard
    case bankAccount
    case crypto
    case savings
    case other

    var label: String {
        switch self {
        case .cash: return "Cash"
        case .bankCard: return "Bank Card"
        case .bankAccount: return "Bank Account"
        case .crypto: return "Crypto Wallet"
        case .savings: return "Savings"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .cash: return "banknote"
        case .bankCard: return "creditcard"
        case .bankAccount: return "building.columns"
        case .crypto: return "bitcoinsign.circle"
        case .savings: return "lock.aisle"
        case .other: return "wallet.bifold"
        }
    }
}

// MARK: - PaymentAccount

struct PaymentAccount: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var type: AccountType
    var currencyCode: String
    var icon: String

    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        currencyCode: String = "USD",
        icon: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.currencyCode = currencyCode
        self.icon = icon ?? type.icon
    }
}

// MARK: - Default Accounts

extension PaymentAccount {
    static let defaults: [PaymentAccount] = [
        PaymentAccount(name: "Cash", type: .cash),
        PaymentAccount(name: "Main Card", type: .bankCard),
    ]
}
