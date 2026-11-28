//
//  VolunteerLogbookTests.swift
//  VolunteerLogbookTests
//

import Foundation
import SwiftData
import Testing
@testable import VolunteerLogbook

/// Mock biometric service used to test `AuthenticationViewModel` without hardware prompts.
private final class MockBiometricAuthService: BiometricAuthServing {
    var biometricType: BiometricType
    var result: Result<Void, Error>

    init(biometricType: BiometricType = .faceID, result: Result<Void, Error> = .success(())) {
        self.biometricType = biometricType
        self.result = result
    }

    func availableBiometricType() -> BiometricType {
        biometricType
    }

    func authenticate(reason: String) async throws {
        try result.get()
    }
}

@Suite(.serialized)
@MainActor
struct VolunteerLogbookTests {
    // MARK: - Helpers

    private func makeInMemoryStorage() throws -> ShiftStorageService {
        let container = try ShiftStorageService.makeModelContainer(inMemory: true)
        return ShiftStorageService(container: container)
    }

    // MARK: - Persistence & CRUD Tests

    @Test func addEditAndDeleteShiftPersistsInSwiftData() throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("VolunteerLogbookTest-\(UUID().uuidString).store")
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }

        let schema = Schema([Shift.self])
        let config = ModelConfiguration(schema: schema, url: tempURL)
        let container = try ModelContainer(for: schema, configurations: [config])
        let storage = ShiftStorageService(container: container)

        let created = try storage.addShift(
            title: "  Neighborhood Food Box Drive  ",
            category: .foodDrive,
            location: "  Central Pantry  ",
            shiftDate: Date(),
            notes: "  Bring gloves  ",
            status: .upcoming
        )

        #expect(storage.shifts.count == 1)
        #expect(created.title == "Neighborhood Food Box Drive")
        #expect(created.location == "Central Pantry")
        #expect(created.notes == "Bring gloves")

        // Verify persistence when reloaded with a new ModelContext against the same store.
        let freshContext = ModelContext(container)
        let reloadedStorage = ShiftStorageService(context: freshContext)
        #expect(reloadedStorage.shifts.count == 1)
        let persisted = try #require(reloadedStorage.shifts.first)
        #expect(persisted.shiftID == created.shiftID)

        try reloadedStorage.updateShift(
            persisted,
            title: "Updated Food Drive",
            category: .relief,
            location: "Eastside Hub",
            shiftDate: persisted.shiftDate,
            notes: "Completed ahead of schedule",
            status: .completed
        )

        #expect(reloadedStorage.shifts.first?.title == "Updated Food Drive")
        #expect(reloadedStorage.shifts.first?.category == .relief)
        #expect(reloadedStorage.shifts.first?.status == .completed)

        try reloadedStorage.deleteShift(persisted)
        #expect(reloadedStorage.shifts.isEmpty)
    }

    // MARK: - Form Validation Tests

    @Test func shiftFormValidationRejectsMissingTitleAndLocation() throws {
        let storage = try makeInMemoryStorage()
        let form = ShiftFormViewModel()

        form.title = "   "
        form.location = "Civic Hall"
        #expect(form.save(using: storage) == false)
        #expect(form.validationMessage == "Please enter a shift title.")
        #expect(storage.shifts.isEmpty)

        form.title = "River Cleanup"
        form.location = "  "
        #expect(form.save(using: storage) == false)
        #expect(form.validationMessage == "Please enter a site or location.")
        #expect(storage.shifts.isEmpty)

        form.location = "Riverside Park"
        form.category = .cleanup
        form.status = .completed
        #expect(form.save(using: storage) == true)
        #expect(form.validationMessage == nil)
        #expect(storage.shifts.count == 1)
    }

    // MARK: - Search & Filter Tests

    @Test func searchAndFiltersCombineCorrectly() throws {
        let storage = try makeInMemoryStorage()
        try storage.addShift(
            title: "Downtown Food Pantry",
            category: .foodDrive,
            location: "Main Street Kitchen",
            shiftDate: Date(),
            notes: "",
            status: .completed
        )
        try storage.addShift(
            title: "Youth Literacy Tutoring",
            category: .teaching,
            location: "Downtown Library",
            shiftDate: Date(),
            notes: "",
            status: .upcoming
        )
        try storage.addShift(
            title: "Park Trail Cleanup",
            category: .cleanup,
            location: "North Park",
            shiftDate: Date(),
            notes: "",
            status: .cancelled
        )

        let listVM = ShiftListViewModel()
        #expect(listVM.filteredShifts(from: storage.shifts).count == 3)

        // Search by location ("Downtown") matches Food Pantry (title) and Library (location).
        listVM.searchText = "downtown"
        #expect(listVM.filteredShifts(from: storage.shifts).count == 2)

        // Combining search + category narrows to 1 shift.
        listVM.selectedCategory = .teaching
        let teachingMatches = listVM.filteredShifts(from: storage.shifts)
        #expect(teachingMatches.count == 1)
        #expect(teachingMatches.first?.title == "Youth Literacy Tutoring")

        // Adding mismatched status yields 0 results.
        listVM.selectedStatus = .completed
        #expect(listVM.filteredShifts(from: storage.shifts).isEmpty)
        #expect(listVM.hasActiveFilters == true)

        // Clearing filters restores all shifts.
        listVM.clearFilters()
        #expect(listVM.hasActiveFilters == false)
        #expect(listVM.filteredShifts(from: storage.shifts).count == 3)
    }

    @Test func deleteConfirmationFlowRemovesSelectedShift() throws {
        let storage = try makeInMemoryStorage()
        let shift = try storage.addShift(
            title: "Duplicate Relief Shift",
            category: .relief,
            location: "Civic Center",
            shiftDate: Date(),
            notes: "",
            status: .cancelled
        )

        let listVM = ShiftListViewModel()
        listVM.requestDeletion(of: shift)
        #expect(listVM.isShowingDeleteConfirmation == true)
        #expect(listVM.shiftPendingDeletion?.shiftID == shift.shiftID)

        listVM.cancelDeletion()
        #expect(listVM.isShowingDeleteConfirmation == false)
        #expect(storage.shifts.count == 1)

        listVM.requestDeletion(of: shift)
        #expect(listVM.confirmDeletion(using: storage) == true)
        #expect(storage.shifts.isEmpty)
        #expect(listVM.shiftPendingDeletion == nil)
    }

    // MARK: - Dashboard Statistics Tests

    @Test func dashboardStatisticsComputeCountsAndRecentEntries() {
        let dashboardVM = DashboardViewModel()
        let emptySummary = dashboardVM.summary(for: [])
        #expect(emptySummary == DashboardSummary(totalShifts: 0, activeCategories: 0, completedShifts: 0, upcomingShifts: 0))
        #expect(dashboardVM.recentShifts(from: []).isEmpty)

        let samples = Shift.makeSampleShifts()
        let summary = dashboardVM.summary(for: samples)
        #expect(summary.totalShifts == 4)
        #expect(summary.activeCategories == 4)
        #expect(summary.completedShifts == 2)
        #expect(summary.upcomingShifts == 1)

        let recent = dashboardVM.recentShifts(from: samples, limit: 3)
        #expect(recent.count == 3)
        #expect(recent[0].createdAt >= recent[1].createdAt)
        #expect(recent[1].createdAt >= recent[2].createdAt)
    }

    // MARK: - Authentication Tests

    @Test func biometricSuccessAndFallbackManualValidation() async {
        let successAuth = AuthenticationViewModel(
            authService: MockBiometricAuthService(biometricType: .faceID, result: .success(()))
        )
        var unlocked = false
        await successAuth.attemptBiometricLogin { unlocked = true }
        #expect(unlocked == true)
        #expect(successAuth.errorMessage == nil)

        // Unavailable biometrics opens manual fallback automatically.
        let unavailableAuth = AuthenticationViewModel(
            authService: MockBiometricAuthService(biometricType: .none)
        )
        unavailableAuth.refreshBiometricAvailability()
        #expect(unavailableAuth.isBiometricAvailable == false)
        #expect(unavailableAuth.showManualForm == true)

        // Rejects invalid manual credentials (short ID / whitespace passcode).
        unavailableAuth.volunteerID = "ab"
        unavailableAuth.passcode = "1234"
        var manualUnlocked = false
        unavailableAuth.attemptManualLogin { manualUnlocked = true }
        #expect(manualUnlocked == false)
        #expect(unavailableAuth.errorMessage != nil)

        unavailableAuth.volunteerID = "vol101"
        unavailableAuth.passcode = "    "
        unavailableAuth.attemptManualLogin { manualUnlocked = true }
        #expect(manualUnlocked == false)

        unavailableAuth.passcode = "4321"
        unavailableAuth.attemptManualLogin { manualUnlocked = true }
        #expect(manualUnlocked == true)
        #expect(unavailableAuth.errorMessage == nil)
        #expect(unavailableAuth.passcode.isEmpty)
    }
}
