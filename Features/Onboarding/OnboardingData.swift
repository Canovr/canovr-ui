import Foundation

/// Collects all inputs across onboarding steps.
@Observable
final class OnboardingData {
    var name: String = ""
    var targetDistance: String = "10k"
    var raceTimeMinutes: Int = 50
    var raceTimeSeconds: Int = 0
    var weeklyKm: Double = 40
    var experienceLevel: ExperienceLevel = .intermediate
    var restDay: Int = 1         // 0=Sun, 1=Mon ... 6=Sat
    var longRunDay: Int = 0      // Sunday
    var hasUpcomingRace: Bool = false
    var raceDate: Date = Calendar.current.date(byAdding: .day, value: 56, to: .now)!

    enum ExperienceLevel: String, CaseIterable {
        case beginner
        case intermediate
        case experienced

        var displayName: String {
            switch self {
            case .beginner:     return String(localized: "Einsteiger")
            case .intermediate: return String(localized: "Fortgeschritten")
            case .experienced:  return String(localized: "Erfahren")
            }
        }

        var years: Int {
            switch self {
            case .beginner: return 0
            case .intermediate: return 3
            case .experienced: return 7
            }
        }
    }

    var raceTimeInSeconds: Double {
        Double(raceTimeMinutes * 60 + raceTimeSeconds)
    }

    var daysToRace: Int? {
        guard hasUpcomingRace else { return nil }
        return max(0, Calendar.current.dateComponents([.day], from: .now, to: raceDate).day ?? 0)
    }

    var defaultMinutes: Int {
        switch targetDistance {
        case "800m": return 3
        case "1500m": return 6
        case "mile": return 7
        case "3k": return 14
        case "5k": return 25
        case "10k": return 50
        case "half_marathon": return 110
        case "marathon": return 240
        default: return 50
        }
    }

    func toAthleteCreate() -> AthleteCreate {
        AthleteCreate(
            name: name,
            targetDistance: targetDistance,
            raceTimeSeconds: raceTimeInSeconds,
            weeklyKm: weeklyKm,
            experienceYears: experienceLevel.years,
            currentPhase: "general",
            weekInPhase: 1,
            phaseWeeksTotal: 8,
            restDay: restDay,
            longRunDay: longRunDay,
            daysToRace: daysToRace
        )
    }
}

/// Distance options for picker
struct DistanceOption: Identifiable {
    let id: String
    let label: String
    let km: Double

    static let all: [DistanceOption] = [
        .init(id: "800m", label: "800 m", km: 0.8),
        .init(id: "1500m", label: "1500 m", km: 1.5),
        .init(id: "mile", label: String(localized: "Meile"), km: 1.609),
        .init(id: "3k", label: "3 km", km: 3.0),
        .init(id: "5k", label: "5 km", km: 5.0),
        .init(id: "10k", label: "10 km", km: 10.0),
        .init(id: "half_marathon", label: String(localized: "Halbmarathon"), km: 21.1),
        .init(id: "marathon", label: "Marathon", km: 42.2),
    ]
}
