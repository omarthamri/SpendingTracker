//
//  SpendingTrackerApp.swift
//  SpendingTracker
//
//  Created by omar thamri on 12/12/2022.
//

import SwiftUI

@main
struct SpendingTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
