//
//  Shift.swift
//  VolunteerLogbook
//

import Foundation
import SwiftData
import SwiftUI

/// Supported volunteer activity categories defined in the project specification.
enum ShiftCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case foodDrive = "Food Drive"
    case teaching = "Teaching"
    case cleanup = "Cleanup"
    case relief = "Relief"

    var id: String { rawValue }

    /// SF Symbol representing the volunteer category.
    var iconName: String {
        switch self {
        case .foodDrive: "takeoutbag.and.cup.and.straw.fill"
        case .teaching: "book.closed.fill"
        case .cleanup: "leaf.fill"
        case .relief: "cross.case.fill"
        }
    }

    /// Accent color paired with each category for visual scanning.
    var tintColor: Color {
        switch self {
        case .foodDrive: .orange
        case .teaching: .indigo
        case .cleanup: .green
        case .relief: .teal
        }
    }
}

/// Tracking statuses for volunteer shifts.
enum ShiftStatus: String, CaseIterable, Identifiable, Codable, Hashable {
    case completed = "Completed"
    case upcoming = "Upcoming"
    case cancelled = "Cancelled"

    var id: String { rawValue }

    /// SF Symbol representing the shift status.
    var iconName: String {
        switch self {
        case .completed: "checkmark.circle.fill"
        case .upcoming: "clock.fill"
        case .cancelled: "xmark.circle.fill"
        }
    }

    /// Semantic color used by status badges.
    var tintColor: Color {
        switch self {
        case .completed: .green
        case .upcoming: .blue
        case .cancelled: .red
        }
    }
}

/// Persistent SwiftData model representing a logged community volunteer shift.
@Model
final class Shift {
    @Attribute(.unique) var shiftID: UUID
    var title: String
    var categoryRawValue: String
    var location: String
    var shiftDate: Date
    var notes: String
    var statusRawValue: String
    var createdAt: Date
    var updatedAt: Date

    /// Typed volunteer category backed by `categoryRawValue` for SwiftData persistence.
    var category: ShiftCategory {
        get { ShiftCategory(rawValue: categoryRawValue) ?? .foodDrive }
        set { categoryRawValue = newValue.rawValue }
    }

    /// Typed tracking status backed by `statusRawValue` for SwiftData persistence.
    var status: ShiftStatus {
        get { ShiftStatus(rawValue: statusRawValue) ?? .upcoming }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        shiftID: UUID = UUID(),
        title: String,
        category: ShiftCategory,
        location: String,
        shiftDate: Date,
        notes: String = "",
        status: ShiftStatus = .upcoming,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.shiftID = shiftID
        self.title = title
        self.categoryRawValue = category.rawValue
        self.location = location
        self.shiftDate = shiftDate
        self.notes = notes
        self.statusRawValue = status.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Sample records used strictly for SwiftUI Canvas previews and unit tests.
    static func makeSampleShifts() -> [Shift] {
        [
            Shift(
                title: "Morning Pantry Distribution",
                category: .foodDrive,
                location: "Downtown Community Kitchen",
                shiftDate: Date().addingTimeInterval(-86_400 * 2),
                notes: "Packed and distributed 140 grocery boxes for local families.",
                status: .completed,
                createdAt: Date().addingTimeInterval(-86_400 * 2)
            ),
            Shift(
                title: "After-School Coding Workshop",
                category: .teaching,
                location: "Lincoln Public Library",
                shiftDate: Date().addingTimeInterval(86_400 * 2),
                notes: "Bring extra laptops and beginner Swift activity sheets.",
                status: .upcoming,
                createdAt: Date().addingTimeInterval(-3_600 * 12)
            ),
            Shift(
                title: "Riverside Park Trail Sweep",
                category: .cleanup,
                location: "Riverside Park North",
                shiftDate: Date().addingTimeInterval(-86_400 * 5),
                notes: "Collected recyclables along the 3-mile riverfront path.",
                status: .completed,
                createdAt: Date().addingTimeInterval(-86_400 * 5)
            ),
            Shift(
                title: "Emergency Supply Sorting",
                category: .relief,
                location: "Eastside Civic Center",
                shiftDate: Date().addingTimeInterval(86_400 * 5),
                notes: "Rescheduled due to venue maintenance.",
                status: .cancelled,
                createdAt: Date().addingTimeInterval(-3_600 * 4)
            )
        ]
    }
}
