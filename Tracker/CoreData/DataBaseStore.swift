//
//  DataBaseStore.swift
//  Tracker
//
//  Created by Aleksandr on 26.11.2026.
//

import CoreData
import Foundation

final class DataBaseStore {
    static let shared = DataBaseStore()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {}

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Unresolved Core Data save error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
