//
//  ledger_iosApp.swift
//  ledger-ios
//
//  Created by Jinwoo Hwangbo on 6/22/25.
//

import SwiftUI
import SwiftData

@main
struct LedgerApp: App {
    
    @AppStorage("appAppearance") private var appearanceSetting: String = AppAppearance.light.rawValue

    var appearance: AppAppearance {
        AppAppearance(rawValue: appearanceSetting) ?? .light
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .preferredColorScheme(appearance.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
