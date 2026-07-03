import SwiftUI

struct AccountsView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showingAdd = false
    @State private var showingTransfer = false
    @State private var editingAccount: PaymentAccount?
    @State private var accountToDelete: PaymentAccount?

    var body: some View {
        NavigationStack {
            List {
                if storage.accounts.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "creditcard")
                                .font(.system(size: 36))
                                .foregroundStyle(.tertiary)
                            Text("No Accounts")
                                .font(.headline)
                            Text("Add a payment account to track your money.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                } else {
                    Section {
                        ForEach(storage.accounts) { acc in
                            Button { editingAccount = acc } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: acc.icon)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(.blue)
                                        .frame(width: 38, height: 38)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 9))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(acc.name)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.primary)
                                        HStack(spacing: 4) {
                                            Text(acc.type.label)
                                            Text("·")
                                            Text(acc.currencyCode)
                                        }
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    let bal = storage.balance(forAccount: acc.id)
                                    Text(CurrencyFormatter.format(bal, currencyCode: acc.currencyCode))
                                        .font(.subheadline.weight(.bold))
                                        .foregroundStyle(bal >= 0 ? .green : .red)
                                }
                            }
                        }
                        .onDelete { offsets in
                            if let idx = offsets.first {
                                accountToDelete = storage.accounts[idx]
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 4) {
                        if storage.accounts.count >= 2 {
                            Button { showingTransfer = true } label: {
                                Image(systemName: "arrow.left.arrow.right.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                            }
                        }
                        Button { showingAdd = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAdd) { AddAccountView() }
            .sheet(isPresented: $showingTransfer) { TransferView() }
            .sheet(item: $editingAccount) { acc in AddAccountView(editing: acc) }
            .confirmationDialog(
                "Delete Account?",
                isPresented: Binding(
                    get: { accountToDelete != nil },
                    set: { if !$0 { accountToDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete Account & Transactions", role: .destructive) {
                    if let acc = accountToDelete {
                        storage.deleteAccount(acc.id)
                    }
                    accountToDelete = nil
                }
                Button("Cancel", role: .cancel) { accountToDelete = nil }
            } message: {
                if let acc = accountToDelete {
                    let txCount = storage.transactions(forAccount: acc.id).count
                    Text("This will permanently delete \"\(acc.name)\" and all \(txCount) linked transactions. This action cannot be undone.")
                }
            }
        }
    }
}

#Preview {
    AccountsView()
        .environment(StorageManager())
}
