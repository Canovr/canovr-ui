import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthState.self) private var authState
    @State private var showEdit = false
    @State private var showServerConfig = false

    private let zoneRoles: [Int: String] = [
        80: "Basic Endurance",
        85: "General Endurance",
        90: "Supportive Endurance",
        95: "Specific Endurance",
        100: "Race Pace",
        105: "Specific Speed",
        110: "Supportive Speed",
        115: "General Speed",
    ]

    var body: some View {
        ScrollView {
            if let athlete = appState.athlete {
                VStack(spacing: 12) {
                    // Athlete Card
                    VStack(spacing: 12) {
                        HStack {
                            Text(athlete.name)
                                .font(CanovRTheme.headlineFont)
                                .foregroundStyle(CanovRTheme.textPrimary)

                            Spacer()

                            Button {
                                showEdit = true
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(CanovRTheme.textSecondary)
                            }
                        }

                        HStack(spacing: 16) {
                            ProfileStat(
                                label: DistanceOption.all.first { $0.id == athlete.targetDistance }?.label ?? athlete.targetDistance,
                                value: athlete.racePace
                            )
                            ProfileStat(label: "Woche", value: "\(Int(athlete.weeklyKm)) km")
                            ProfileStat(label: "Erfahrung", value: "\(athlete.experienceYears) J.")
                        }

                        PhaseIndicator(
                            phase: athlete.currentPhase,
                            week: athlete.weekInPhase,
                            total: athlete.phaseWeeksTotal
                        )
                    }
                    .cardStyle()

                    // Pace Zones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pace-Zonen")
                            .font(.custom("Lato-Bold", size: 18))
                            .foregroundStyle(CanovRTheme.textPrimary)

                        let sortedZones = athlete.paceZones.sorted { a, b in
                            let aNum = Int(a.key.dropFirst()) ?? 0
                            let bNum = Int(b.key.dropFirst()) ?? 0
                            return aNum < bNum
                        }

                        ForEach(sortedZones, id: \.key) { zone, pace in
                            let pct = Int(zone.dropFirst()) ?? 100
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(CanovRTheme.zoneColor(percentage: pct))
                                    .frame(width: 6, height: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(zone)
                                        .font(.custom("Lato-Bold", size: 15))
                                        .foregroundStyle(CanovRTheme.textPrimary)
                                    Text(zoneRoles[pct] ?? "")
                                        .font(.custom("Lato-Regular", size: 11))
                                        .foregroundStyle(CanovRTheme.textSecondary)
                                }

                                Spacer()

                                Text(pace)
                                    .font(CanovRTheme.paceFont)
                                    .foregroundStyle(CanovRTheme.textPrimary)
                            }
                        }
                    }
                    .cardStyle()

                    // Logout
                    Button(role: .destructive) {
                        Task {
                            await appState.api.logout()
                            await MainActor.run {
                                appState.reset()
                                authState.clearTokens()
                            }
                        }
                    } label: {
                        Label("Abmelden", systemImage: "rectangle.portrait.and.arrow.right")
                            .font(.custom("Lato-Regular", size: 14))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.red.opacity(0.7))
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                .padding(.vertical, 16)
            }
        }
        .background(CanovRTheme.background)
        .sheet(isPresented: $showEdit) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showServerConfig) {
            ServerConfigSheet()
        }
        .refreshable {
            await appState.loadAthlete()
        }
    }
}

// MARK: - Stat Component

private struct ProfileStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Lato-Bold", size: 16))
                .foregroundStyle(CanovRTheme.textPrimary)
            Text(label)
                .font(.custom("Lato-Regular", size: 11))
                .foregroundStyle(CanovRTheme.textSecondary)
        }
    }
}
