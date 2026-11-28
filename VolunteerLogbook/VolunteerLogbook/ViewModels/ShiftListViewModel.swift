//
//  ShiftListViewModel.swift
//  VolunteerLogbook
//

import Foundation
import Observation

/// Manages shift list search, category/status filtering, and deletion confirmation.
@Observable
final class ShiftListViewModel {
    var searchText: String = ""
    var selectedCategory: ShiftCategory?
    var selectedStatus: ShiftStatus?

    var shiftPendingDeletion: Shift?
    var isShowingDeleteConfirmation: Bool = false
    var errorMessage: String?

    /// Returns `true` when any search query, category filter, or status filter is active.
    var hasActiveFilters: Bool {
        !trimmedSearchText.isEmpty || selectedCategory != nil || selectedStatus != nil
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Applies search text (title or location), category, and status filters together.
    func filteredShifts(from shifts: [Shift]) -> [Shift] {
        let query = trimmedSearchText

        return shifts.filter { shift in
            let matchesCategory = selectedCategory == nil || shift.category == selectedCategory
            let matchesStatus = selectedStatus == nil || shift.status == selectedStatus
            let matchesQuery = query.isEmpty
                || shift.title.localizedCaseInsensitiveContains(query)
                || shift.location.localizedCaseInsensitiveContains(query)

            return matchesCategory && matchesStatus && matchesQuery
        }
    }

    /// Resets search text and all active category/status filters.
    func clearFilters() {
        searchText = ""
        selectedCategory = nil
        selectedStatus = nil
    }

    /// Prompts the user to confirm deletion before removing a shift.
    func requestDeletion(of shift: Shift) {
        shiftPendingDeletion = shift
        isShowingDeleteConfirmation = true
    }

    /// Cancels the pending deletion request.
    func cancelDeletion() {
        shiftPendingDeletion = nil
        isShowingDeleteConfirmation = false
    }

    /// Permanently deletes the pending shift via `ShiftStorageService`.
    @discardableResult
    func confirmDeletion(using storageService: ShiftStorageService) -> Bool {
        guard let shift = shiftPendingDeletion else { return false }

        do {
            try storageService.deleteShift(shift)
            shiftPendingDeletion = nil
            isShowingDeleteConfirmation = false
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
