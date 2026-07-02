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
                VStack(spacing: 20) {
                    balanceCard
                    monthSummary
                    categoryBreakdown
                    accountsOverview
                    recentTransactionsList
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Ledgr")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
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

        return VStack(spacing: 12) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white.opacity(0.8))

            Text("Total Balance")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))

            Text(CurrencyFormatter.format(bal, currencyCode: storage.baseCurrency))
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            LinearGradient(
                colors: bal >= 0
                    ? [Color(hex: "#2ECC71"), Color(hex: "#27AE60")]
                    : [Color(hex: "#E74C3C"), Color(hex: "#C0392B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: (bal >= 0 ? Color.green : Color.red).opacity(0.3), radius: 12, y: 6)
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
                color: .green,
                bgColor: Color.green.opacity(0.1)
            )

            summaryTile(
                title: "Expenses",
                amount: expense,
                icon: "arrow.up.circle.fill",
                color: .red,
                bgColor: Color.red.opacity(0.1)
            )
        }
    }

    private func summaryTile(title: String, amount: Decimal, icon: String, color: Color, bgColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 16))
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Text(CurrencyFormatter.format(amount, currencyCode: storage.baseCurrency))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Category Breakdown

    @ViewBuilder
    private var categoryBreakdown: some View {
        let expenses = storage.expenseByCategory(for: storage.thisMonth())

        if !expenses.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("This Month's Spending")
                    .font(.headline)
                    .fontWeight(.semibold)

                let totalExpense = expenses.reduce(0) { $0 + $1.1 }

                ForEach(expenses.prefix(5), id: \.0.id) { category, total in
                    VStack(spacing: 6) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(category.color.opacity(0.15))
                                    .frame(width: 32, height: 32)
                                Image(systemName: category.icon)
                                    .foregroundStyle(category.color)
                                    .font(.system(size: 13))
                            }

                            Text(category.name)
                                .font(.subheadline)

                            Spacer()

                            Text(CurrencyFormatter.format(total, currencyCode: storage.baseCurrency))
                                .font(.subheadline.weight(.medium))
                        }

                        // Progress bar
                        GeometryReader { geo in
                            let pct = totalExpense > 0
                                ? NSDecimalNumber(decimal: total / totalExpense).doubleValue
                                : 0

                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 6)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(category.color)
                                    .frame(width: geo.size.width * pct, height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        }
    }

    // MARK: - Accounts Overview

    @ViewBuilder
    private var accountsOverview: some View {
        if !storage.accounts.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("Accounts")
                    .font(.headline)
                    .fontWeight(.semibold)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(storage.accounts) { acc in
                            let bal = storage.balance(forAccount: acc.id)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: acc.icon)
                                        .foregroundStyle(.blue)
                                        .font(.system(size: 14))
                                    Text(acc.type.label)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text(acc.name)
                                    .font(.subheadline.weight(.medium))

                                Text(CurrencyFormatter.format(bal, currencyCode: acc.currencyCode))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(bal >= 0 ? .green : .red)
                            }
                            .padding(14)
                            .frame(width: 150)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent Transactions

    private var recentTransactionsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                NavigationLink("See All") {
                    TransactionListView()
                }
                .font(.subheadline)
            }

            if recentTransactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    Text("No transactions yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Add Your First Transaction") {
                        showingAddTransaction = true
                    }
                    .font(.subheadline.weight(.medium))
                    .buttonStyle(.bordered)
                    .tint(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(recentTransactions) { tx in
                    TransactionRow(transaction: tx)
                    if tx.id != recentTransactions.last?.id {
                        Divider()
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

// MARK: - Transaction Row

struct TransactionRow: View {
    @Environment(StorageManager.self) private var storage
    let transaction: Transaction

    var body: some View {
        let category = storage.category(by: transaction.categoryId)
        let account = storage.account(by: transaction.accountId)

        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill((category?.color ?? .gray).opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: category?.icon ?? "questionmark")
                    .foregroundStyle(category?.color ?? .gray)
                    .font(.system(size: 16, weight: .medium))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(category?.name ?? "Unknown")
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 4) {
                    if let account {
                        Text(account.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !transaction.note.isEmpty {
                        Text((account != nil ? "· " : "") + transaction.note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                let sign = transaction.type == .income ? "+" : "−"
                Text("\(sign)\(CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(transaction.type == .income ? .green : .red)

                Text(transaction.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    DashboardView()
        .environment(StorageManager())
}
