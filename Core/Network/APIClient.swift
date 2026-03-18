import Foundation

@Observable
final class APIClient {
    var baseURL: String {
        didSet { UserDefaults.standard.set(baseURL, forKey: "serverURL") }
    }

    init() {
        self.baseURL = UserDefaults.standard.string(forKey: "serverURL")
            ?? "https://canovr-354203175068.europe-west3.run.app"
    }

    // MARK: - Generischer Request

    private func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.timeoutInterval = 60

        if let body = endpoint.body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 404:
            throw APIError.notFound
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

    // MARK: - Athletes

    func createAthlete(_ data: AthleteCreate) async throws -> AthleteResponse {
        try await request(.createAthlete(data))
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
