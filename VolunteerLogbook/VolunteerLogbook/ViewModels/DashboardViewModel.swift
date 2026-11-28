//
//  DashboardViewModel.swift
//  VolunteerLogbook
//

import Foundation
import Observation

/// Snapshot of summary statistics displayed on the Dashboard.
struct DashboardSummary: Equatable {
    let totalShifts: Int
    let activeCategories: Int
    let completedShifts: Int
    let upcomingShifts: Int
}

/// Computes live volunteer summary metrics and recent entries for `DashboardView`.
@Observable
final class DashboardViewModel {
    /// Calculates all dashboard statistics from the persisted shift list.
    func summary(for shifts: [Shift]) -> DashboardSummary {
        DashboardSummary(
            totalShifts: shifts.count,
            activeCategories: Set(shifts.map(\.category)).count,
            completedShifts: shifts.filter { $0.status == .completed }.count,
            upcomingShifts: shifts.filter { $0.status == .upcoming }.count
        )
    }

    /// Returns the most recently added shifts sorted newest-first.
    func recentShifts(from shifts: [Shift], limit: Int = 3) -> [Shift] {
        guard limit > 0 else { return [] }
        return Array(
            shifts
                .sorted { $0.createdAt > $1.createdAt }
                .prefix(limit)
        )
    }
}
