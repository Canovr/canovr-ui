import Foundation

@Observable
final class AppState {
    // Persistierter Athlet
    var athleteId: Int? {
        didSet {
            if let athleteId {
                UserDefaults.standard.set(athleteId, forKey: "athleteId")
            } else {
                UserDefaults.standard.removeObject(forKey: "athleteId")
            }
        }
    }

    // Geladene Daten
    var athlete: AthleteResponse?
    var currentWeek: WeeklyPlan?
    var history: HistoryResponse?

    // UI State
    var isLoading = false
    var error: APIError?

    let api: APIClient

    var isOnboarded: Bool { athleteId != nil && athlete != nil }

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

    /// Athlet vom Server laden. Bei 404 → Reset (DB wurde geleert).
    @MainActor
    func loadAthlete() async {
        guard let id = athleteId else { return }
        isLoading = true
        error = nil
        do {
            athlete = try await api.getAthlete(id)
        } catch let err as APIError {
            if case .notFound = err {
                // Server kennt den Athleten nicht mehr → zurück zum Onboarding
                print("Athlet \(id) nicht auf Server gefunden — Reset")
                reset()
            } else {
                error = err
            }
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

    // MARK: - Onboarding

    /// Athlet anlegen, verifizieren, Plan laden. Navigiert NUR bei Erfolg.
    @MainActor
    func finishOnboarding(_ data: AthleteCreate) async throws {
        isLoading = true
        error = nil

        // 1. Athlet anlegen
        let created: AthleteResponse
        do {
            created = try await api.createAthlete(data)
            print("Athlet angelegt: id=\(created.id), name=\(created.name)")
        } catch {
            isLoading = false
            print("Fehler beim Anlegen: \(error)")
            throw error
        }

        // 2. Verifizieren: Athlet wirklich in DB?
        let verified: AthleteResponse
        do {
            verified = try await api.getAthlete(created.id)
            print("Athlet verifiziert: id=\(verified.id)")
        } catch {
            isLoading = false
            print("Athlet NICHT verifiziert: \(error)")
            throw error
        }

        // 3. Plan laden — Versuch, aber nicht blockierend
        do {
            let plan = try await api.generateWeek(verified.id)
            currentWeek = plan
            print("Plan geladen: \(plan.days.count) Tage")
        } catch {
            print("Plan-Fehler (wird auf Dashboard nachgeladen): \(error)")
        }

        // 4. Athlet ist verifiziert — navigieren
        athlete = verified
        isLoading = false
        athleteId = verified.id  // triggert Navigation
    }

    /// Logout / Reset
    @MainActor
    func reset() {
        athleteId = nil
        athlete = nil
        currentWeek = nil
        history = nil
    }
}
