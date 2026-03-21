import Foundation

@Observable
final class AuthState {
    var accessToken: String?
    var refreshToken: String?
    var needsOnboarding: Bool = false
    var stravaProfile: StravaProfile?

    var isAuthenticated: Bool { accessToken != nil }

    init() {
        self.accessToken = KeychainManager.get(for: "accessToken")
        self.refreshToken = KeychainManager.get(for: "refreshToken")
    }

    func setTokens(access: String, refresh: String) {
        accessToken = access
        refreshToken = refresh
        KeychainManager.save(access, for: "accessToken")
        KeychainManager.save(refresh, for: "refreshToken")
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        stravaProfile = nil
        needsOnboarding = false
        KeychainManager.deleteAll()
    }
}
