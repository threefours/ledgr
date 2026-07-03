# features

everything ledgr can do right now.

## dashboard

- **balance card** — total balance at the top, green when positive, red when negative. shows income and expense for the current month below
- **spending by category** — top categories with progress bars, see where your money goes at a glance
- **accounts overview** — all your accounts with their current balances, directly on the dashboard
- **recent transactions** — last two transactions for quick reference, tap to edit

## transactions

- **add income or expense** — pick type, amount, category, account, date, and an optional note
- **edit and delete** — tap any transaction to edit, swipe to delete
- **search** — search by category name or note text
- **filter by type** — all, income only, or expenses only
- **grouped by date** — transactions grouped under date headers, newest first
- **currency follows account** — transaction currency is determined by the selected account, no need to pick separately

## transfers

- **move money between accounts** — pick source and destination, enter amount, add a date and note
- **transfer badge** — transfers are highlighted in blue with a `from → to` label in the transaction list
- **edit transfers** — tap a transfer to change accounts, amount, or date
- **transfers are a native transaction type** — separate from income and expense, clean in reports

## accounts

- **multiple account types** — cash, bank card, bank account, crypto wallet, savings, or custom
- **per-account currency** — each account has its own currency (rub, usd, btc, etc.)
- **custom icon** — pick any icon for each account, independent of the account type
- **per-account balance** — see how much is on each account, transfers affect both source and destination
- **delete with confirmation** — warns how many linked transactions will be removed

## categories

- **income and expense categories** — separate sets, switch between them in the picker
- **customize everything** — name, icon (28 choices), color (20 choices)
- **transaction count** — see how many transactions use each category at a glance
- **default set included** — food, transport, shopping, entertainment, health, bills, education, transfer, opening balance, salary, freelance, investments, gifts, and more
- **delete with cascade** — deleting a category removes all linked transactions, with a confirmation dialog

## onboarding

- **four-step setup** — welcome, base currency, accounts, starting balance
- **starting balance as a real transaction** — entered amount creates an actual income transaction on the chosen account, not an abstract number
- **account setup during onboarding** — add or remove accounts before you even start

## currencies

- **13 currencies** — rub, usd, eur, gbp, chf, jpy, cny, aed, try, inr, brl, btc, eth
- **popular subset** — rub, usd, eur, gbp, btc for quick pickers
- **base currency** — set in settings or during onboarding, used for all summaries and the dashboard
- **locale-safe amount input** — comma or dot, both work regardless of your device region

## data management

- **export to json** — save all your data (transactions, categories, accounts, settings) as a `.json` file
- **import from json** — restore from a backup, with a preview of what will be imported
- **reset all data** — wipes everything and restarts onboarding, with confirmation

## settings

- **base currency picker** — beautiful list with symbol, code, and name on a separate screen
- **statistics** — count of transactions, categories, and accounts
- **import & export** — dedicated screen with clear options
- **about section** — app name and version

## under the hood

- **zero dependencies** — pure swiftui, no third-party packages
- **local storage** — single json file, no internet, no accounts, no cloud
- **atomic saves** — writes to a temp file first, then replaces the original to prevent corruption
- **`@observable`** — swift observation framework for reactive ui updates
- **dark mode** — follows system setting automatically
- **ios 18+** — uses the latest apis and design patterns
