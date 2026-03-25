import Foundation

// MARK: - Request Models

struct StravaAuthRequest: Codable {
    let code: String
    let state: String
}

struct EmailRegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
}

struct EmailLoginRequest: Codable {
    let email: String
    let password: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

// MARK: - Response Models

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let needsOnboarding: Bool
    let stravaProfile: StravaProfile?
}

struct StravaProfile: Codable {
    let firstName: String
    let lastName: String
}

struct UserInfo: Codable {
    let id: Int
    let email: String?
    let firstName: String?
    let lastName: String?
    let authProvider: String
    let hasAthlete: Bool
    let athleteId: Int?
}

struct StravaStateResponse: Codable {
    let state: String
    let expiresAt: String
}
