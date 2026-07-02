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
        "tag.fill", "cart.fill", "fork.knife", "cup.and.saucer.fill",
        "car.fill", "bus.fill", "fuelpump.fill", "airplane",
        "bag.fill", "tshirt.fill", "gift.fill", "cart.shopping",
        "film.fill", "gamecontroller.fill", "music.note", "sportscourt.fill",
        "heart.fill", "cross.case.fill", "pills.fill", "stethoscope",
        "doc.text.fill", "bolt.fill", "flame.fill", "drop.fill",
        "book.fill", "pencil", "paintbrush.fill", "graduationcap.fill",
        "banknote.fill", "creditcard.fill", "chart.line.uptrend.xyaxis", "dollarsign.circle.fill",
        "house.fill", "building.2.fill", "lock.fill", "wifi",
        "phone.fill", "envelope.fill", "camera.fill", "paintpalette.fill",
        "ellipsis.circle.fill", "star.fill", "flag.fill", "bookmark.fill",
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
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 14) {
                        ForEach(iconOptions, id: \.self) { ic in
                            Button {
                                icon = ic
                            } label: {
                                Image(systemName: ic)
                                    .font(.system(size: 18))
                                    .foregroundStyle(icon == ic ? .white : .secondary)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(icon == ic ? Color(hex: colorHex) : Color(.systemGray6))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 14) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Button {
                                colorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: colorHex == hex ? 3 : 0)
                                    )
                                    .shadow(color: colorHex == hex ? Color(hex: hex).opacity(0.4) : .clear, radius: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section("Preview") {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 56, height: 56)
                                Image(systemName: icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white)
                            }
                            Text(name.isEmpty ? "Category" : name)
                                .font(.headline)
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(editing == nil ? "New Category" : "Edit Category")
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
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let editing {
            var updated = editing
            updated.name = trimmed
            updated.icon = icon
            updated.colorHex = colorHex
            storage.updateCategory(updated)
        } else {
            let cat = Category(
                name: trimmed,
                icon: icon,
                colorHex: colorHex,
                type: type
            )
            storage.addCategory(cat)
        }
        dismiss()
    }
}

#Preview {
    AddCategoryView()
        .environment(StorageManager())
}
