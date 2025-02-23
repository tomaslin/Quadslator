//
//  Persistence.swift
//  Quadslator
//
//  Created by Chih Hao Lin on 2/23/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create a sample translation preference
        let preference = TranslationPreference(context: viewContext)
        preference.translateAs = "Spanish used in Mexico"
        preference.timestamp = Date()
        
        // Create some sample translations
        for i in 0..<3 {
            let translation = TranslationText(context: viewContext)
            translation.sourceText = "Sample text \(i)"
            translation.translatedText = "Translated sample \(i)"
            translation.timestamp = Date()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Quadslator")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
