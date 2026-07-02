import SwiftUI

struct DashboardView: View {
    @Environment(StorageManager.self) private var storage

    private var recentTransactions: [Transaction] {
        Array(storage.transactions.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    balanceCard
                    monthSummary
                    categoryBreakdown
                    recentTransactionsList
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Ledgr")
        }
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        let bal = storage.balance()
        let symbol = Currency.symbol(for: storage.baseCurrency)

        return VStack(spacing: 8) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(CurrencyFormatter.format(bal, currencyCode: storage.baseCurrency))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(bal >= 0 ? .green : .red)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Month Summary

    private var monthSummary: some View {
        let month = storage.thisMonth()
        let income = storage.totalIncome(for: month)
        let expense = storage.totalExpense(for: month)

        return HStack(spacing: 12) {
            summaryTile(
                title: "Income",
                amount: income,
                icon: "arrow.down.circle.fill",
                color: .green
            )

            summaryTile(
                title: "Expenses",
                amount: expense,
                icon: "arrow.up.circle.fill",
                color: .red
            )
        }
    }

    private func summaryTile(title: String, amount: Decimal, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(CurrencyFormatter.format(amount, currencyCode: storage.baseCurrency))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Category Breakdown

    @ViewBuilder
    private var categoryBreakdown: some View {
        let expenses = storage.expenseByCategory(for: storage.thisMonth())

        if !expenses.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Spending by Category")
                    .font(.headline)

                ForEach(expenses.prefix(5), id: \.0.id) { category, total in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)

                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                            .frame(width: 20)

                        Text(category.name)
                            .font(.subheadline)

                        Spacer()

                        Text(CurrencyFormatter.format(total, currencyCode: storage.baseCurrency))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.headline)

            if recentTransactions.isEmpty {
                Text("No transactions yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(recentTransactions) { tx in
                    TransactionRow(transaction: tx)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    @Environment(StorageManager.self) private var storage
    let transaction: Transaction

    var body: some View {
        let category = storage.category(by: transaction.categoryId)
        let account = storage.account(by: transaction.accountId)

        HStack {
            ZStack {
                Circle()
                    .fill(category?.color ?? .gray)
                    .frame(width: 40, height: 40)
                Image(systemName: category?.icon ?? "questionmark")
                    .foregroundStyle(.white)
                    .font(.system(size: 16))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category?.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    if let account {
                        Text(account.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !transaction.note.isEmpty {
                        Text("· \(transaction.note)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                let sign = transaction.type == .income ? "+" : "-"
                Text("\(sign)\(CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(transaction.type == .income ? .green : .red)

                Text(transaction.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
        .environment(StorageManager())
}
