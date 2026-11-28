//
//  AuthenticationViewModel.swift
//  VolunteerLogbook
//

import Foundation
import Observation

/// Manages biometric unlock (`LocalAuthentication`) and manual login fallback validation.
@Observable
final class AuthenticationViewModel {
    var volunteerID: String = ""
    var passcode: String = ""
    var showManualForm: Bool = false
    var isAuthenticating: Bool = false
    var biometricType: BiometricType = .none
    var statusMessage: String?
    var errorMessage: String?

    private let authService: any BiometricAuthServing

    /// Indicates whether Face ID or Touch ID is currently available and enrolled.
    var isBiometricAvailable: Bool {
        biometricType != .none
    }

    init(authService: any BiometricAuthServing = BiometricAuthService()) {
        self.authService = authService
    }

    /// Refreshes device biometric capability and reveals manual fallback if unavailable.
    func refreshBiometricAvailability() {
        biometricType = authService.availableBiometricType()
        if !isBiometricAvailable {
            showManualForm = true
            statusMessage = "Biometric authentication is unavailable or not enrolled. Use manual login below."
        } else {
            statusMessage = nil
        }
    }

    /// Triggers Face ID / Touch ID verification via `BiometricAuthService`.
    func attemptBiometricLogin(onSuccess: () -> Void) async {
        guard !isAuthenticating else { return }

        refreshBiometricAvailability()
        guard isBiometricAvailable else {
            errorMessage = nil
            return
        }

        isAuthenticating = true
        errorMessage = nil
        defer { isAuthenticating = false }

        do {
            try await authService.authenticate(
                reason: "Unlock Volunteer Logbook to view and manage community shifts."
            )
            onSuccess()
        } catch let authError as BiometricAuthError {
            switch authError {
            case .fallbackRequested, .unavailable:
                showManualForm = true
                errorMessage = authError.errorDescription
            case .cancelled, .failed:
                showManualForm = true
                errorMessage = authError.errorDescription
            }
        } catch {
            showManualForm = true
            errorMessage = error.localizedDescription
        }
    }

    /// Validates manual credentials and unlocks the session when biometrics cannot be used.
    func attemptManualLogin(onSuccess: () -> Void) {
        let trimmedID = volunteerID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPasscode = passcode.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedID.count < 3 {
            errorMessage = "Please enter a Volunteer ID or email (at least 3 characters)."
            return
        }

        if trimmedPasscode.count < 4 {
            errorMessage = "Please enter a passcode with at least 4 characters."
            return
        }

        errorMessage = nil
        statusMessage = nil
        passcode = ""
        onSuccess()
    }
}
