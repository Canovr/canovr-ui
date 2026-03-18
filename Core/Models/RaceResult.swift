import Foundation

// MARK: - Request

struct RaceResultCreate: Codable {
    let date: String          // "YYYY-MM-DD"
    let distance: String
    let timeSeconds: Double
    var notes: String? = nil
}

// MARK: - Response

struct RaceResultResponse: Codable, Identifiable {
    let id: Int
    let date: String
    let distance: String
    let timeSeconds: Double
    let pace: String
    let notes: String?
}
