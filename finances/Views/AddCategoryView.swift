import SwiftUI

struct AddCategoryView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    let editing: Category?
    let presetType: TransactionType?

    @State private var name = ""
    @State private var icon = "tag.fill"
    @State private var colorHex = "#4ECDC4"
    @State private var type: TransactionType = .expense

    private let iconOptions: [String] = [
        "fork.knife", "cup.and.saucer.fill", "cart.fill", "bag.fill",
        "car.fill", "bus.fill", "airplane", "fuelpump.fill",
        "film.fill", "gamecontroller.fill", "music.note", "sportscourt.fill",
        "heart.fill", "cross.case.fill", "pills.fill",
        "house.fill", "bolt.fill", "wifi", "phone.fill",
        "book.fill", "graduationcap.fill", "paintbrush.fill",
        "chart.line.uptrend.xyaxis", "banknote.fill", "creditcard.fill", "gift.fill",
        "star.fill", "ellipsis.circle.fill",
    ]

    private let colorOptions: [String] = [
        "#FF6B6B", "#FF8E8E", "#FFA07A", "#FFD93D",
        "#6BCB77", "#2ECC71", "#1ABC9C", "#4ECDC4",
        "#45B7D1", "#3498DB", "#5B86E5", "#9B59B6",
        "#DDA0DD", "#E74C3C", "#F39C12", "#95A5A6",
        "#B0BEC5", "#795548", "#607D8B", "#2C3E50",
    ]

    init(editing: Category? = nil, presetType: TransactionType? = nil) {
        self.editing = editing
        self.presetType = presetType
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Category name", text: $name)
                }

                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Text(t.label).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    .disabled(editing != nil)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(iconOptions, id: \.self) { ic in
                            Image(systemName: ic)
                                .font(.system(size: 16))
                                .foregroundStyle(icon == ic ? .white : .secondary)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(icon == ic ? Color(hex: colorHex) : Color(.systemGray6))
                                )
                                .onTapGesture { icon = ic }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: colorHex == hex ? 3 : 0)
                                )
                                .shadow(color: colorHex == hex ? Color(hex: hex).opacity(0.4) : .clear, radius: 4)
                                .onTapGesture { colorHex = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(editing == nil ? "New Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let editing {
                    name = editing.name
                    icon = editing.icon
                    colorHex = editing.colorHex
                    type = editing.type
                } else if let presetType {
                    type = presetType
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let editing {
            var updated = editing
            updated.name = trimmed
            updated.icon = icon
            updated.colorHex = colorHex
            storage.updateCategory(updated)
        } else {
            let cat = Category(name: trimmed, icon: icon, colorHex: colorHex, type: type)
            storage.addCategory(cat)
        }
        dismiss()
    }
}

#Preview {
    AddCategoryView()
        .environment(StorageManager())
}
