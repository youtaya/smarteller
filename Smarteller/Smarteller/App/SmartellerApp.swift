//
//  SmartellerApp.swift
//  Smarteller
//
//  Created by 金小平 on 2025/7/18.
//

import SwiftUI
import SwiftData

@main
struct SmartellerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TeleprompterText.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
