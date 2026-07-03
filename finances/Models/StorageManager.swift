import Foundation
import SwiftUI

// MARK: - App Data

struct AppData: Codable {
    var transactions: [Transaction]
    var categories: [Category]
    var accounts: [PaymentAccount]
    var baseCurrency: String
    var initialBalance: Decimal

    static var empty: AppData {
        AppData(
            transactions: [],
            categories: Category.allDefaults,
            accounts: PaymentAccount.defaults,
            baseCurrency: "USD",
            initialBalance: 0
        )
    }
}

// MARK: - Storage Manager

@Observable
final class StorageManager {
    var transactions: [Transaction] = []
    var categories: [Category] = []
    var accounts: [PaymentAccount] = []
    var baseCurrency: String = "USD"
    var initialBalance: Decimal = 0

    private let fileName = "ledgr_data.json"

    // MARK: - Init

    init() {
        load()
    }

    // MARK: - Persistence

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(AppData.self, from: data) else {
            // First launch: use defaults
            let defaults = AppData.empty
            self.transactions = defaults.transactions
            self.categories = defaults.categories
            self.accounts = defaults.accounts
            self.baseCurrency = defaults.baseCurrency
            self.initialBalance = defaults.initialBalance
            save()
            return
        }
        self.transactions = decoded.transactions
        self.categories = decoded.categories
        self.accounts = decoded.accounts
        self.baseCurrency = decoded.baseCurrency
        self.initialBalance = decoded.initialBalance
    }

    func save() {
        let data = AppData(
            transactions: transactions,
            categories: categories,
            accounts: accounts,
            baseCurrency: baseCurrency,
            initialBalance: initialBalance
        )
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        try? encoded.write(to: fileURL)
    }

    // MARK: - Transactions

    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        transactions.sort { $0.date > $1.date }
        save()
    }

    func updateTransaction(_ transaction: Transaction) {
        guard let idx = transactions.firstIndex(where: { $0.id == transaction.id }) else { return }
        transactions[idx] = transaction
        transactions.sort { $0.date > $1.date }
        save()
    }

    func deleteTransaction(_ id: UUID) {
        transactions.removeAll { $0.id == id }
        save()
    }

    func deleteTransactions(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
        save()
    }

    // MARK: - Categories

    func addCategory(_ category: Category) {
        categories.append(category)
        save()
    }

    func updateCategory(_ category: Category) {
        guard let idx = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[idx] = category
        save()
    }

    func deleteCategory(_ id: UUID) {
        categories.removeAll { $0.id == id }
        save()
    }

    func categories(for type: TransactionType) -> [Category] {
        categories.filter { $0.type == type }
    }

    func category(by id: UUID) -> Category? {
        categories.first { $0.id == id }
    }

    // MARK: - Accounts

    func addAccount(_ account: PaymentAccount) {
        accounts.append(account)
        save()
    }

    func updateAccount(_ account: PaymentAccount) {
        guard let idx = accounts.firstIndex(where: { $0.id == account.id }) else { return }
        accounts[idx] = account
        save()
    }

    func deleteAccount(_ id: UUID) {
        accounts.removeAll { $0.id == id }
        save()
    }

    func account(by id: UUID) -> PaymentAccount? {
        accounts.first { $0.id == id }
    }

    // MARK: - Transfers

    func transfer(
        amount: Decimal,
        from sourceAccountId: UUID,
        to destAccountId: UUID,
        date: Date = Date(),
        note: String = ""
    ) {
        guard sourceAccountId != destAccountId,
              let sourceAcc = account(by: sourceAccountId),
              let destAcc = account(by: destAccountId) else { return }

        guard let transferCat = categories.first(where: { $0.name == "Transfer" && $0.type == .expense }) else { return }

        let tx = Transaction(
            amount: amount,
            type: .transfer,
            categoryId: transferCat.id,
            accountId: sourceAccountId,
            destAccountId: destAccountId,
            currencyCode: sourceAcc.currencyCode,
            note: note.isEmpty ? "\(sourceAcc.name) → \(destAcc.name)" : note,
            date: date
        )

        transactions.append(tx)
        transactions.sort { $0.date > $1.date }
        save()
    }

    func updateTransfer(_ tx: Transaction, amount: Decimal, from: UUID, to: UUID, date: Date, note: String) {
        guard let idx = transactions.firstIndex(where: { $0.id == tx.id }) else { return }
        var updated = tx
        updated.amount = amount
        updated.accountId = from
        updated.destAccountId = to
        updated.date = date
        updated.note = note
        updated.currencyCode = account(by: from)?.currencyCode ?? tx.currencyCode
        transactions[idx] = updated
        transactions.sort { $0.date > $1.date }
        save()
    }

    // MARK: - Balance for Account (handles transfers)

    func balance(forAccount accountId: UUID) -> Decimal {
        var total: Decimal = 0
        for tx in transactions {
            if tx.type == .transfer {
                if tx.accountId == accountId {
                    total -= tx.amount
                }
                if tx.destAccountId == accountId {
                    total += tx.amount
                }
            } else if tx.accountId == accountId {
                total += (tx.type == .income ? tx.amount : -tx.amount)
            }
        }
        return total
    }

    // MARK: - Export / Import

    func exportData() -> Data? {
        let data = AppData(
            transactions: transactions,
            categories: categories,
            accounts: accounts,
            baseCurrency: baseCurrency,
            initialBalance: initialBalance
        )
        return try? JSONEncoder().encode(data)
    }

    func importData(from jsonData: Data) throws {
        let decoded = try JSONDecoder().decode(AppData.self, from: jsonData)
        self.transactions = decoded.transactions
        self.categories = decoded.categories
        self.accounts = decoded.accounts
        self.baseCurrency = decoded.baseCurrency
        self.initialBalance = decoded.initialBalance
        save()
    }

    // MARK: - Currency

    func setBaseCurrency(_ code: String) {
        baseCurrency = code
        save()
    }

    // MARK: - Statistics

    func totalIncome(for period: DateInterval? = nil) -> Decimal {
        transactions
            .filter { $0.type == .income }
            .filter { period == nil || period!.contains($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    func totalExpense(for period: DateInterval? = nil) -> Decimal {
        transactions
            .filter { $0.type == .expense }
            .filter { period == nil || period!.contains($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    func balance(for period: DateInterval? = nil) -> Decimal {
        initialBalance + totalIncome(for: period) - totalExpense(for: period)
    }

    func setInitialBalance(_ value: Decimal) {
        initialBalance = value
        save()
    }

    func expenseByCategory(for period: DateInterval? = nil) -> [(Category, Decimal)] {
        var map: [UUID: Decimal] = [:]
        for tx in transactions where tx.type == .expense {
            if let period, !period.contains(tx.date) { continue }
            map[tx.categoryId, default: 0] += tx.amount
        }
        return map.compactMap { (id, total) in
            guard let cat = category(by: id) else { return nil }
            return (cat, total)
        }.sorted { $0.1 > $1.1 }
    }

    func incomeByCategory(for period: DateInterval? = nil) -> [(Category, Decimal)] {
        var map: [UUID: Decimal] = [:]
        for tx in transactions where tx.type == .income {
            if let period, !period.contains(tx.date) { continue }
            map[tx.categoryId, default: 0] += tx.amount
        }
        return map.compactMap { (id, total) in
            guard let cat = category(by: id) else { return nil }
            return (cat, total)
        }.sorted { $0.1 > $1.1 }
    }

    func transactions(forAccount accountId: UUID) -> [Transaction] {
        transactions.filter { $0.accountId == accountId }
    }

    // MARK: - Date Helpers

    func thisMonth() -> DateInterval {
        let cal = Calendar.current
        let now = Date()
        let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let end = cal.date(byAdding: DateComponents(month: 1, day: -1), to: start)!
        return DateInterval(start: start, end: cal.startOfDay(for: end).addingTimeInterval(86399))
    }

    func thisWeek() -> DateInterval {
        let cal = Calendar.current
        let now = Date()
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let end = cal.date(byAdding: .day, value: 6, to: start)!
        return DateInterval(start: start, end: cal.startOfDay(for: end).addingTimeInterval(86399))
    }
}
