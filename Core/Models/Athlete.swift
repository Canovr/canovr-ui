import Foundation

// MARK: - Request Models

struct AthleteCreate: Codable {
    let name: String
    let targetDistance: String
    let raceTimeSeconds: Double
    let weeklyKm: Double
    let experienceYears: Int
    var currentPhase: String = "general"
    var weekInPhase: Int = 1
    var phaseWeeksTotal: Int = 8
    var restDay: Int? = nil
    var longRunDay: Int? = nil
    var daysToRace: Int? = nil
}

struct AthleteUpdate: Codable {
    var name: String? = nil
    var targetDistance: String? = nil
    var raceTimeSeconds: Double? = nil
    var weeklyKm: Double? = nil
    var experienceYears: Int? = nil
    var currentPhase: String? = nil
    var weekInPhase: Int? = nil
    var phaseWeeksTotal: Int? = nil
    var restDay: Int? = nil
    var longRunDay: Int? = nil
    var daysToRace: Int? = nil
}

// MARK: - Response Model

struct AthleteResponse: Codable, Identifiable {
    let id: Int
    let name: String
    let targetDistance: String
    let raceTimeSeconds: Double
    let racePace: String
    let weeklyKm: Double
    let experienceYears: Int
    let currentPhase: String
    let weekInPhase: Int
    let phaseWeeksTotal: Int
    let restDay: Int?
    let longRunDay: Int?
    let daysToRace: Int?
    let paceZones: [String: String]
}
