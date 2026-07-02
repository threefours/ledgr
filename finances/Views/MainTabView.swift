import SwiftUI

struct MainTabView: View {
    @Environment(StorageManager.self) private var storage
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "chart.pie.fill", value: 0) {
                DashboardView()
            }

            Tab("Transactions", systemImage: "list.bullet.rectangle.fill", value: 1) {
                TransactionListView()
            }

            Tab("Categories", systemImage: "square.grid.2x2.fill", value: 2) {
                CategoriesView()
            }

            Tab("Accounts", systemImage: "creditcard.fill", value: 3) {
                AccountsView()
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                SettingsView()
            }
        }
        .tint(.green)
    }
}

#Preview {
    MainTabView()
        .environment(StorageManager())
}
