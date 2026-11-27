//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Aleksandr on 26.11.2026.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories()
}

final class TrackerCategoryStore: NSObject {

    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true)
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

    func fetchCategories() -> [TrackerCategory] {
        let objects = fetchedResultsController.fetchedObjects ?? []
        return objects.map { categoryCoreData in
            let title = categoryCoreData.title ?? ""
            let trackersSet = categoryCoreData.trackers as? Set<TrackerCoreData> ?? []
            let trackers: [Tracker] = trackersSet.compactMap { trackerCoreData in
                guard let id = trackerCoreData.id,
                      let title = trackerCoreData.title,
                      let emoji = trackerCoreData.emoji else {
                    return nil
                }

                let color: UIColor
                if let data = trackerCoreData.color as? Data,
                   let decodedColor = try? NSKeyedUnarchiver.unarchivedObject(
                       ofClass: UIColor.self,
                       from: data
                   ) {
                    color = decodedColor
                } else if let directColor = trackerCoreData.color as? UIColor {
                    color = directColor
                } else {
                    color = UIColor(resource: .ypColorSelection5)
                }

                let rawSchedule = (trackerCoreData.schedule as? [Int]) ?? []
                let schedule = rawSchedule.compactMap(Weekday.init(rawValue:))

                return Tracker(
                    id: id,
                    title: title,
                    color: color,
                    emoji: emoji,
                    schedule: schedule,
                    createdDate: trackerCoreData.createdDate
                )
            }
            return TrackerCategory(title: title, trackers: trackers)
        }
    }

    func addCategory(title: String) {
        do {
            _ = try categoryCoreData(withTitle: title)
            try fetchedResultsController.performFetch()
            delegate?.didUpdateCategories()
        } catch {
            print("Ошибка добавления категории: \(error)")
        }
    }

    func categoryCoreData(withTitle title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), title)
        request.fetchLimit = 1

        if let existing = try context.fetch(request).first {
            return existing
        }

        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        try saveContext()
        return newCategory
    }

    private func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories()
    }
}
