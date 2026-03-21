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
        ZStack {
            CanovRTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)

                    // Logo
                    VStack(spacing: 8) {
                        Text("CANOVR")
                            .font(.custom("FugazOne-Regular", size: 42))
                            .foregroundStyle(CanovRTheme.primary)

                        Text("Dein intelligenter Trainingsplan")
                            .font(CanovRTheme.bodyFont)
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }

                    Spacer().frame(height: 16)

                    // Strava Button
                    Button {
                        Task { await loginWithStrava() }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 20, weight: .bold))
                            Text("Mit Strava anmelden")
                                .font(.custom("Lato-Bold", size: 17))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.988, green: 0.325, blue: 0.063)) // Strava Orange #FC5200
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(CanovRTheme.textSecondary.opacity(0.3))
                            .frame(height: 1)
                        Text("oder")
                            .font(.custom("Lato-Regular", size: 14))
                            .foregroundStyle(CanovRTheme.textSecondary)
                        Rectangle()
                            .fill(CanovRTheme.textSecondary.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)

                    // Email Login
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Passwort", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)

                        Button {
                            Task { await loginWithEmail() }
                        } label: {
                            Text("Anmelden")
                                .font(.custom("Lato-Bold", size: 17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(CanovRTheme.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1)
                    }
                    .padding(.horizontal, 24)

                    // Error
                    if let error {
                        Text(error)
                            .font(.custom("Lato-Regular", size: 14))
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Register Link
                    Button {
                        showRegister = true
                    } label: {
                        Text("Noch kein Konto? **Registrieren**")
                            .font(.custom("Lato-Regular", size: 15))
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }

                    if isLoading {
                        ProgressView()
                            .tint(CanovRTheme.primary)
                    }

                    Spacer()
                }
            }
        }
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
        } catch is StravaAuthManager.AuthError where (error as? StravaAuthManager.AuthError) == .cancelled {
            // User hat abgebrochen — nichts tun
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
