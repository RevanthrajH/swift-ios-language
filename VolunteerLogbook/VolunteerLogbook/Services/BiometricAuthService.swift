//
//  BiometricAuthService.swift
//  VolunteerLogbook
//

import Foundation
import LocalAuthentication

/// Supported device biometric authentication types.
enum BiometricType: Equatable {
    case faceID
    case touchID
    case opticID
    case none

    /// Human-readable label for UI buttons and prompts.
    var displayName: String {
        switch self {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .opticID: "Optic ID"
        case .none: "Biometrics"
        }
    }

    /// SF Symbol representing the detected biometric hardware.
    var iconName: String {
        switch self {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        case .none: "lock.shield.fill"
        }
    }
}

/// Errors surfaced during LocalAuthentication verification.
enum BiometricAuthError: LocalizedError, Equatable {
    case unavailable(String)
    case cancelled
    case fallbackRequested
    case failed(String)

    var errorDescription: String? {
        switch self {
        case .unavailable(let reason):
            reason
        case .cancelled:
            "Authentication was cancelled. You can retry biometrics or use manual login."
        case .fallbackRequested:
            "Please sign in using manual login below."
        case .failed(let reason):
            reason
        }
    }
}

/// Abstraction over LocalAuthentication so `AuthenticationViewModel` can be unit-tested cleanly.
protocol BiometricAuthServing {
    func availableBiometricType() -> BiometricType
    func authenticate(reason: String) async throws
}

/// Service wrapping Apple's `LocalAuthentication` framework without storing any biometric data.
final class BiometricAuthService: BiometricAuthServing {
    /// Checks whether Face ID / Touch ID is available and enrolled on the current device.
    func availableBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    /// Prompts the system biometric sheet and returns on successful verification.
    func authenticate(reason: String) async throws {
        let context = LAContext()
        context.localizedFallbackTitle = "Use Manual Login"

        var authError: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            let message = mapPolicyError(authError)
            throw BiometricAuthError.unavailable(message)
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            if !success {
                throw BiometricAuthError.failed("Biometric verification did not succeed.")
            }
        } catch let error as BiometricAuthError {
            throw error
        } catch let laError as LAError {
            throw mapLAError(laError)
        } catch {
            throw BiometricAuthError.failed(error.localizedDescription)
        }
    }

    private func mapPolicyError(_ error: NSError?) -> String {
        guard let laError = error as? LAError else {
            return "Biometric authentication is not available on this device."
        }

        switch laError.code {
        case .biometryNotEnrolled:
            return "No Face ID or Touch ID is enrolled on this device. Use manual login below."
        case .biometryLockout:
            return "Biometrics are temporarily locked after too many attempts. Use manual login below."
        case .biometryNotAvailable, .passcodeNotSet:
            return "Biometric authentication is unavailable. Use manual login below."
        default:
            return laError.localizedDescription
        }
    }

    private func mapLAError(_ error: LAError) -> BiometricAuthError {
        switch error.code {
        case .userCancel, .appCancel, .systemCancel:
            return .cancelled
        case .userFallback:
            return .fallbackRequested
        case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet, .biometryLockout:
            return .unavailable(mapPolicyError(error as NSError))
        default:
            return .failed("Biometric recognition failed. Please try again or use manual login.")
        }
    }
}
