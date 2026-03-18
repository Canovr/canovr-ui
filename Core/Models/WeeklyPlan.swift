import Foundation

struct DayPlan: Codable, Identifiable {
    var id: Int { dayIndex }

    let dayIndex: Int
    let dayName: String
    let sessionType: String
    let workoutKey: String?
    let workoutName: String?
    let description: String?
    let zone: String?
    let percentage: Int?
    let pace: String?
    let volume: String?
    let estimatedKm: Double
    let scoringReason: String?
}

struct WeeklyPlan: Codable {
    let phase: String
    let weekInPhase: Int
    let phaseWeeksTotal: Int
    let progressionPct: Double
    let totalKm: Double
    let hardSessions: Int
    let days: [DayPlan]
    let reasoningTrace: [String]
    let recommendations: [String]
}
