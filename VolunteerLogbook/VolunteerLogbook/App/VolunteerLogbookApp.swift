//
//  VolunteerLogbookApp.swift
//  VolunteerLogbook
//

import SwiftData
import SwiftUI

/// Entry point for the Community Volunteer & Shift Logbook application.
@main
struct VolunteerLogbookApp: App {
    private let modelContainer: ModelContainer
    @State private var appState = AppState()
    @State private var storageService: ShiftStorageService

    init() {
        do {
            let container = try ShiftStorageService.makeModelContainer()
            self.modelContainer = container
            _storageService = State(initialValue: ShiftStorageService(container: container))
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environment(appState)
            .environment(storageService)
            .modelContainer(modelContainer)
        }
    }
}
