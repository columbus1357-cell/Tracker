//
//  TrackerStore.swift
//  Tracker
//
//  Created by Aleksandr on 26.11.2026.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    override convenience init() {
        self.init(context: DataBaseStore.shared.viewContext)
    }
    
    func add(_ tracker: Tracker, toCategoryTitle categoryTitle: String) throws {
            let categoryStore = TrackerCategoryStore(context: context)
            let categoryCoreData = try categoryStore.categoryCoreData(withTitle: categoryTitle)

            let trackerCoreData = TrackerCoreData(context: context)
            trackerCoreData.id = tracker.id
            trackerCoreData.title = tracker.title
            trackerCoreData.color = try NSKeyedArchiver.archivedData(
                withRootObject: tracker.color,
                requiringSecureCoding: true
            ) as NSData
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = tracker.schedule.map(\.rawValue) as NSArray
            trackerCoreData.createdDate = tracker.createdDate
            trackerCoreData.category = categoryCoreData

            do {
                try saveContext()
            } catch let error as NSError {
                print("Core Data save error:", error)
                print("Detailed errors:", error.userInfo[NSDetailedErrorsKey] ?? "none")
                throw error
            }
        }

        private func saveContext() throws {
            guard context.hasChanges else { return }
            try context.save()
        }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexes = nil
        deletedIndexes = nil
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath {
                insertedIndexes?.insert(newIndexPath.item)
            }
        case .delete:
            if let indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
