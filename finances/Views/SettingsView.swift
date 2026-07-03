import SwiftUI

struct SettingsView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showResetConfirm = false
    @State private var showDataManagement = false

    var body: some View {
        NavigationStack {
            List {
                // Base Currency
                Section {
                    NavigationLink {
                        CurrencyPickerView()
                    } label: {
                        HStack {
                            Text("Base Currency")
                                .foregroundStyle(.primary)
                            Spacer()
                            if let cur = Currency.available.first(where: { $0.code == storage.baseCurrency }) {
                                Text("\(cur.symbol)  \(cur.code)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } footer: {
                    Text("All balances and reports will use this currency for display.")
                }

                // Stats
                Section("Statistics") {
                    let txCount = storage.transactions.count
                    let catCount = storage.categories.count
                    let accCount = storage.accounts.count

                    statRow(icon: "list.bullet", label: "Transactions", value: "\(txCount)")
                    statRow(icon: "square.grid.2x2", label: "Categories", value: "\(catCount)")
                    statRow(icon: "creditcard", label: "Accounts", value: "\(accCount)")
                }

                // Data Management
                Section("Data") {
                    Button {
                        showDataManagement = true
                    } label: {
                        Label("Import & Export", systemImage: "arrow.triangle.swap")
                    }

                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Ledgr")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Reset All Data?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { resetData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all transactions, categories, and accounts. This action cannot be undone.")
            }
            .sheet(isPresented: $showDataManagement) {
                DataManagementView()
            }
        }
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Label(label, systemImage: icon)
            Spacer()
            Text(value)
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private func resetData() {
        storage.transactions = []
        storage.categories = Category.allDefaults
        storage.accounts = PaymentAccount.defaults
        storage.baseCurrency = "USD"
        storage.initialBalance = 0
        storage.save()
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}

#Preview {
    SettingsView()
        .environment(StorageManager())
}
