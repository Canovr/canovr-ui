import SwiftUI

struct RegisterView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthState.self) private var authState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var error: String?

    private var isValid: Bool {
        !name.isEmpty && !email.isEmpty && password.count >= 8 && password == confirmPassword
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CanovRTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 20)

                        Text("Konto erstellen")
                            .font(CanovRTheme.headlineFont)
                            .foregroundStyle(CanovRTheme.textPrimary)

                        VStack(spacing: 16) {
                            TextField("Name", text: $name)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.name)

                            TextField("Email", text: $email)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)

                            SecureField("Passwort (min. 8 Zeichen)", text: $password)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.newPassword)

                            SecureField("Passwort bestätigen", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.newPassword)

                            if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwörter stimmen nicht überein")
                                    .font(.custom("Lato-Regular", size: 13))
                                    .foregroundStyle(.red)
                            }
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

                        Button {
                            Task { await register() }
                        } label: {
                            Text("Registrieren")
                                .font(.custom("Lato-Bold", size: 17))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(isValid ? CanovRTheme.primary : CanovRTheme.primary.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(!isValid || isLoading)
                        .padding(.horizontal, 24)

                        if isLoading {
                            ProgressView()
                                .tint(CanovRTheme.primary)
                        }

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }

    private func register() async {
        isLoading = true
        error = nil

        do {
            let response = try await appState.api.emailRegister(
                email: email,
                password: password,
                name: name
            )
            await MainActor.run {
                authState.setTokens(access: response.accessToken, refresh: response.refreshToken)
                authState.needsOnboarding = true
                dismiss()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
