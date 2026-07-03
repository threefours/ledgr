import SwiftUI

struct TransferView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    @State private var fromAccountId: UUID?
    @State private var toAccountId: UUID?
    @State private var amountString = ""
    @State private var note = ""
    @State private var date = Date()

    private var canSave: Bool {
        guard let from = fromAccountId, let to = toAccountId, from != to else { return false }
        guard let amount = Decimal(string: amountString), amount > 0 else { return false }
        return true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text(Currency.symbol(for: fromCurrency))
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)

                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 28, weight: .semibold, design: .rounded))
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Amount")
                }

                Section("From") {
                    ForEach(storage.accounts) { acc in
                        Button { fromAccountId = acc.id } label: {
                            accountRow(acc, selected: fromAccountId == acc.id)
                        }
                    }
                }

                Section("To") {
                    ForEach(storage.accounts.filter { $0.id != fromAccountId }) { acc in
                        Button { toAccountId = acc.id } label: {
                            accountRow(acc, selected: toAccountId == acc.id)
                        }
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                }
            }
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Transfer") { save() }.disabled(!canSave)
                }
            }
            .onAppear {
                fromAccountId = storage.accounts.first?.id
                toAccountId = storage.accounts.dropFirst().first?.id
            }
        }
    }

    private var fromCurrency: String {
        if let id = fromAccountId, let acc = storage.account(by: id) { return acc.currencyCode }
        return storage.baseCurrency
    }

    private func accountRow(_ acc: PaymentAccount, selected: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: acc.icon)
                .font(.system(size: 14, weight: .medium))
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

            let bal = storage.balance(forAccount: acc.id)
            Text(CurrencyFormatter.format(bal, currencyCode: acc.currencyCode))
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }

    private func save() {
        guard let amount = Decimal(string: amountString),
              let from = fromAccountId,
              let to = toAccountId else { return }

        storage.transfer(
            amount: amount,
            from: from,
            to: to,
            date: date,
            note: note.trimmingCharacters(in: .whitespaces)
        )
        dismiss()
    }
}

#Preview {
    TransferView()
        .environment(StorageManager())
}
