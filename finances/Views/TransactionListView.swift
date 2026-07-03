import SwiftUI

struct TransactionListView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showingAdd = false
    @State private var editingTransaction: Transaction?
    @State private var filterType: TransactionType? = nil
    @State private var searchText = ""

    private var filteredTransactions: [Transaction] {
        var result = storage.transactions
        if let filterType { result = result.filter { $0.type == filterType } }
        if !searchText.isEmpty {
            result = result.filter { tx in
                let cat = storage.category(by: tx.categoryId)
                return (tx.note.localizedCaseInsensitiveContains(searchText)) ||
                       (cat?.name.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        return result
    }

    private var groupedTransactions: [(String, [Transaction])] {
        let cal = Calendar.current
        var groups: [String: [Transaction]] = [:]
        let df = DateFormatter()
        df.dateStyle = .medium

        for tx in filteredTransactions {
            let key = df.string(from: cal.startOfDay(for: tx.date))
            groups[key, default: []].append(tx)
        }
        return groups.sorted { lhs, rhs in
            guard let d1 = groups[lhs.key]?.first?.date,
                  let d2 = groups[rhs.key]?.first?.date else { return false }
            return d1 > d2
        }
    }

    var body: some View {
        NavigationStack {
            List {
                summarySection
                filterSection
                transactionsList
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Search transactions")
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) { AddTransactionView() }
            .sheet(item: $editingTransaction) { tx in AddTransactionView(editing: tx) }
        }
    }

    // MARK: - Summary

    private var summarySection: some View {
        let income = filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }

        return Section {
            HStack(spacing: 0) {
                statItem(label: "Income", amount: income, color: .green)
                Divider().frame(height: 32)
                statItem(label: "Expenses", amount: expense, color: .red)
                Divider().frame(height: 32)
                statItem(label: "Net", amount: income - expense, color: income >= expense ? .green : .red)
            }
            .padding(.vertical, 8)
        }
    }

    private func statItem(label: String, amount: Decimal, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.formatShort(amount, currencyCode: storage.baseCurrency))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Filter

    private var filterSection: some View {
        Section {
            Picker("Filter", selection: $filterType) {
                Text("All").tag(TransactionType?.none)
                Text("Income").tag(TransactionType?.some(.income))
                Text("Expenses").tag(TransactionType?.some(.expense))
            }
            .pickerStyle(.segmented)
        }
    }

    // MARK: - List

    @ViewBuilder
    private var transactionsList: some View {
        if filteredTransactions.isEmpty && !storage.transactions.isEmpty {
            Section {
                ContentUnavailableView(
                    "No Matching Transactions",
                    systemImage: "magnifyingglass",
                    description: Text("Try adjusting your search or filter.")
                )
            }
        } else if storage.transactions.isEmpty {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("No Transactions")
                        .font(.headline)
                    Text("Tap + to add your first transaction.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        } else {
            ForEach(groupedTransactions, id: \.0) { dateKey, txs in
                Section(dateKey) {
                    ForEach(txs) { tx in
                        Button { editingTransaction = tx } label: {
                            TransactionRow(transaction: tx)
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete { offsets in
                        for idx in offsets { storage.deleteTransaction(txs[idx].id) }
                    }
                }
            }
        }
    }
}

#Preview {
    TransactionListView()
        .environment(StorageManager())
}
