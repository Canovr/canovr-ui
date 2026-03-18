import Foundation

@Observable
final class AppState {
    // Persistierter Athlet
    var athleteId: Int? {
        didSet { UserDefaults.standard.set(athleteId, forKey: "athleteId") }
    }

    // Geladene Daten
    var athlete: AthleteResponse?
    var currentWeek: WeeklyPlan?
    var history: HistoryResponse?

    // UI State
    var isLoading = false
    var error: APIError?

    let api: APIClient

    var isOnboarded: Bool { athleteId != nil }

    /// Heutiger Wochentag als day_index (0=Sonntag, 6=Samstag)
    var todayIndex: Int {
        Calendar.current.component(.weekday, from: .now) - 1
    }

    /// Heutiges Workout aus dem aktuellen Wochenplan
    var todayWorkout: DayPlan? {
        currentWeek?.days.first { $0.dayIndex == todayIndex }
    }

    init(api: APIClient = APIClient()) {
        self.api = api
        let stored = UserDefaults.standard.object(forKey: "athleteId") as? Int
        self.athleteId = stored
    }

    // MARK: - Daten laden

    @MainActor
    func loadAthlete() async {
        guard let id = athleteId else { return }
        isLoading = true
        error = nil
        do {
            athlete = try await api.getAthlete(id)
        } catch let err as APIError {
            error = err
        } catch {
            self.error = .networkError(error)
        }
        isLoading = false
    }

    @MainActor
    func loadWeek() async {
        guard let id = athleteId else { return }
        isLoading = true
        error = nil
        do {
            currentWeek = try await api.generateWeek(id)
        } catch let err as APIError {
            error = err
        } catch {
            self.error = .networkError(error)
        }
        isLoading = false
    }

    @MainActor
    func loadHistory() async {
        guard let id = athleteId else { return }
        do {
            history = try await api.getHistory(id)
        } catch let err as APIError {
            error = err
        } catch {
            self.error = .networkError(error)
        }
    }

    /// Onboarding abschließen: Athlet anlegen + Wochenplan laden
    @MainActor
    func finishOnboarding(_ data: AthleteCreate) async throws -> AthleteResponse {
        isLoading = true
        error = nil

        let response: AthleteResponse
        do {
            response = try await api.createAthlete(data)
        } catch {
            isLoading = false
            throw error
        }

        // Athlet steht in der DB — jetzt Plan laden
        athlete = response
        let tempId = response.id

        do {
            currentWeek = try await api.generateWeek(tempId)
        } catch {
            // Plan-Fehler ist nicht kritisch — Athlet existiert
        }

        // Erst JETZT athleteId setzen → triggert Navigation zu MainTabView
        isLoading = false
        athleteId = tempId
        return response
    }

    /// Logout / Reset
    @MainActor
    func reset() {
        athleteId = nil
        athlete = nil
        currentWeek = nil
        history = nil
        UserDefaults.standard.removeObject(forKey: "athleteId")
    }
}
