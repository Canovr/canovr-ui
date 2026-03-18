import SwiftUI

struct OnboardingSummaryView: View {
    @Environment(AppState.self) private var appState
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

    private let dayLabels = ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Alles klar?")
                    .font(CanovRTheme.titleFont)
                    .foregroundStyle(CanovRTheme.textPrimary)
                    .padding(.top, 24)

                // Summary Card
                VStack(spacing: 16) {
                    SummaryRow(label: "Name", value: data.name)
                    SummaryRow(label: "Zieldistanz", value: distanceLabel)
                    SummaryRow(label: "Bestzeit", value: timeDisplay)
                    SummaryRow(label: "Pace", value: paceDisplay)
                    SummaryRow(label: "Wochenkilometer", value: "\(Int(data.weeklyKm)) km")
                    SummaryRow(label: "Erfahrung", value: data.experienceLevel.rawValue)
                    SummaryRow(label: "Ruhetag", value: dayLabels[data.restDay])
                    SummaryRow(label: "Langer Lauf", value: dayLabels[data.longRunDay])
                    if let days = data.daysToRace {
                        SummaryRow(label: "Wettkampf in", value: "\(days) Tagen")
                    }
                }
                .cardStyle()

                // Zone Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Deine Pace-Zonen")
                        .font(.custom("Lato-Bold", size: 16))
                        .foregroundStyle(CanovRTheme.textPrimary)

                    let zones = computePreviewZones()
                    ForEach(zones, id: \.label) { zone in
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(CanovRTheme.zoneColor(percentage: zone.pct))
                                .frame(width: 6, height: 24)

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
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                    }
                }
                .cardStyle()

                if let error {
                    Text(error)
                        .font(CanovRTheme.captionFont)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                }

                // Create Button
                Button {
                    Task { await createAthlete() }
                } label: {
                    if isCreating {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    } else {
                        Text("Profil erstellen")
                            .font(.custom("Lato-Bold", size: 18))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                }
                .background(CanovRTheme.azureGradient)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .disabled(isCreating)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }

    private func createAthlete() async {
        isCreating = true
        error = nil
        do {
            try await appState.finishOnboarding(data.toAthleteCreate())
            // Navigation passiert automatisch über isOnboarded
        } catch let apiError as APIError {
            self.error = apiError.localizedDescription
        } catch {
            self.error = "Verbindungsfehler: \(error.localizedDescription)"
        }
        isCreating = false
    }

    // MARK: - Zonen-Vorschau berechnen (client-seitig, nur für Preview)

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
            ("z80", 80, "Grundlage"),
            ("z85", 85, "Aerobe Basis"),
            ("z90", 90, "Endurance"),
            ("z95", 95, "Spezifisch"),
            ("z100", 100, "Race Pace"),
            ("z105", 105, "Speed"),
            ("z110", 110, "Intervalle"),
            ("z115", 115, "Strides"),
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
                .font(.custom("Lato-Bold", size: 16))
                .foregroundStyle(CanovRTheme.textPrimary)
        }
    }
}
