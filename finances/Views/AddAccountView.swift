import SwiftUI

struct AddAccountView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    let editing: PaymentAccount?

    @State private var name = ""
    @State private var type: AccountType = .bankCard
    @State private var currencyCode = "USD"
    @State private var customIcon: String?

    private let iconOptions: [String] = [
        "creditcard", "banknote", "building.columns", "bitcoinsign.circle",
        "wallet.bifold", "lock.aisle", "giftcard", "dollarsign.circle",
        "eurosign.circle", "sterlingsign.circle", "yensign.circle",
        "bitcoinsign.circle.fill", "ethereum.circle",
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
                        Button {
                            type = t
                        } label: {
                            HStack {
                                Image(systemName: t.icon)
                                    .foregroundStyle(.blue)
                                    .frame(width: 24)

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
                            Text("\(c.code) — \(c.symbol) \(c.name)").tag(c.code)
                        }
                    }
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { ic in
                            Button {
                                customIcon = ic
                            } label: {
                                Image(systemName: ic)
                                    .font(.system(size: 22))
                                    .foregroundStyle((customIcon ?? type.icon) == ic ? .white : .secondary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill((customIcon ?? type.icon) == ic ? Color.blue : Color.clear)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Preview") {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 64, height: 64)
                                Image(systemName: customIcon ?? type.icon)
                                    .font(.system(size: 28))
                                    .foregroundStyle(.blue)
                            }
                            Text(name.isEmpty ? "Account" : name)
                                .font(.headline)
                            Text(type.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(editing == nil ? "New Account" : "Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
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
                    customIcon = editing.icon
                } else {
                    currencyCode = storage.baseCurrency
                }
            }
            .onChange(of: type) {
                if customIcon == nil || iconOptions.contains(customIcon!) {
                    // Keep custom if it was explicitly picked
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
            updated.icon = customIcon ?? type.icon
            storage.updateAccount(updated)
        } else {
            let acc = PaymentAccount(
                name: trimmed,
                type: type,
                currencyCode: currencyCode,
                icon: customIcon
            )
            storage.addAccount(acc)
        }
        dismiss()
    }
}

#Preview {
    AddAccountView()
        .environment(StorageManager())
}
