import AuthenticationServices
import Foundation

@Observable
final class StravaAuthManager: NSObject {
    private let clientId: String
    private let callbackDomain: String

    var isAuthenticating = false

    /// clientId: Strava App Client ID
    /// callbackDomain: Backend-Domain für Universal Link (z.B. "canovr-354203175068.europe-west3.run.app")
    init(clientId: String, callbackDomain: String) {
        self.clientId = clientId
        self.callbackDomain = callbackDomain
    }

    /// Startet den Strava OAuth Flow und gibt den Authorization Code zurück
    @MainActor
    func authenticate() async throws -> String {
        let redirectURI = "https://\(callbackDomain)/auth/strava/callback"
        let scope = "profile:read_all"

        guard var components = URLComponents(string: "https://www.strava.com/oauth/mobile/authorize") else {
            throw AuthError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope),
            URLQueryItem(name: "approval_prompt", value: "auto"),
        ]

        guard let authURL = components.url else {
            throw AuthError.invalidURL
        }

        isAuthenticating = true
        defer { isAuthenticating = false }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: "canovr"
            ) { callbackURL, error in
                if let error {
                    if (error as NSError).code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: AuthError.cancelled)
                    } else {
                        continuation.resume(throwing: AuthError.sessionFailed(error))
                    }
                    return
                }

                guard let callbackURL,
                      let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: AuthError.noCode)
                    return
                }

                continuation.resume(returning: code)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    enum AuthError: LocalizedError {
        case invalidURL
        case cancelled
        case sessionFailed(Error)
        case noCode

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Ungültige Strava-URL"
            case .cancelled: return "Anmeldung abgebrochen"
            case .sessionFailed(let e): return "Strava-Fehler: \(e.localizedDescription)"
            case .noCode: return "Kein Authorization Code von Strava erhalten"
            }
        }
    }
}

extension StravaAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
