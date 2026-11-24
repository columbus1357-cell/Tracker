//
//  TrackerModels.swift
//  Tracker
//
//  Created by Aleksandr on 25.11.2026.
//

import UIKit

// MARK: - Weekday

enum Weekday: Int, CaseIterable {
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6
    case sunday = 7

    var shortTitle: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

// MARK: - Tracker

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let createdDate: Date?

    init(
        id: UUID,
        title: String,
        color: UIColor,
        emoji: String,
        schedule: [Weekday],
        createdDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.createdDate = createdDate
    }
}

// MARK: - TrackerCategory

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

// MARK: - TrackerRecord

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}
