import SwiftUI

struct DashboardView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showingAddTransaction = false

    private var recentTransactions: [Transaction] {
        Array(storage.transactions.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceCard
                    categorySection
                    accountsSection
                    recentSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Ledgr")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddTransaction = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
            }
        }
    }

    // MARK: - Balance Card

    private var balanceCard: some View {
        let bal = storage.balance()
        let month = storage.thisMonth()
        let income = storage.totalIncome(for: month)
        let expense = storage.totalExpense(for: month)

        return VStack(spacing: 0) {
            // Top section: balance
            VStack(spacing: 6) {
                Text("Current Balance")
                    .font(.caption.weight(.semibold))
                    .textCase(.uppercase)
                    .foregroundStyle(.secondary)

                Text(CurrencyFormatter.format(bal, currencyCode: storage.baseCurrency))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(bal >= 0 ? Color.green : Color.red)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)

            Divider()
                .padding(.horizontal, 20)

            // Bottom: income / expense
            HStack(spacing: 0) {
                // Income
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.green)
                        Text("Income")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(CurrencyFormatter.formatShort(income, currencyCode: storage.baseCurrency))
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 1, height: 30)

                // Expense
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.red)
                        Text("Expense")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(CurrencyFormatter.formatShort(expense, currencyCode: storage.baseCurrency))
                        .font(.callout.weight(.bold))
                        .foregroundStyle(.red)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 14)
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    // MARK: - Summary Row

    // MARK: - Category Section

    @ViewBuilder
    private var categorySection: some View {
        let expenses = storage.expenseByCategory(for: storage.thisMonth())

        if !expenses.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader("Spending by Category")

                let totalExpense = expenses.reduce(0) { $0 + $1.1 }

                ForEach(expenses.prefix(6), id: \.0.id) { cat, total in
                    let pct = totalExpense > 0
                        ? NSDecimalNumber(decimal: total / totalExpense).doubleValue
                        : 0

                    HStack(spacing: 10) {
                        Image(systemName: cat.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(cat.color)
                            .frame(width: 28, height: 28)
                            .background(cat.color.opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(cat.name)
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text(CurrencyFormatter.formatShort(total, currencyCode: storage.baseCurrency))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 4)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(cat.color)
                                        .frame(width: max(4, geo.size.width * pct), height: 4)
                                }
                            }
                            .frame(height: 4)
                        }
                    }
                }
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    // MARK: - Accounts Section

    @ViewBuilder
    private var accountsSection: some View {
        if !storage.accounts.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader("Accounts")

                ForEach(storage.accounts.prefix(3)) { acc in
                    let bal = storage.balance(forAccount: acc.id)

                    HStack(spacing: 12) {
                        Image(systemName: acc.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.blue)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(acc.name)
                                .font(.subheadline.weight(.semibold))
                            Text("\(acc.type.label) · \(acc.currencyCode)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(CurrencyFormatter.format(bal, currencyCode: acc.currencyCode))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(bal >= 0 ? .green : .red)
                    }
                    .padding(14)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: - Recent Section

    @ViewBuilder
    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("Recent")
                Spacer()
                NavigationLink("See All") {
                    TransactionListView()
                }
                .font(.subheadline.weight(.medium))
            }

            if recentTransactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button { showingAddTransaction = true } label: {
                        Text("Add Your First")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { idx, tx in
                        TransactionRow(transaction: tx)
                        if idx < recentTransactions.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .padding(16)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline.weight(.semibold))
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    @Environment(StorageManager.self) private var storage
    let transaction: Transaction

    var body: some View {
        let category = storage.category(by: transaction.categoryId)
        let account = storage.account(by: transaction.accountId)

        HStack(spacing: 12) {
            ZStack {
                Image(systemName: category?.icon ?? "questionmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(category?.color ?? .gray)
                    .frame(width: 36, height: 36)
                    .background((category?.color ?? .gray).opacity(0.12))
                    .clipShape(Circle())

                if transaction.isTransfer {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 13, y: 13)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category?.name ?? "Unknown")
                    .font(.subheadline.weight(.medium))

                if transaction.type == .transfer, let destId = transaction.destAccountId,
                   let destAcc = storage.account(by: destId) {
                    HStack(spacing: 4) {
                        Text(account?.name ?? "?")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8, weight: .bold))
                        Text(destAcc.name)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 4) {
                        if let account {
                            Text(account.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !transaction.note.isEmpty {
                            Text((account != nil ? "· " : "") + transaction.note)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if transaction.type == .transfer {
                    Text(CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                } else {
                    let sign = transaction.type == .income ? "+" : "−"
                    Text("\(sign)\(CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(transaction.type == .income ? .green : .red)
                }

                Text(transaction.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    DashboardView()
        .environment(StorageManager())
}
