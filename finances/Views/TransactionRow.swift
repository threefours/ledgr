import SwiftUI

struct TransactionRow: View {
    @Environment(StorageManager.self) private var storage
    let transaction: Transaction

    var body: some View {
        let category = storage.category(by: transaction.categoryId)
        let account = storage.account(by: transaction.accountId)

        HStack(spacing: 12) {
            ZStack {
                Image(systemName: category?.icon ?? "questionmark")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(category?.color ?? .gray)
                    .frame(width: 36, height: 36)
                    .background((category?.color ?? .gray).opacity(0.12))
                    .clipShape(Circle())

                if transaction.isTransfer {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 16, height: 16)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .offset(x: 13, y: 13)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category?.name ?? "Unknown")
                    .font(.subheadline.weight(.medium))

                if transaction.type == .transfer, let destId = transaction.destAccountId,
                   let destAcc = storage.account(by: destId) {
                    HStack(spacing: 4) {
                        Text(account?.name ?? "?")
                        Image(systemName: "arrow.right")
                            .font(.system(size: 8, weight: .bold))
                        Text(destAcc.name)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 4) {
                        if let account {
                            Text(account.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !transaction.note.isEmpty {
                            Text((account != nil ? "· " : "") + transaction.note)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if transaction.type == .transfer {
                    Text(CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.blue)
                } else {
                    let sign = transaction.type == .income ? "+" : "\u{2212}"
                    Text("\(sign)\(CurrencyFormatter.format(transaction.amount, currencyCode: transaction.currencyCode))")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(transaction.type == .income ? .green : .red)
                }

                Text(transaction.date, format: .dateTime.month(.abbreviated).day())
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    TransactionRow(transaction: Transaction(
        amount: 42,
        type: .expense,
        categoryId: UUID(),
        accountId: UUID(),
        currencyCode: "USD"
    ))
    .environment(StorageManager())
}
