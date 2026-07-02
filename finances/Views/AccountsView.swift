import SwiftUI

struct AccountsView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showingAdd = false
    @State private var editingAccount: PaymentAccount?

    var body: some View {
        NavigationStack {
            List {
                if storage.accounts.isEmpty {
                    ContentUnavailableView(
                        "No Accounts",
                        systemImage: "creditcard",
                        description: Text("Add a payment account to track your money.")
                    )
                }

                ForEach(storage.accounts) { acc in
                    Button {
                        editingAccount = acc
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: acc.icon)
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 18))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(acc.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                HStack(spacing: 4) {
                                    Text(acc.type.label)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("·")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(acc.currencyCode)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            let bal = storage.balance(forAccount: acc.id)
                            Text(CurrencyFormatter.format(bal, currencyCode: acc.currencyCode))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(bal >= 0 ? .green : .red)
                        }
                    }
                }
                .onDelete { offsets in
                    for idx in offsets {
                        storage.deleteAccount(storage.accounts[idx].id)
                    }
                }
            }
            .navigationTitle("Accounts")
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
                AddAccountView()
            }
            .sheet(item: $editingAccount) { acc in
                AddAccountView(editing: acc)
            }
        }
    }
}

#Preview {
    AccountsView()
        .environment(StorageManager())
}
