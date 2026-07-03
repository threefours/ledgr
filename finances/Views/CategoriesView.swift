import SwiftUI

struct CategoriesView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showingAdd = false
    @State private var selectedType: TransactionType = .expense
    @State private var editingCategory: Category?

    private var filtered: [Category] { storage.categories(for: selectedType) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Text(t.label).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if filtered.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 32))
                                .foregroundStyle(.tertiary)
                            Text("No categories for \(selectedType.label.lowercased())")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                } else {
                    Section {
                        ForEach(filtered) { cat in
                            Button { editingCategory = cat } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(cat.color)
                                        .frame(width: 34, height: 34)
                                        .background(cat.color.opacity(0.12))
                                        .clipShape(Circle())

                                    Text(cat.name)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(.primary)

                                    Spacer()

                                    let count = storage.transactions.filter { $0.categoryId == cat.id }.count
                                    Text("\(count)")
                                        .font(.callout)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color(.systemGray6))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .onDelete { offsets in
                            for idx in offsets { storage.deleteCategory(filtered[idx].id) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) { AddCategoryView(presetType: selectedType) }
            .sheet(item: $editingCategory) { cat in AddCategoryView(editing: cat) }
        }
    }
}

#Preview {
    CategoriesView()
        .environment(StorageManager())
}
