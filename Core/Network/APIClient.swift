import Foundation

@Observable
final class APIClient {
    private let requestTimeout: TimeInterval = 300
    private weak var authState: AuthState?

    var baseURL: String {
        didSet { UserDefaults.standard.set(baseURL, forKey: "serverURL") }
    }

    init(authState: AuthState? = nil) {
        self.baseURL = UserDefaults.standard.string(forKey: "serverURL")
            ?? "https://canovr-354203175068.europe-west3.run.app"
        self.authState = authState
    }

    func setAuthState(_ authState: AuthState) {
        self.authState = authState
    }

    // MARK: - Generischer Request

    private func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        headers extraHeaders: [String: String] = [:],
        skipTokenRefresh: Bool = false
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.timeoutInterval = requestTimeout

        if let body = endpoint.body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        // Auth Header
        if endpoint.requiresAuth, let token = authState?.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        for (field, value) in extraHeaders {
            request.setValue(value, forHTTPHeaderField: field)
        }

        print(">>> [\(endpoint.method)] \(baseURL + endpoint.path)")
        if let body = request.httpBody, let json = String(data: body, encoding: .utf8) {
            print(">>> BODY: \(json.prefix(500))")
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError where error.code == .timedOut {
            print(">>> CLIENT TIMEOUT: \(error)")
            throw APIError.clientTimeout
        } catch {
            print(">>> NETWORK ERROR: \(error)")
            throw APIError.networkError(error)
        }

        if let httpResponse = response as? HTTPURLResponse {
            print(">>> RESPONSE: \(httpResponse.statusCode)")
            if let body = String(data: data, encoding: .utf8)?.prefix(500) {
                print(">>> DATA: \(body)")
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }

        // 401 → Token Refresh versuchen
        if httpResponse.statusCode == 401 && endpoint.requiresAuth && !skipTokenRefresh {
            if try await attemptTokenRefresh() {
                // Retry mit neuem Token
                return try await self.request(endpoint, headers: extraHeaders, skipTokenRefresh: true)
            }
            throw APIError.unauthorized
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimited
        case 504:
            throw APIError.upstreamTimeout
        default:
            let body = String(data: data, encoding: .utf8)
            throw APIError.httpError(statusCode: httpResponse.statusCode, body: body)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Token Refresh

    private func attemptTokenRefresh() async throws -> Bool {
        guard let refreshToken = authState?.refreshToken else {
            return false
        }

        do {
            let response: AuthResponse = try await request(
                .refreshToken(RefreshTokenRequest(refreshToken: refreshToken)),
                skipTokenRefresh: true
            )
            await MainActor.run {
                authState?.setTokens(access: response.accessToken, refresh: response.refreshToken)
            }
            return true
        } catch {
            // Refresh fehlgeschlagen → Logout
            await MainActor.run {
                authState?.clearTokens()
            }
            return false
        }
    }

    // MARK: - Auth

    func stravaAuth(code: String) async throws -> AuthResponse {
        try await request(.stravaAuth(StravaAuthRequest(code: code)))
    }

    func emailLogin(email: String, password: String) async throws -> AuthResponse {
        try await request(.emailLogin(EmailLoginRequest(email: email, password: password)))
    }

    func emailRegister(email: String, password: String, name: String) async throws -> AuthResponse {
        try await request(.emailRegister(EmailRegisterRequest(email: email, password: password, name: name)))
    }

    func logout() async {
        guard let refreshToken = authState?.refreshToken else { return }
        _ = try? await request(
            .logout(RefreshTokenRequest(refreshToken: refreshToken))
        ) as [String: String]
    }

    func getMe() async throws -> UserInfo {
        try await request(.getMe)
    }

    // MARK: - Athletes

    func createAthlete(
        _ data: AthleteCreate,
        idempotencyKey: String? = nil
    ) async throws -> AthleteResponse {
        var headers: [String: String] = [:]
        if let idempotencyKey, !idempotencyKey.isEmpty {
            headers["X-Idempotency-Key"] = idempotencyKey
        }
        return try await request(.createAthlete(data), headers: headers)
    }

    func getAthlete(_ id: Int) async throws -> AthleteResponse {
        try await request(.getAthlete(id))
    }

    func updateAthlete(_ id: Int, _ data: AthleteUpdate) async throws -> AthleteResponse {
        try await request(.updateAthlete(id, data))
    }

    // MARK: - Training

    func generateWeek(_ athleteId: Int) async throws -> WeeklyPlan {
        try await request(.generateWeek(athleteId))
    }

    func completeWorkout(_ athleteId: Int, _ data: CompleteWorkoutCreate) async throws -> WorkoutHistoryResponse {
        try await request(.completeWorkout(athleteId, data))
    }

    func addRace(_ athleteId: Int, _ data: RaceResultCreate) async throws -> RaceResultResponse {
        try await request(.addRace(athleteId, data))
    }

    func getHistory(_ athleteId: Int) async throws -> HistoryResponse {
        try await request(.getHistory(athleteId))
    }
}

// MARK: - Type-Erased Encodable Wrapper

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        _encode = { encoder in try value.encode(to: encoder) }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
