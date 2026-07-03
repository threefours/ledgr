//
//  financesApp.swift
//  Ledgr
//

import SwiftUI

@main
struct LedgrApp: App {
    @State private var storage = StorageManager()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(storage)
                .fullScreenCover(isPresented: Binding(
                    get: { !hasCompletedOnboarding },
                    set: { hasCompletedOnboarding = !$0 }
                )) {
                    OnboardingView()
                        .environment(storage)
                }
        }
    }
}
