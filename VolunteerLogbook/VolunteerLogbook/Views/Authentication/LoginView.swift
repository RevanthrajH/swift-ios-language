//
//  LoginView.swift
//  VolunteerLogbook
//

import SwiftUI

/// Authentication screen supporting Face ID / Touch ID and a manual login fallback.
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthenticationViewModel()
    @State private var hasTriggeredLaunchPrompt = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                biometricCard

                manualFallbackSection
            }
            .padding(24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .scrollDismissesKeyboard(.interactively)
        .task {
            viewModel.refreshBiometricAvailability()
            if appState.shouldAutoPromptBiometrics && !hasTriggeredLaunchPrompt && viewModel.isBiometricAvailable {
                hasTriggeredLaunchPrompt = true
                await viewModel.attemptBiometricLogin {
                    appState.unlockSession()
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
                .padding(18)
                .background(.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 24, style: .continuous))

            Text("Volunteer Logbook")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            Text("Verify your identity to access community volunteer shifts and logs.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var biometricCard: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.biometricType.iconName)
                .font(.system(size: 40))
                .foregroundStyle(.tint)

            Text(viewModel.isBiometricAvailable ? "Unlock with \(viewModel.biometricType.displayName)" : "Biometric Unlock Unavailable")
                .font(.headline)

            Text(
                viewModel.statusMessage
                    ?? "Use \(viewModel.biometricType.displayName) to unlock your logbook quickly and securely."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            if let errorMessage = viewModel.errorMessage, !viewModel.showManualForm {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            if viewModel.isBiometricAvailable {
                Button {
                    Task {
                        await viewModel.attemptBiometricLogin {
                            appState.unlockSession()
                        }
                    }
                } label: {
                    if viewModel.isAuthenticating {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    } else {
                        Label(
                            "Unlock with \(viewModel.biometricType.displayName)",
                            systemImage: "lock.open.fill"
                        )
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isAuthenticating)
            }
        }
        .padding(20)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }

    private var manualFallbackSection: some View {
        VStack(spacing: 14) {
            if viewModel.isBiometricAvailable {
                Button {
                    withAnimation {
                        viewModel.showManualForm.toggle()
                    }
                } label: {
                    Text(viewModel.showManualForm ? "Hide Manual Login" : "Use Manual Login Instead")
                        .font(.subheadline.weight(.medium))
                }
            }

            if viewModel.showManualForm || !viewModel.isBiometricAvailable {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Manual Login Fallback")
                        .font(.headline)

                    if let errorMessage = viewModel.errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    TextField("Volunteer ID or Email", text: $viewModel.volunteerID)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    SecureField("Passcode (min 4 characters)", text: $viewModel.passcode)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.go)
                        .onSubmit {
                            viewModel.attemptManualLogin {
                                appState.unlockSession()
                            }
                        }

                    Button {
                        viewModel.attemptManualLogin {
                            appState.unlockSession()
                        }
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(20)
                .background(
                    Color(uiColor: .secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
