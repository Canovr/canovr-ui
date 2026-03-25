import Foundation

enum APIEndpoint {
    // Auth
    case stravaAuth(StravaAuthRequest)
    case emailLogin(EmailLoginRequest)
    case emailRegister(EmailRegisterRequest)
    case refreshToken(RefreshTokenRequest)
    case logout(RefreshTokenRequest)
    case getMe

    case deleteAccount

    // Athletes
    case createAthlete(AthleteCreate)
    case getAthlete(Int)
    case updateAthlete(Int, AthleteUpdate)

    // Training
    case generateWeek(Int)
    case completeWorkout(Int, CompleteWorkoutCreate)
    case addRace(Int, RaceResultCreate)
    case getHistory(Int)

    var method: String {
        switch self {
        case .getAthlete, .getHistory, .getMe:
            return "GET"
        case .deleteAccount:
            return "DELETE"
        case .updateAthlete:
            return "PATCH"
        default:
            return "POST"
        }
    }

    var path: String {
        switch self {
        // Auth
        case .stravaAuth:
            return "/api/auth/strava"
        case .emailLogin:
            return "/api/auth/login"
        case .emailRegister:
            return "/api/auth/register"
        case .refreshToken:
            return "/api/auth/refresh"
        case .logout:
            return "/api/auth/logout"
        case .getMe, .deleteAccount:
            return "/api/auth/me"

        // Athletes
        case .createAthlete:
            return "/api/athletes/"
        case .getAthlete(let id):
            return "/api/athletes/\(id)"
        case .updateAthlete(let id, _):
            return "/api/athletes/\(id)"

        // Training
        case .generateWeek(let id):
            return "/api/athletes/\(id)/week"
        case .completeWorkout(let id, _):
            return "/api/athletes/\(id)/complete-workout"
        case .addRace(let id, _):
            return "/api/athletes/\(id)/race"
        case .getHistory(let id):
            return "/api/athletes/\(id)/history"
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .stravaAuth(let data):        return data
        case .emailLogin(let data):        return data
        case .emailRegister(let data):     return data
        case .refreshToken(let data):      return data
        case .logout(let data):            return data
        case .createAthlete(let data):     return data
        case .updateAthlete(_, let data):  return data
        case .completeWorkout(_, let data): return data
        case .addRace(_, let data):        return data
        default:                           return nil
        }
    }

    /// Auth-Endpoints brauchen keinen Bearer Token
    var requiresAuth: Bool {
        switch self {
        case .stravaAuth, .emailLogin, .emailRegister, .refreshToken:
            return false
        default:
            return true
        }
    }
}
