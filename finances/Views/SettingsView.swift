import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showResetConfirm = false
    @State private var showExport = false

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
                        showExport = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
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
            .sheet(isPresented: $showExport) {
                ExportView()
            }
        }
    }

    private func resetData() {
        storage.transactions = []
        storage.categories = Category.allDefaults
        storage.accounts = PaymentAccount.defaults
        storage.baseCurrency = "USD"
        storage.save()
    }
}

// MARK: - Export View

struct ExportView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    @State private var exportText = ""
    @State private var copied = false

    var body: some View {
        NavigationStack {
            ScrollView {
                Text(exportText)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .textSelection(.enabled)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        UIPasteboard.general.string = exportText
                        copied = true
                    } label: {
                        Text(copied ? "Copied!" : "Copy")
                    }
                    .disabled(copied)
                }
            }
            .onAppear {
                generateExport()
            }
        }
    }

    private func generateExport() {
        var lines: [String] = []
        lines.append("Ledgr Export")
        lines.append("Date: \(Date().formatted())")
        lines.append("Base Currency: \(storage.baseCurrency)")
        lines.append("")
        lines.append("--- Transactions ---")
        lines.append("Date,Type,Category,Account,Amount,Currency,Note")

        for tx in storage.transactions {
            let catName = storage.category(by: tx.categoryId)?.name ?? "Unknown"
            let accName = storage.account(by: tx.accountId)?.name ?? "Unknown"
            let dateStr = tx.date.formatted(.dateTime.year().month().day())
            lines.append("\(dateStr),\(tx.type.rawValue),\(catName),\(accName),\(tx.amount),\(tx.currencyCode),\(tx.note)")
        }

        lines.append("")
        lines.append("--- Categories ---")
        for cat in storage.categories {
            lines.append("\(cat.name) [\(cat.type.rawValue)]")
        }

        lines.append("")
        lines.append("--- Accounts ---")
        for acc in storage.accounts {
            lines.append("\(acc.name) (\(acc.type.label)) — \(acc.currencyCode)")
        }

        exportText = lines.joined(separator: "\n")
    }
}

#Preview {
    SettingsView()
        .environment(StorageManager())
}
