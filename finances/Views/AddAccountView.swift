import SwiftUI

struct AddAccountView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    let editing: PaymentAccount?

    @State private var name = ""
    @State private var type: AccountType = .bankCard
    @State private var currencyCode = "USD"

    private let iconOptions: [String] = [
        "creditcard", "banknote", "building.columns", "bitcoinsign.circle",
        "wallet.bifold", "lock.aisle", "giftcard", "dollarsign.circle",
        "eurosign.circle", "sterlingsign.circle", "yensign.circle",
        "bitcoinsign.circle.fill",
    ]

    init(editing: PaymentAccount? = nil) {
        self.editing = editing
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Account name", text: $name)
                }

                Section("Type") {
                    ForEach(AccountType.allCases, id: \.self) { t in
                        Button { type = t } label: {
                            HStack(spacing: 10) {
                                Image(systemName: t.icon)
                                    .font(.system(size: 15))
                                    .foregroundStyle(.blue)
                                    .frame(width: 28, height: 28)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 7))

                                Text(t.label)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if type == t {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }

                Section("Currency") {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(Currency.available) { c in
                            Text("\(c.symbol)  \(c.code)  ·  \(c.name)").tag(c.code)
                        }
                    }
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { ic in
                            Button { } label: {
                                Image(systemName: ic)
                                    .font(.system(size: 20))
                                    .foregroundStyle(type.icon == ic ? .white : .secondary)
                                    .frame(width: 38, height: 38)
                                    .background(
                                        RoundedRectangle(cornerRadius: 9)
                                            .fill(type.icon == ic ? Color.blue : Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(.plain)
                            .onTapGesture {
                                type = AccountType.allCases.first { $0.icon == ic } ?? type
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(editing == nil ? "New Account" : "Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let editing {
                    name = editing.name
                    type = editing.type
                    currencyCode = editing.currencyCode
                } else {
                    currencyCode = storage.baseCurrency
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let editing {
            var updated = editing
            updated.name = trimmed
            updated.type = type
            updated.currencyCode = currencyCode
            updated.icon = type.icon
            storage.updateAccount(updated)
        } else {
            let acc = PaymentAccount(name: trimmed, type: type, currencyCode: currencyCode)
            storage.addAccount(acc)
        }
        dismiss()
    }
}

#Preview {
    AddAccountView()
        .environment(StorageManager())
}
