//
//  AppState.swift
//  VolunteerLogbook
//

import Observation

/// Top-level tabs available after authentication.
enum AppTab: Hashable {
    case dashboard
    case shifts
}

/// Holds application-wide state such as authentication and active tab selection.
@Observable
final class AppState {
    /// Requires biometric or manual authentication before accessing volunteer logs.
    var isAuthenticated: Bool = false

    /// Automatically prompts biometrics on initial app launch, but stays idle after manual lock.
    var shouldAutoPromptBiometrics: Bool = true

    /// Currently selected tab in `MainTabView`.
    var selectedTab: AppTab = .dashboard

    /// Unlocks access to the volunteer logbook.
    func unlockSession() {
        isAuthenticated = true
    }

    /// Locks access to the volunteer logbook and returns to the login screen.
    func lockSession() {
        shouldAutoPromptBiometrics = false
        isAuthenticated = false
    }
}
