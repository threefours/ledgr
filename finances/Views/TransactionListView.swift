import SwiftUI

struct TransactionListView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showingAdd = false
    @State private var filterType: TransactionType? = nil
    @State private var searchText = ""

    private var filteredTransactions: [Transaction] {
        var result = storage.transactions

        if let filterType {
            result = result.filter { $0.type == filterType }
        }

        if !searchText.isEmpty {
            result = result.filter { tx in
                let cat = storage.category(by: tx.categoryId)
                let noteMatch = tx.note.localizedCaseInsensitiveContains(searchText)
                let catMatch = cat?.name.localizedCaseInsensitiveContains(searchText) ?? false
                return noteMatch || catMatch
            }
        }

        return result
    }

    private var groupedTransactions: [(String, [Transaction])] {
        let cal = Calendar.current
        var groups: [String: [Transaction]] = [:]
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        for tx in filteredTransactions {
            let startOfDay = cal.startOfDay(for: tx.date)
            let key = formatter.string(from: startOfDay)
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
                // Summary section
                Section {
                    summaryHeader
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                // Filter
                Section {
                    Picker("Filter", selection: $filterType) {
                        Text("All").tag(TransactionType?.none)
                        Text("Income").tag(TransactionType?.some(.income))
                        Text("Expenses").tag(TransactionType?.some(.expense))
                    }
                    .pickerStyle(.segmented)
                }

                // Grouped transactions
                ForEach(groupedTransactions, id: \.0) { dateKey, txs in
                    Section(dateKey) {
                        ForEach(txs) { tx in
                            TransactionRow(transaction: tx)
                        }
                        .onDelete { offsets in
                            for idx in offsets {
                                storage.deleteTransaction(txs[idx].id)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search transactions")
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAdd = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTransactionView()
            }
        }
    }

    private var summaryHeader: some View {
        let income = filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }

        return HStack {
            VStack {
                Text("Income")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.format(income, currencyCode: storage.baseCurrency))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("Expenses")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.format(expense, currencyCode: storage.baseCurrency))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
            }
            .frame(maxWidth: .infinity)

            VStack {
                Text("Net")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(CurrencyFormatter.format(income - expense, currencyCode: storage.baseCurrency))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    TransactionListView()
        .environment(StorageManager())
}
