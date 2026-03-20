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
    var isLoadingWeek = false
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
    func loadWeek(retries: Int = 3) async {
        guard let id = athleteId else { return }
        isLoadingWeek = true
        error = nil

        for attempt in 1...retries {
            do {
                currentWeek = try await api.generateWeek(id)
                print("Plan geladen (Versuch \(attempt))")
                isLoadingWeek = false
                return
            } catch let err as APIError {
                print("Plan-Fehler Versuch \(attempt)/\(retries): \(err)")
                if attempt == retries {
                    error = err
                }
            } catch {
                print("Plan-Fehler Versuch \(attempt)/\(retries): \(error)")
                if attempt == retries {
                    self.error = .networkError(error)
                }
            }
            // Exponential backoff: 2s, 4s, 8s
            if attempt < retries {
                try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
            }
        }
        isLoadingWeek = false
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

    /// Athlet anlegen und verifizieren. Plan wird im Hintergrund geladen.
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

        // 3. Sofort navigieren — Plan im Hintergrund laden
        athlete = verified
        isLoading = false
        athleteId = verified.id  // triggert Navigation zum Dashboard

        // 4. Plan async laden mit Retry (blockiert Navigation nicht)
        Task { await loadWeek(retries: 3) }
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
