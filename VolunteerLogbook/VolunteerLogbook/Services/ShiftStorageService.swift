//
//  ShiftStorageService.swift
//  VolunteerLogbook
//

import Foundation
import Observation
import SwiftData

/// Errors surfaced by local SwiftData persistence operations.
enum ShiftStorageError: LocalizedError {
    case fetchFailed(Error)
    case saveFailed(Error)
    case deleteFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            "Unable to load volunteer shifts: \(error.localizedDescription)"
        case .saveFailed(let error):
            "Unable to save volunteer shift: \(error.localizedDescription)"
        case .deleteFailed(let error):
            "Unable to delete volunteer shift: \(error.localizedDescription)"
        }
    }
}

/// Service managing persistent local SwiftData storage for `Shift` records.
@Observable
final class ShiftStorageService {
    private let container: ModelContainer?
    private let context: ModelContext

    /// Cached list of persisted shifts sorted with the most recently added entries first.
    private(set) var shifts: [Shift] = []

    /// Most recent storage error message, if an operation failed.
    private(set) var lastErrorMessage: String?

    /// Creates a shared SwiftData `ModelContainer` for disk or in-memory storage.
    static func makeModelContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([Shift.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    convenience init(container: ModelContainer) {
        self.init(context: container.mainContext, container: container)
    }

    init(context: ModelContext, container: ModelContainer? = nil) {
        self.context = context
        self.container = container
        do {
            try refresh()
        } catch {
            lastErrorMessage = error.localizedDescription
        }
    }

    /// Reloads all persisted shifts from SwiftData sorted by newest `createdAt` first.
    @discardableResult
    func refresh() throws -> [Shift] {
        let descriptor = FetchDescriptor<Shift>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        do {
            let fetched = try context.fetch(descriptor)
            shifts = fetched
            return fetched
        } catch {
            throw ShiftStorageError.fetchFailed(error)
        }
    }

    /// Inserts and persists a new `Shift` record in SwiftData.
    @discardableResult
    func addShift(
        title: String,
        category: ShiftCategory,
        location: String,
        shiftDate: Date,
        notes: String,
        status: ShiftStatus
    ) throws -> Shift {
        let now = Date()
        let shift = Shift(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            shiftDate: shiftDate,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            status: status,
            createdAt: now,
            updatedAt: now
        )
        context.insert(shift)
        try saveContext()
        try refresh()
        return shift
    }

    /// Updates an existing persisted `Shift` record and saves changes to disk.
    func updateShift(
        _ shift: Shift,
        title: String,
        category: ShiftCategory,
        location: String,
        shiftDate: Date,
        notes: String,
        status: ShiftStatus
    ) throws {
        shift.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        shift.category = category
        shift.location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        shift.shiftDate = shiftDate
        shift.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        shift.status = status
        shift.updatedAt = Date()

        try saveContext()
        try refresh()
    }

    /// Permanently removes a `Shift` record from SwiftData.
    func deleteShift(_ shift: Shift) throws {
        context.delete(shift)
        do {
            try context.save()
        } catch {
            throw ShiftStorageError.deleteFailed(error)
        }
        try refresh()
    }

    private func saveContext() throws {
        do {
            try context.save()
        } catch {
            throw ShiftStorageError.saveFailed(error)
        }
    }

    #if DEBUG
    /// In-memory storage pre-seeded with sample shifts for SwiftUI previews.
    static func preview() -> ShiftStorageService {
        do {
            let container = try makeModelContainer(inMemory: true)
            let context = container.mainContext
            for sample in Shift.makeSampleShifts() {
                context.insert(sample)
            }
            try context.save()
            return ShiftStorageService(container: container)
        } catch {
            fatalError("Failed to create preview ShiftStorageService: \(error)")
        }
    }
    #endif
}
