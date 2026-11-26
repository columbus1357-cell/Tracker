//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Aleksandr on 26.11.2026.
//

import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerRecordCoreData.date), ascending: false)
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
    
    func fetchRecords() -> [TrackerRecord] {
            let objects = fetchedResultsController.fetchedObjects ?? []
            return objects.compactMap { coreDataRecord in
                guard let trackerId = coreDataRecord.trackerId,
                      let date = coreDataRecord.date else {
                    return nil
                }
                return TrackerRecord(trackerId: trackerId, date: date)
            }
        }

        func add(_ record: TrackerRecord) throws {
            let entity = TrackerRecordCoreData(context: context)
            entity.trackerId = record.trackerId
            entity.date = record.date

            let trackerRequest = TrackerCoreData.fetchRequest()
            trackerRequest.predicate = NSPredicate(format: "id == %@", record.trackerId as CVarArg)
            trackerRequest.fetchLimit = 1
            entity.tracker = try context.fetch(trackerRequest).first

            try saveContext()
        }

        func remove(_ record: TrackerRecord) throws {
            let request = TrackerRecordCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerId), record.trackerId as CVarArg)

            let candidates = try context.fetch(request)
            let matchingRecords = candidates.filter { coreDataRecord in
                guard let date = coreDataRecord.date else { return false }
                return Calendar.current.isDate(date, inSameDayAs: record.date)
            }

            for object in matchingRecords {
                context.delete(object)
            }

            if !matchingRecords.isEmpty {
                try saveContext()
            }
        }

        private func saveContext() throws {
            guard context.hasChanges else { return }
            try context.save()
        }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
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
