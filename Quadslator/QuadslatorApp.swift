//
//  QuadslatorApp.swift
//  Quadslator
//
//  Created by Chih Hao Lin on 2/23/25.
//

import SwiftUI

@main
struct QuadslatorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
