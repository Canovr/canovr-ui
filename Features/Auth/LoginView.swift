import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthState.self) private var authState

    @State private var showRegister = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?

    @State private var stravaManager = StravaAuthManager(
        clientId: "214640",
        callbackDomain: "canovr-354203175068.europe-west3.run.app"
    )

    var body: some View {
        ScrollView {
            VStack(spacing: CanovRTheme.spacingXXL) {
                Spacer().frame(height: 48)

                // Logo
                VStack(spacing: CanovRTheme.spacingSM) {
                    Text("CANOVR")
                        .font(.custom("FugazOne-Regular", size: 44))
                        .foregroundStyle(CanovRTheme.primary)

                    Text("Dein intelligenter Trainingsplan")
                        .font(CanovRTheme.bodyFont)
                        .foregroundStyle(CanovRTheme.textSecondary)
                }

                Spacer().frame(height: CanovRTheme.spacingSM)

                // Strava Button
                Button {
                    Task { await loginWithStrava() }
                } label: {
                    Text("Mit Strava anmelden")
                        .font(CanovRTheme.lato(17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(CanovRTheme.strava)
                    .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusMD))
                }
                .disabled(isLoading)
                .padding(.horizontal, CanovRTheme.spacingXL)

                // Divider
                HStack(spacing: CanovRTheme.spacingMD) {
                    CanovRTheme.border.frame(height: 1)
                    Text("oder")
                        .font(CanovRTheme.lato(14))
                        .foregroundStyle(CanovRTheme.textTertiary)
                    CanovRTheme.border.frame(height: 1)
                }
                .padding(.horizontal, CanovRTheme.spacingXL)

                // Email Login
                VStack(spacing: CanovRTheme.spacingLG) {
                    VStack(spacing: CanovRTheme.spacingMD) {
                        TextField("", text: $email, prompt: Text("Email").foregroundColor(CanovRTheme.placeholder))
                            .inputStyle()
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("", text: $password, prompt: Text("Passwort").foregroundColor(CanovRTheme.placeholder))
                            .inputStyle()
                            .textContentType(.password)
                    }

                    let loginDisabled = email.isEmpty || password.isEmpty || isLoading
                    Button {
                        Task { await loginWithEmail() }
                    } label: {
                        Text("Anmelden")
                            .primaryButtonStyle(disabled: loginDisabled)
                    }
                    .disabled(loginDisabled)
                }
                .padding(.horizontal, CanovRTheme.spacingXL)

                // Error
                if let error {
                    Text(error)
                        .font(CanovRTheme.lato(14))
                        .foregroundStyle(CanovRTheme.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CanovRTheme.spacingXL)
                }

                // Register Link
                HStack(spacing: 4) {
                    Text("Noch kein Konto?")
                        .font(CanovRTheme.lato(15))
                        .foregroundStyle(CanovRTheme.textPrimary)
                    Text("Registrieren")
                        .font(CanovRTheme.lato(15, weight: .bold))
                        .foregroundStyle(CanovRTheme.primary)
                }
                .padding(.vertical, CanovRTheme.spacingMD)
                .contentShape(Rectangle())
                .onTapGesture {
                    showRegister = true
                }

                if isLoading {
                    ProgressView()
                        .tint(CanovRTheme.primary)
                }
            }
            .padding(.bottom, 48)
        }
        .background(CanovRTheme.background)
        .sheet(isPresented: $showRegister) {
            RegisterView()
        }
    }

    // MARK: - Actions

    private func loginWithStrava() async {
        isLoading = true
        error = nil

        do {
            let code = try await stravaManager.authenticate()
            let response = try await appState.api.stravaAuth(code: code)
            await MainActor.run {
                authState.setTokens(access: response.accessToken, refresh: response.refreshToken)
                authState.needsOnboarding = response.needsOnboarding
                authState.stravaProfile = response.stravaProfile
            }
        } catch StravaAuthManager.AuthError.cancelled {
            // User cancelled — do nothing
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    private func loginWithEmail() async {
        isLoading = true
        error = nil

        do {
            let response = try await appState.api.emailLogin(
                email: email,
                password: password
            )
            await MainActor.run {
                authState.setTokens(access: response.accessToken, refresh: response.refreshToken)
                authState.needsOnboarding = response.needsOnboarding
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
