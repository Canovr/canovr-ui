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
            ScrollView {
                VStack(spacing: CanovRTheme.spacingXL) {
                    // Logo
                    Text("CANOVR")
                        .font(.custom("FugazOne-Regular", size: 32))
                        .foregroundStyle(CanovRTheme.primary)
                        .padding(.top, CanovRTheme.spacingXXL)

                    Text("Konto erstellen")
                        .font(CanovRTheme.headlineFont)
                        .foregroundStyle(CanovRTheme.textPrimary)

                    VStack(spacing: CanovRTheme.spacingMD) {
                        TextField("", text: $name, prompt: Text("Name").foregroundColor(CanovRTheme.placeholder))
                            .inputStyle()
                            .textContentType(.name)

                        TextField("", text: $email, prompt: Text("Email").foregroundColor(CanovRTheme.placeholder))
                            .inputStyle()
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("", text: $password, prompt: Text("Passwort (min. 8 Zeichen)").foregroundColor(CanovRTheme.placeholder))
                            .inputStyle()
                            .textContentType(.newPassword)

                        SecureField("", text: $confirmPassword, prompt: Text("Passwort bestätigen").foregroundColor(CanovRTheme.placeholder))
                            .inputStyle()
                            .textContentType(.newPassword)

                        if !password.isEmpty && !confirmPassword.isEmpty && password != confirmPassword {
                            Text("Passwörter stimmen nicht überein")
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.error)
                        }
                    }
                    .padding(.horizontal, CanovRTheme.spacingXL)

                    if let error {
                        Text(error)
                            .font(CanovRTheme.lato(14))
                            .foregroundStyle(CanovRTheme.error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CanovRTheme.spacingXL)
                    }

                    Button {
                        Task { await register() }
                    } label: {
                        Text("Registrieren")
                            .primaryButtonStyle(disabled: !isValid || isLoading)
                    }
                    .disabled(!isValid || isLoading)
                    .padding(.horizontal, CanovRTheme.spacingXL)

                    if isLoading {
                        ProgressView()
                            .tint(CanovRTheme.primary)
                    }

                    Spacer()
                }
            }
            .background(CanovRTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundStyle(CanovRTheme.primary)
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
                authState.registeredName = name
                authState.needsOnboarding = true
                dismiss()
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
