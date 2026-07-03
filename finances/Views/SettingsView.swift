import SwiftUI

struct SettingsView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showResetConfirm = false
    @State private var showDataManagement = false

    var body: some View {
        NavigationStack {
            List {
                // Base Currency
                Section("Base Currency") {
                    Picker("Currency", selection: Binding(
                        get: { storage.baseCurrency },
                        set: { storage.setBaseCurrency($0) }
                    )) {
                        ForEach(Currency.available) { c in
                            HStack {
                                Text(c.symbol)
                                    .frame(width: 24)
                                Text(c.code)
                                    .fontWeight(.medium)
                                Text("—")
                                Text(c.name)
                            }
                            .tag(c.code)
                        }
                    }
                    .labelsHidden()
                }

                // Stats
                Section("Statistics") {
                    let txCount = storage.transactions.count
                    let catCount = storage.categories.count
                    let accCount = storage.accounts.count

                    HStack {
                        Label("Transactions", systemImage: "list.bullet")
                        Spacer()
                        Text("\(txCount)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Categories", systemImage: "square.grid.2x2")
                        Spacer()
                        Text("\(catCount)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Accounts", systemImage: "creditcard")
                        Spacer()
                        Text("\(accCount)")
                            .foregroundStyle(.secondary)
                    }
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
                Button("Reset", role: .destructive) {
                    resetData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all transactions, categories, and accounts. This action cannot be undone.")
            }
            .sheet(isPresented: $showDataManagement) {
                DataManagementView()
            }
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
