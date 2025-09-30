//
//  PeakofEloquenceApp.swift
//  PeakofEloquence
//
//  Created by Reza Jafar on 9/29/25.
//

import SwiftUI
import SwiftData

@main
struct PeakofEloquenceApp: App {
    @AppStorage("isDarkMode") private var storedDarkMode: Bool = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
                .preferredColorScheme(storedDarkMode ? .dark : .light)
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .windowBackground(storedDarkMode ? .ultraThinMaterial : .thickMaterial)
    }
}
