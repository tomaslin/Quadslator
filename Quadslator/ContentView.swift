//
//  ContentView.swift
//  Quadslator
//
//  Created by Chih Hao Lin on 2/23/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TranslatorView()
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
