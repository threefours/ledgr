import SwiftUI

struct CurrencyPickerView: View {
    @Environment(StorageManager.self) private var storage

    var body: some View {
        List {
            Section {
                ForEach(Currency.available) { currency in
                    Button {
                        storage.setBaseCurrency(currency.code)
                    } label: {
                        HStack(spacing: 12) {
                            Text(currency.symbol)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.green)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(currency.code)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text(currency.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if storage.baseCurrency == currency.code {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Text("Choose the currency used to display all balances and summaries throughout the app.")
            }
        }
        .navigationTitle("Base Currency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        CurrencyPickerView()
            .environment(StorageManager())
    }
}
