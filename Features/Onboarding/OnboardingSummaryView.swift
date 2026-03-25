import SwiftUI

struct OnboardingSummaryView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthState.self) private var authState
    let data: OnboardingData

    @State private var isCreating = false
    @State private var error: String?

    private var distanceLabel: String {
        DistanceOption.all.first { $0.id == data.targetDistance }?.label ?? data.targetDistance
    }

    private var timeDisplay: String {
        let m = data.raceTimeMinutes
        let s = data.raceTimeSeconds
        return String(format: "%d:%02d", m, s)
    }

    private var paceDisplay: String {
        let km = DistanceOption.all.first { $0.id == data.targetDistance }?.km ?? 10.0
        let paceSeconds = data.raceTimeInSeconds / km
        let m = Int(paceSeconds) / 60
        let s = Int(paceSeconds) % 60
        return String(format: "%d:%02d/km", m, s)
    }

    private var dayLabels: [String] { Calendar.current.weekdaySymbols }

    var body: some View {
        ScrollView {
            VStack(spacing: CanovRTheme.spacingXL) {
                Text("Alles klar?")
                    .font(CanovRTheme.titleFont)
                    .foregroundStyle(CanovRTheme.textPrimary)
                    .padding(.top, CanovRTheme.spacingXL)

                // Summary Card
                VStack(spacing: CanovRTheme.spacingLG) {
                    SummaryRow(label: "Name", value: data.name)
                    SummaryRow(label: "Zieldistanz", value: distanceLabel)
                    SummaryRow(label: "Bestzeit", value: timeDisplay)
                    SummaryRow(label: "Pace", value: paceDisplay)
                    SummaryRow(label: "Wochenkilometer", value: "\(Int(data.weeklyKm)) km")
                    SummaryRow(label: "Erfahrung", value: data.experienceLevel.displayName)
                    SummaryRow(label: "Ruhetag", value: dayLabels[data.restDay])
                    SummaryRow(label: "Langer Lauf", value: dayLabels[data.longRunDay])
                    if let days = data.daysToRace {
                        SummaryRow(label: "Wettkampf in", value: "\(days) Tagen")
                    }
                }
                .cardStyle()

                // Zone Preview
                VStack(alignment: .leading, spacing: CanovRTheme.spacingMD) {
                    Text("Deine Pace-Zonen")
                        .font(CanovRTheme.lato(16, weight: .bold))
                        .foregroundStyle(CanovRTheme.textPrimary)

                    let zones = computePreviewZones()
                    ForEach(zones, id: \.label) { zone in
                        HStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(CanovRTheme.zoneColor(percentage: zone.pct))
                                .frame(width: 4, height: 24)

                            Text(zone.label)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                                .frame(width: 40, alignment: .leading)

                            Text(zone.pace)
                                .font(CanovRTheme.paceFont)
                                .foregroundStyle(CanovRTheme.textPrimary)

                            Spacer()

                            Text(zone.role)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textTertiary)
                        }
                    }
                }
                .cardStyle()

                if let error {
                    Text(error)
                        .font(CanovRTheme.captionFont)
                        .foregroundStyle(CanovRTheme.error)
                        .padding(.horizontal, CanovRTheme.spacingXL)
                }

                // Create Button
                Button {
                    Task { await createAthlete() }
                } label: {
                    if isCreating {
                        ProgressView()
                            .tint(.white)
                            .primaryButtonStyle()
                    } else {
                        Text("Profil erstellen")
                            .primaryButtonStyle()
                    }
                }
                .disabled(isCreating)
                .padding(.horizontal, CanovRTheme.spacingXL)
                .padding(.bottom, 48)
            }
        }
    }

    private func createAthlete() async {
        print("=== ONBOARDING: Profil erstellen gestartet ===")
        print("Name: \(data.name), Distanz: \(data.targetDistance), Zeit: \(data.raceTimeInSeconds)s")
        print("Server: \(appState.api.baseURL)")
        isCreating = true
        error = nil
        do {
            try await appState.finishOnboarding(data.toAthleteCreate())
            await MainActor.run {
                authState.needsOnboarding = false
            }
            print("=== ONBOARDING: Erfolgreich! ===")
        } catch let apiError as APIError {
            print("=== ONBOARDING FEHLER (API): \(apiError) ===")
            self.error = "API-Fehler: \(apiError.localizedDescription)"
        } catch {
            print("=== ONBOARDING FEHLER: \(error) ===")
            self.error = "Fehler: \(error.localizedDescription)"
        }
        isCreating = false
    }

    // MARK: - Zone preview (client-side, preview only)

    private struct ZonePreview {
        let label: String
        let pct: Int
        let pace: String
        let role: String
    }

    private func computePreviewZones() -> [ZonePreview] {
        let km = DistanceOption.all.first { $0.id == data.targetDistance }?.km ?? 10.0
        let racePaceSeconds = data.raceTimeInSeconds / km

        let zones: [(String, Int, String)] = [
            ("z80", 80, String(localized: "Grundlage")),
            ("z85", 85, String(localized: "Aerobe Basis")),
            ("z90", 90, String(localized: "Endurance")),
            ("z95", 95, String(localized: "Spezifisch")),
            ("z100", 100, String(localized: "Race Pace")),
            ("z105", 105, String(localized: "Speed")),
            ("z110", 110, String(localized: "Intervalle")),
            ("z115", 115, String(localized: "Strides")),
        ]

        return zones.map { label, pct, role in
            let pace = racePaceSeconds / (Double(pct) / 100.0)
            let m = Int(pace) / 60
            let s = Int(pace) % 60
            return ZonePreview(label: label, pct: pct, pace: String(format: "%d:%02d/km", m, s), role: role)
        }
    }
}

// MARK: - Summary Row

private struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(CanovRTheme.bodyFont)
                .foregroundStyle(CanovRTheme.textSecondary)
            Spacer()
            Text(value)
                .font(CanovRTheme.lato(16, weight: .bold))
                .foregroundStyle(CanovRTheme.textPrimary)
        }
    }
}
