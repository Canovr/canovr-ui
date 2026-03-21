import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case clientTimeout
    case rateLimited
    case upstreamTimeout
    case httpError(statusCode: Int, body: String?)
    case decodingError(Error)
    case notFound
    case unauthorized
    case serverError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Ungültige Server-URL"
        case .networkError(let error):
            return "Netzwerkfehler: \(error.localizedDescription)"
        case .clientTimeout:
            return "Client-Timeout beim Warten auf die Server-Antwort"
        case .rateLimited:
            return "Zu viele Anfragen (HTTP 429). Bitte kurz warten und erneut versuchen."
        case .upstreamTimeout:
            return "Server-Timeout (HTTP 504). Bitte erneut versuchen."
        case .httpError(let code, _):
            return "Server-Fehler (HTTP \(code))"
        case .decodingError:
            return "Fehler beim Verarbeiten der Server-Antwort"
        case .notFound:
            return "Nicht gefunden"
        case .unauthorized:
            return "Sitzung abgelaufen. Bitte erneut anmelden."
        case .serverError:
            return "Interner Server-Fehler"
        }
    }
}
