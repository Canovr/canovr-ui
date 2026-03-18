import Foundation

struct HistoryResponse: Codable {
    let workouts: [HistoryWorkout]
    let races: [HistoryRace]
    let paceHistory: [HistoryPace]
}

struct HistoryWorkout: Codable, Identifiable {
    var id: String { "\(date)-\(workoutKey)" }

    let date: String
    let workoutKey: String
    let workoutName: String
    let zone: String?
    let distanceKm: Double?
}

struct HistoryRace: Codable, Identifiable {
    var id: String { "\(date)-\(distance)" }

    let date: String
    let distance: String
    let timeSeconds: Double
    let pace: String
}

struct HistoryPace: Codable, Identifiable {
    var id: String { "\(date)-\(strategy)" }

    let date: String
    let strategy: String
    let oldPace: String
    let newPace: String
    let improvementPct: Double
}
