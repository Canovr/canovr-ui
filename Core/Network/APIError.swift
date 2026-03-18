import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case httpError(statusCode: Int, body: String?)
    case decodingError(Error)
    case notFound
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige Server-URL"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .httpError(let code, _):
            return "Server-Fehler (HTTP \(code))"
        case .decodingError:
            return "Fehler beim Verarbeiten der Server-Antwort"
        case .notFound:
            return "Nicht gefunden"
        case .serverError:
            return "Interner Server-Fehler"
        }
    }
}
