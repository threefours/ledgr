# ledgr

a simple and beautiful personal finance tracker for ios. no fluff, just what you need.

## what it does

- **income and expenses** — add transactions in a couple of taps, pick a category and an account
- **accounts** — cash, cards, crypto, savings — whatever. each has its own currency and icon
- **transfers between accounts** — move money between cards or stash it in savings
- **categories** — customize them: color, icon, type. comes with a solid default set
- **clean dashboard** — see your balance at a glance, top spending categories, how your accounts are doing
- **import and export** — save all your data to a json file or restore from a backup
- **onboarding** — set up your currency, accounts, and starting balance in under a minute on first launch
- **13 currencies** — rubles, dollars, euros, bitcoin, ethereum, and more
- **dark mode** — works out of the box, follows your system setting

## what it doesn't do

- ads
- budgets or analytics charts (for now)
- sign-ups or cloud accounts
- subscriptions

your money, your data. everything lives in a local json file.

## how to run

open `finances.xcodeproj` in xcode, pick a simulator or your iphone, hit run. that's it.

requires xcode 16+ and ios 18+.

## project layout

```
finances/
├── models/
│   ├── transaction   — transaction model (income, expense, transfer)
│   ├── category      — category with icon, color, and type
│   ├── currency      — currency (rub, usd, btc, eth, and others)
│   ├── account       — payment account
│   └── storage       — persistence, crud, stats, import/export
├── views/
│   ├── dashboard     — main screen with balance card and breakdowns
│   ├── transactions  — full transaction list with search and filters
│   ├── categories    — manage categories
│   ├── accounts      — manage accounts
│   ├── transfer      — move money between accounts
│   ├── settings      — base currency, import/export, reset
│   ├── onboarding    — four-step first-launch setup
│   └── Add*          — create and edit screens
└── utilities/
    ├── color         — color from hex string
    └── formatter     — currency formatting and locale-safe parsing
```

built with swiftui and `@observable` (observation framework), zero external dependencies.

## why the name

from *ledger* — a book for keeping financial records. just dropped a letter, shorter and cleaner.

## license

mit — do whatever you want.
