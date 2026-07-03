import SwiftUI

struct AddTransactionView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    let editing: Transaction?

    @State private var type: TransactionType = .expense
    @State private var amountString = ""
    @State private var selectedCategoryId: UUID?
    @State private var selectedAccountId: UUID?
    @State private var note = ""
    @State private var date = Date()
    @State private var isPopulating = false

    init(editing: Transaction? = nil) {
        self.editing = editing
    }

    private var availableCategories: [Category] { storage.categories(for: type) }
    private var isEditing: Bool { editing != nil }

    private var selectedAccountCurrency: String {
        if let selectedAccountId, let acc = storage.account(by: selectedAccountId) {
            return acc.currencyCode
        }
        return storage.baseCurrency
    }

    var body: some View {
        NavigationStack {
            Form {
                typeSection
                amountSection
                categorySection
                accountSection
                detailsSection
            }
            .navigationTitle(isEditing ? "Edit Transaction" : "New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") { save() }.disabled(!canSave)
                }
            }
            .onAppear { populateFields() }
        }
    }

    // MARK: - Sections

    private var typeSection: some View {
        Section {
            Picker("Type", selection: $type) {
                ForEach(TransactionType.allCases.filter { $0 != .transfer }, id: \.self) { t in Text(t.label).tag(t) }
            }
            .pickerStyle(.segmented)
            .onChange(of: type) { _, _ in
                guard !isPopulating else { return }
                selectedCategoryId = nil
            }
        }
    }

    private var amountSection: some View {
        Section {
            HStack {
                Text(Currency.symbol(for: selectedAccountCurrency))
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 28)

                TextField("0.00", text: $amountString)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
            }
            .padding(.vertical, 4)

            if let acc = selectedAccountId.flatMap({ storage.account(by: $0) }) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Text("Currency: \(acc.currencyCode) — determined by account")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Amount")
        }
    }

    private var categorySection: some View {
        Section("Category") {
            if availableCategories.isEmpty {
                HStack {
                    Image(systemName: "square.grid.2x2")
                        .foregroundStyle(.tertiary)
                    Text("No categories — add one in the Categories tab")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(availableCategories) { cat in
                    Button { selectedCategoryId = cat.id } label: {
                        HStack(spacing: 10) {
                            Image(systemName: cat.icon)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(cat.color)
                                .frame(width: 30, height: 30)
                                .background(cat.color.opacity(0.12))
                                .clipShape(Circle())

                            Text(cat.name)
                                .foregroundStyle(.primary)

                            Spacer()

                            if selectedCategoryId == cat.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
        }
    }

    private var accountSection: some View {
        Section("Account") {
            if storage.accounts.isEmpty {
                HStack {
                    Image(systemName: "creditcard")
                        .foregroundStyle(.tertiary)
                    Text("No accounts — add one in the Accounts tab")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(storage.accounts) { acc in
                    Button { selectedAccountId = acc.id } label: {
                        HStack(spacing: 10) {
                            Image(systemName: acc.icon)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.blue)
                                .frame(width: 30, height: 30)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 7))

                            VStack(alignment: .leading, spacing: 1) {
                                Text(acc.name)
                                    .foregroundStyle(.primary)
                                Text("\(acc.type.label) · \(acc.currencyCode)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if selectedAccountId == acc.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            }
        }
    }

    private var detailsSection: some View {
        Section("Details") {
            DatePicker("Date", selection: $date, displayedComponents: .date)
            TextField("Note (optional)", text: $note)
        }
    }

    // MARK: - Logic

    private var canSave: Bool {
        guard let amount = Decimal(string: amountString), amount > 0 else { return false }
        guard selectedCategoryId != nil else { return false }
        guard selectedAccountId != nil else { return false }
        return true
    }

    private func populateFields() {
        isPopulating = true
        if let editing {
            type = editing.type
            amountString = NSDecimalNumber(decimal: editing.amount).stringValue
            selectedCategoryId = editing.categoryId
            selectedAccountId = editing.accountId
            note = editing.note
            date = editing.date
        } else {
            if selectedAccountId == nil { selectedAccountId = storage.accounts.first?.id }
        }
        isPopulating = false
    }

    private func save() {
        guard let amount = Decimal(string: amountString),
              let catId = selectedCategoryId,
              let accId = selectedAccountId else { return }

        let currency = storage.account(by: accId)?.currencyCode ?? storage.baseCurrency

        if let editing {
            var updated = editing
            updated.amount = amount
            updated.type = type
            updated.categoryId = catId
            updated.accountId = accId
            updated.currencyCode = currency
            updated.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.date = date
            storage.updateTransaction(updated)
        } else {
            let tx = Transaction(
                amount: amount,
                type: type,
                categoryId: catId,
                accountId: accId,
                currencyCode: currency,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                date: date
            )
            storage.addTransaction(tx)
        }
        dismiss()
    }
}

#Preview {
    AddTransactionView()
        .environment(StorageManager())
}
