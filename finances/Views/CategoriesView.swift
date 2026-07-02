import SwiftUI

struct CategoriesView: View {
    @Environment(StorageManager.self) private var storage
    @State private var showingAdd = false
    @State private var selectedType: TransactionType = .expense
    @State private var editingCategory: Category?

    private var filtered: [Category] {
        storage.categories(for: selectedType)
    }

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

                Section {
                    ForEach(filtered) { cat in
                        Button {
                            editingCategory = cat
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(cat.color)
                                        .frame(width: 36, height: 36)
                                    Image(systemName: cat.icon)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 14))
                                }

                                Text(cat.name)
                                    .foregroundStyle(.primary)

                                Spacer()

                                let count = storage.transactions.filter { $0.categoryId == cat.id }.count
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        for idx in offsets {
                            storage.deleteCategory(filtered[idx].id)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
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
                AddCategoryView(presetType: selectedType)
            }
            .sheet(item: $editingCategory) { cat in
                AddCategoryView(editing: cat)
            }
        }
    }
}

#Preview {
    CategoriesView()
        .environment(StorageManager())
}
