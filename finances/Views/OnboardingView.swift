import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    @Environment(StorageManager.self) private var storage
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0
    @State private var balanceString = ""
    @State private var balanceCurrency = "USD"
    @State private var onboardingAccounts: [OnboardingAccount] = [
        OnboardingAccount(name: "Cash", type: .cash, currencyCode: "USD"),
        OnboardingAccount(name: "Main Card", type: .bankCard, currencyCode: "USD"),
    ]
    @State private var showingAddAccount = false
    @FocusState private var balanceFocused: Bool
    @State private var selectedBalanceAccountId: UUID?

    private let totalPages = 4

    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Capsule()
                        .fill(i <= currentPage ? Color.green : Color(.systemGray4))
                        .frame(width: i == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.top, 20)

            // Pages — currency first, then accounts, then balance
            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                currencyPage.tag(1)
                accountsPage.tag(2)
                balancePage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom buttons
            HStack {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation { currentPage -= 1 }
                    }
                    .foregroundStyle(.secondary)
                } else {
                    Spacer()
                }

                Spacer()

                Button(currentPage == totalPages - 1 ? "Get Started" : "Next") {
                    withAnimation {
                        if currentPage < totalPages - 1 {
                            currentPage += 1
                        } else {
                            finishOnboarding()
                        }
                    }
                }
                .fontWeight(.semibold)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .sheet(isPresented: $showingAddAccount) {
            OnboardingAddAccountView(defaultCurrency: storage.baseCurrency) { account in
                onboardingAccounts.append(account)
            }
        }
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.green)
            }

            Text("Welcome to Ledgr")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Your simple and beautiful\npersonal finance tracker")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Page 3: Initial Balance

    private var selectedAccountCurrency: String {
        if let id = selectedBalanceAccountId,
           let acc = onboardingAccounts.first(where: { $0.id == id }) {
            return acc.currencyCode
        }
        return onboardingAccounts.first?.currencyCode ?? "USD"
    }

    private var balancePage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "banknote.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)
            }

            Text("Starting Balance")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Enter your current balance.\nIt will be credited to the selected account.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 16) {
                // Amount
                HStack(spacing: 8) {
                    Text(Currency.symbol(for: selectedAccountCurrency))
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("0.00", text: $balanceString)
                        .keyboardType(.decimalPad)
                        .focused($balanceFocused)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 200)
                }

                Divider()

                // Account picker
                VStack(spacing: 8) {
                    Text("Credited to")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(onboardingAccounts) { acc in
                        Button {
                            selectedBalanceAccountId = acc.id
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: acc.type.icon)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.blue)
                                    .frame(width: 28, height: 28)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 7))

                                Text(acc.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)

                                Text("· \(acc.currencyCode)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                if selectedBalanceAccountId == acc.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedBalanceAccountId == acc.id
                                        ? Color.green.opacity(0.08)
                                        : Color(.systemGray6))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .padding(.horizontal, 32)
        .contentShape(Rectangle())
        .onTapGesture { balanceFocused = false }
        .onAppear {
            if selectedBalanceAccountId == nil {
                selectedBalanceAccountId = onboardingAccounts.first?.id
            }
        }
    }

    // MARK: - Page 2: Accounts

    private var accountsPage: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "creditcard.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.purple)
            }

            Text("Your Accounts")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Set up your payment accounts.\nYou can add more later.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(onboardingAccounts) { acc in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: acc.type.icon)
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 14))
                            }

                            VStack(alignment: .leading, spacing: 1) {
                                Text(acc.name)
                                    .font(.subheadline.weight(.medium))
                                Text("\(acc.type.label) · \(acc.currencyCode)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .onDelete { offsets in
                        onboardingAccounts.remove(atOffsets: offsets)
                    }

                    Button {
                        showingAddAccount = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Account")
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .frame(maxHeight: 280)

            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            // Sync default accounts to the base currency chosen on previous page
            let cur = storage.baseCurrency
            onboardingAccounts = onboardingAccounts.map { acc in
                var updated = acc
                updated.currencyCode = cur
                return updated
            }
        }
    }

    // MARK: - Page 4: Base Currency

    private var currencyPage: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.orange)
            }

            Text("Base Currency")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("Choose your default currency.\nYou can change it anytime in Settings.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 0) {
                ForEach(Currency.popular) { currency in
                    Button {
                        storage.setBaseCurrency(currency.code)
                    } label: {
                        HStack {
                            Text(currency.symbol)
                                .font(.title3)
                                .frame(width: 32)

                            Text(currency.code)
                                .font(.body.weight(.medium))

                            Text(currency.name)
                                .font(.body)
                                .foregroundStyle(.secondary)

                            Spacer()

                            if storage.baseCurrency == currency.code {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)

                    if currency.code != Currency.popular.last?.code {
                        Divider().padding(.leading, 48)
                    }
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Finish

    private func finishOnboarding() {
        // Save accounts — preserve UUID so balance transaction links correctly
        storage.accounts = onboardingAccounts.map {
            PaymentAccount(
                id: $0.id,
                name: $0.name,
                type: $0.type,
                currencyCode: $0.currencyCode
            )
        }

        // Create initial balance transaction for the selected account
        if let balance = Decimal(string: balanceString), balance > 0,
           let accountId = selectedBalanceAccountId,
           let account = onboardingAccounts.first(where: { $0.id == accountId }),
           let cat = storage.categories.first(where: { $0.name == "Opening Balance" && $0.type == .income }) {

            let tx = Transaction(
                amount: balance,
                type: .income,
                categoryId: cat.id,
                accountId: accountId,
                currencyCode: account.currencyCode,
                note: "Initial balance",
                date: Date()
            )
            storage.addTransaction(tx)
        }

        storage.save()

        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

// MARK: - Onboarding Account Model

struct OnboardingAccount: Identifiable {
    let id = UUID()
    var name: String
    var type: AccountType
    var currencyCode: String
}

// MARK: - Quick Add Account Sheet

struct OnboardingAddAccountView: View {
    @Environment(\.dismiss) private var dismiss

    let defaultCurrency: String
    let onAdd: (OnboardingAccount) -> Void

    @State private var name = ""
    @State private var type: AccountType = .bankCard
    @State private var currencyCode: String

    init(defaultCurrency: String = "USD", onAdd: @escaping (OnboardingAccount) -> Void) {
        self.defaultCurrency = defaultCurrency
        self.onAdd = onAdd
        self._currencyCode = State(initialValue: defaultCurrency)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Account name", text: $name)
                }

                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(AccountType.allCases, id: \.self) { t in
                            HStack {
                                Image(systemName: t.icon)
                                Text(t.label)
                            }
                            .tag(t)
                        }
                    }
                }

                Section("Currency") {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(Currency.available) { c in
                            Text("\(c.code) — \(c.symbol)").tag(c.code)
                        }
                    }
                }
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onAdd(OnboardingAccount(name: trimmed, type: type, currencyCode: currencyCode))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(StorageManager())
}
