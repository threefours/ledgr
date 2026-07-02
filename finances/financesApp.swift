//
//  financesApp.swift
//  Ledgr
//

import SwiftUI

@main
struct LedgrApp: App {
    @State private var storage = StorageManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(storage)
        }
    }
}
