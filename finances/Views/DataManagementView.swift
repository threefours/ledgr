import SwiftUI
import UniformTypeIdentifiers

struct DataManagementView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    @State private var showExporter = false
    @State private var showImporter = false
    @State private var exportData: Data?
    @State private var importError: String?
    @State private var showImportConfirm = false
    @State private var pendingImportData: Data?
    @State private var importPreview: ImportPreview?

    struct ImportPreview {
        let transactions: Int
        let categories: Int
        let accounts: Int
        let baseCurrency: String
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Export
                    Button {
                        prepareExport()
                    } label: {
                        Label("Export to File", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.plain)

                    // Import
                    Button {
                        showImporter = true
                    } label: {
                        Label("Import from File", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Data Transfer")
                } footer: {
                    Text("Export saves all your data as a JSON file. Import restores data from a previously exported file.")
                }

                Section {
                    Text("Export format: JSON")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Compatible with Ledgr backups")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Import & Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: LedgrDocument(data: exportData ?? Data()),
                contentType: .json,
                defaultFilename: "ledgr_backup"
            ) { result in
                if case .failure(let error) = result {
                    importError = error.localizedDescription
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        if let data = try? Data(contentsOf: url) {
                            if let preview = validateImport(data) {
                                pendingImportData = data
                                importPreview = preview
                                showImportConfirm = true
                            } else {
                                importError = "Invalid Ledgr backup file."
                            }
                        }
                    }
                case .failure(let error):
                    importError = error.localizedDescription
                }
            }
            .alert("Import Error", isPresented: .constant(importError != nil)) {
                Button("OK") { importError = nil }
            } message: {
                Text(importError ?? "")
            }
            .confirmationDialog(
                "Import Data?",
                isPresented: $showImportConfirm,
                titleVisibility: .visible
            ) {
                Button("Replace All Data", role: .destructive) {
                    performImport()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                if let preview = importPreview {
                    Text("This will replace all current data with:\n• \(preview.transactions) transactions\n• \(preview.categories) categories\n• \(preview.accounts) accounts\n• Base currency: \(preview.baseCurrency)\n\nThis cannot be undone.")
                }
            }
        }
    }

    // MARK: - Export

    private func prepareExport() {
        guard let data = storage.exportData() else { return }
        // Pretty-print JSON
        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]) {
            exportData = pretty
        } else {
            exportData = data
        }
        showExporter = true
    }

    // MARK: - Import

    private func validateImport(_ data: Data) -> ImportPreview? {
        guard let decoded = try? JSONDecoder().decode(AppData.self, from: data) else {
            return nil
        }
        return ImportPreview(
            transactions: decoded.transactions.count,
            categories: decoded.categories.count,
            accounts: decoded.accounts.count,
            baseCurrency: decoded.baseCurrency
        )
    }

    private func performImport() {
        guard let data = pendingImportData else { return }
        do {
            try storage.importData(from: data)
        } catch {
            importError = error.localizedDescription
        }
        pendingImportData = nil
        importPreview = nil
    }
}

// MARK: - FileDocument for Export

struct LedgrDocument: FileDocument {
    let data: Data

    static var readableContentTypes: [UTType] { [.json] }

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
