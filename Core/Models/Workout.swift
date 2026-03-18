import Foundation

// MARK: - Request

struct CompleteWorkoutCreate: Codable {
    let date: String          // "YYYY-MM-DD"
    let workoutKey: String
    var zone: String? = nil
    var distanceKm: Double? = nil
    var durationMinutes: Double? = nil
    var notes: String? = nil
}

// MARK: - Response

struct WorkoutHistoryResponse: Codable, Identifiable {
    let id: Int
    let date: String
    let workoutKey: String
    let workoutName: String
    let zone: String?
    let distanceKm: Double?
    let notes: String?
}
