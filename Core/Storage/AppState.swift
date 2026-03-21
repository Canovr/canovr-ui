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
    private var pendingCreateKey: String? {
        didSet {
            if let pendingCreateKey {
                UserDefaults.standard.set(pendingCreateKey, forKey: "pendingCreateKey")
            } else {
                UserDefaults.standard.removeObject(forKey: "pendingCreateKey")
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
    var todayCompleted = false

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
        self.pendingCreateKey = UserDefaults.standard.string(forKey: "pendingCreateKey")
    }

    // MARK: - Daten laden

    /// Athlet vom Server laden. Retries bei 429/504 (Cloud Run cold starts). Bei 404 → Reset.
    @MainActor
    func loadAthlete(retries: Int = 3) async {
        guard let id = athleteId else { return }
        isLoading = true
        error = nil

        var lastError: APIError?
        for attempt in 0...retries {
            if attempt > 0 {
                let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
            do {
                athlete = try await api.getAthlete(id)
                lastError = nil
                break
            } catch let err as APIError {
                if case .notFound = err {
                    print("Athlet \(id) nicht auf Server gefunden — Reset")
                    reset()
                    return
                }
                lastError = err
                if case .rateLimited = err { continue }
                if case .upstreamTimeout = err { continue }
                if case .clientTimeout = err { continue }
                break
            } catch {
                lastError = .networkError(error)
                break
            }
        }

        if let lastError {
            self.error = lastError
        }
        isLoading = false
    }

    /// Wochenplan laden mit automatischen Retries bei 429/504 (Cloud Run cold starts).
    @MainActor
    func loadWeek(retries: Int = 3) async {
        guard let id = athleteId else { return }
        isLoadingWeek = true
        error = nil

        var lastError: APIError?
        for attempt in 0...retries {
            if attempt > 0 {
                // Exponential backoff: 2s, 4s, 8s
                let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                try? await Task.sleep(nanoseconds: delay)
            }
            do {
                currentWeek = try await api.generateWeek(id)
                lastError = nil
                break
            } catch let err as APIError {
                lastError = err
                if case .rateLimited = err { continue }
                if case .upstreamTimeout = err { continue }
                if case .clientTimeout = err { continue }
                break // Andere Fehler nicht retrien
            } catch {
                lastError = .networkError(error)
                break
            }
        }

        if let lastError {
            self.error = lastError
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

    private func currentOrCreatePendingCreateKey() -> String {
        if let key = pendingCreateKey, !key.isEmpty {
            return key
        }
        let generated = UUID().uuidString.lowercased()
        pendingCreateKey = generated
        return generated
    }

    /// Athlet anlegen. Onboarding gilt bei erfolgreichem Create als abgeschlossen.
    @MainActor
    func finishOnboarding(_ data: AthleteCreate) async throws {
        isLoading = true
        error = nil

        let idempotencyKey = currentOrCreatePendingCreateKey()

        // 1. Athlet anlegen
        let created: AthleteResponse
        do {
            created = try await api.createAthlete(data, idempotencyKey: idempotencyKey)
            print("Athlet angelegt: id=\(created.id), name=\(created.name)")
        } catch {
            isLoading = false
            print("Fehler beim Anlegen: \(error)")
            throw error
        }

        // 2. Onboarding sofort abschließen
        athleteId = created.id
        athlete = created
        currentWeek = nil
        pendingCreateKey = nil
        isLoading = false

        // 3. Woche entkoppelt im Hintergrund laden (mit Retries für Cold Starts)
        Task { @MainActor in
            await self.loadWeek(retries: 3)
        }
    }

    /// Logout / Reset
    @MainActor
    func reset() {
        athleteId = nil
        pendingCreateKey = nil
        athlete = nil
        currentWeek = nil
        history = nil
        isLoadingWeek = false
        todayCompleted = false
    }
}
