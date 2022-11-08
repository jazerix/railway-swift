//
//  RailworkDetectionApp.swift
//  RailworkDetection
//
//  Created by Niels Faurskov on 08/11/2022.
//

import SwiftUI

@main
struct RailworkDetectionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
