import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
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
        NavigationStack {
            ScrollView {
                if let athlete = appState.athlete {
                    VStack(spacing: 20) {
                        // Athlete Card
                        VStack(spacing: 12) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 40))
                                .foregroundStyle(CanovRTheme.azure)

                            Text(athlete.name)
                                .font(CanovRTheme.headlineFont)
                                .foregroundStyle(.white)

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
                        .padding(.horizontal, 20)

                        // Pace Zones
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pace-Zonen")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)

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
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text(zoneRoles[pct] ?? "")
                                            .font(.system(size: 11))
                                            .foregroundStyle(CanovRTheme.textSecondary)
                                    }

                                    Spacer()

                                    Text(pace)
                                        .font(CanovRTheme.paceFont)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal, 20)

                        // Actions
                        VStack(spacing: 12) {
                            Button {
                                showEdit = true
                            } label: {
                                Label("Profil bearbeiten", systemImage: "pencil")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                            .tint(CanovRTheme.azure)

                            Button {
                                showServerConfig = true
                            } label: {
                                Label("Server-URL", systemImage: "server.rack")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                            .tint(CanovRTheme.textSecondary)

                            Button(role: .destructive) {
                                appState.reset()
                            } label: {
                                Label("Profil zurücksetzen", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                }
            }
            .background(CanovRTheme.background)
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
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
}

// MARK: - Stat Component

private struct ProfileStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(CanovRTheme.textSecondary)
        }
    }
}
