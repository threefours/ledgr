import SwiftUI

struct AddTransactionView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    let editing: Transaction?

    @State private var type: TransactionType = .expense
    @State private var amountString = ""
    @State private var selectedCategoryId: UUID?
    @State private var selectedAccountId: UUID?
    @State private var selectedCurrency: String = "USD"
    @State private var note = ""
    @State private var date = Date()

    init(editing: Transaction? = nil) {
        self.editing = editing
    }

    private var availableCategories: [Category] {
        storage.categories(for: type)
    }

    private var isEditing: Bool { editing != nil }

    var body: some View {
        NavigationStack {
            Form {
                // Type
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Text(t.label).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) {
                        selectedCategoryId = nil
                    }
                }

                // Amount
                Section("Amount") {
                    HStack {
                        Text(Currency.symbol(for: selectedCurrency))
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 30)

                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    }

                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(Currency.available) { c in
                            Text("\(c.code) — \(c.symbol) \(c.name)").tag(c.code)
                        }
                    }
                }

                // Category
                Section("Category") {
                    if availableCategories.isEmpty {
                        Text("No categories available for \(type.label.lowercased())")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableCategories) { cat in
                            Button {
                                selectedCategoryId = cat.id
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(cat.color.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: cat.icon)
                                            .foregroundStyle(cat.color)
                                            .font(.system(size: 13))
                                    }

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

                // Account
                Section("Account") {
                    if storage.accounts.isEmpty {
                        Text("No accounts available. Add one in the Accounts tab.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(storage.accounts) { acc in
                            Button {
                                selectedAccountId = acc.id
                            } label: {
                                HStack(spacing: 10) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: acc.icon)
                                            .foregroundStyle(.blue)
                                            .font(.system(size: 13))
                                    }

                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(acc.name)
                                            .foregroundStyle(.primary)
                                        Text(acc.type.label)
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

                // Details
                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle(isEditing ? "Edit Transaction" : "New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear {
                if let editing {
                    // Populate fields from existing transaction
                    type = editing.type
                    amountString = NSDecimalNumber(decimal: editing.amount).stringValue
                    selectedCategoryId = editing.categoryId
                    selectedAccountId = editing.accountId
                    selectedCurrency = editing.currencyCode
                    note = editing.note
                    date = editing.date
                } else {
                    selectedCurrency = storage.baseCurrency
                    if selectedAccountId == nil {
                        selectedAccountId = storage.accounts.first?.id
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        guard let amount = Decimal(string: amountString), amount > 0 else { return false }
        guard selectedCategoryId != nil else { return false }
        guard selectedAccountId != nil else { return false }
        return true
    }

    private func save() {
        guard let amount = Decimal(string: amountString),
              let catId = selectedCategoryId,
              let accId = selectedAccountId else { return }

        if let editing {
            var updated = editing
            updated.amount = amount
            updated.type = type
            updated.categoryId = catId
            updated.accountId = accId
            updated.currencyCode = selectedCurrency
            updated.note = note.trimmingCharacters(in: .whitespaces)
            updated.date = date
            storage.updateTransaction(updated)
        } else {
            let tx = Transaction(
                amount: amount,
                type: type,
                categoryId: catId,
                accountId: accId,
                currencyCode: selectedCurrency,
                note: note.trimmingCharacters(in: .whitespaces),
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
