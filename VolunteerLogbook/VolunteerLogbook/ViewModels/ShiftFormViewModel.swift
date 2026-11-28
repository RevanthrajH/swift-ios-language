//
//  ShiftFormViewModel.swift
//  VolunteerLogbook
//

import Foundation
import Observation

/// Manages form state, validation, and persistence for adding or editing a `Shift`.
@Observable
final class ShiftFormViewModel {
    var title: String
    var category: ShiftCategory
    var location: String
    var shiftDate: Date
    var status: ShiftStatus
    var notes: String
    var validationMessage: String?

    private let existingShift: Shift?

    /// Whether the form is modifying an existing record (`true`) or creating a new one (`false`).
    var isEditing: Bool {
        existingShift != nil
    }

    /// Creates a form view model for adding a new shift.
    init() {
        self.existingShift = nil
        self.title = ""
        self.category = .foodDrive
        self.location = ""
        self.shiftDate = Date()
        self.status = .upcoming
        self.notes = ""
    }

    /// Creates a form view model pre-populated with an existing shift for editing.
    init(shift: Shift) {
        self.existingShift = shift
        self.title = shift.title
        self.category = shift.category
        self.location = shift.location
        self.shiftDate = shift.shiftDate
        self.status = shift.status
        self.notes = shift.notes
    }

    /// Validates required fields before saving.
    @discardableResult
    func validate() -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedTitle.isEmpty {
            validationMessage = "Please enter a shift title."
            return false
        }

        if trimmedLocation.isEmpty {
            validationMessage = "Please enter a site or location."
            return false
        }

        validationMessage = nil
        return true
    }

    /// Validates input and persists the new or updated shift using `ShiftStorageService`.
    @discardableResult
    func save(using storageService: ShiftStorageService) -> Bool {
        guard validate() else { return false }

        do {
            if let existingShift {
                try storageService.updateShift(
                    existingShift,
                    title: title,
                    category: category,
                    location: location,
                    shiftDate: shiftDate,
                    notes: notes,
                    status: status
                )
            } else {
                try storageService.addShift(
                    title: title,
                    category: category,
                    location: location,
                    shiftDate: shiftDate,
                    notes: notes,
                    status: status
                )
            }
            return true
        } catch {
            validationMessage = error.localizedDescription
            return false
        }
    }
}
