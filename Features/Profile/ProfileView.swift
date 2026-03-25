import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthState.self) private var authState
    @State private var showEdit = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false

    private var zoneRoles: [Int: String] {
        [
            80: String(localized: "Basic Endurance"),
            85: String(localized: "General Endurance"),
            90: String(localized: "Supportive Endurance"),
            95: String(localized: "Specific Endurance"),
            100: String(localized: "Race Pace"),
            105: String(localized: "Specific Speed"),
            110: String(localized: "Supportive Speed"),
            115: String(localized: "General Speed"),
        ]
    }

    var body: some View {
        ScrollView {
            if let athlete = appState.athlete {
                VStack(spacing: CanovRTheme.spacingMD) {
                    // Athlete Card
                    VStack(spacing: CanovRTheme.spacingMD) {
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
                                    .foregroundStyle(CanovRTheme.textTertiary)
                            }
                        }

                        HStack(spacing: CanovRTheme.spacingLG) {
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
                    VStack(alignment: .leading, spacing: CanovRTheme.spacingMD) {
                        Text("Pace-Zonen")
                            .font(CanovRTheme.headlineFont)
                            .foregroundStyle(CanovRTheme.textPrimary)

                        let sortedZones = athlete.paceZones.sorted { a, b in
                            let aNum = Int(a.key.dropFirst()) ?? 0
                            let bNum = Int(b.key.dropFirst()) ?? 0
                            return aNum < bNum
                        }

                        ForEach(sortedZones, id: \.key) { zone, pace in
                            let pct = Int(zone.dropFirst()) ?? 100
                            HStack(spacing: CanovRTheme.spacingMD) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(CanovRTheme.zoneColor(percentage: pct))
                                    .frame(width: 4, height: 36)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(zone)
                                        .font(CanovRTheme.lato(15, weight: .bold))
                                        .foregroundStyle(CanovRTheme.textPrimary)
                                    Text(zoneRoles[pct] ?? "")
                                        .font(CanovRTheme.lato(11))
                                        .foregroundStyle(CanovRTheme.textTertiary)
                                }

                                Spacer()

                                Text(pace)
                                    .font(CanovRTheme.paceFont)
                                    .foregroundStyle(CanovRTheme.textPrimary)
                            }
                        }
                    }
                    .cardStyle()

                    // Legal Links
                    HStack(spacing: CanovRTheme.spacingLG) {
                        if let privacyURL = URL(string: appState.api.baseURL + "/privacy") {
                            Link("Datenschutz", destination: privacyURL)
                        }
                        if let impressumURL = URL(string: appState.api.baseURL + "/impressum") {
                            Link("Impressum", destination: impressumURL)
                        }
                    }
                    .font(CanovRTheme.lato(12))
                    .foregroundStyle(CanovRTheme.textTertiary)

                    // Logout & Account-Löschung
                    VStack(spacing: CanovRTheme.spacingSM) {
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
                                .font(CanovRTheme.lato(14))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CanovRTheme.error.opacity(0.7))

                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Account löschen", systemImage: "trash")
                                .font(CanovRTheme.lato(12))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(CanovRTheme.textTertiary)
                        .disabled(isDeleting)
                    }
                    .padding(.horizontal, CanovRTheme.spacingXL)
                    .padding(.top, CanovRTheme.spacingSM)
                }
                .padding(.vertical, CanovRTheme.spacingLG)
            }
        }
        .background(CanovRTheme.background)
        .sheet(isPresented: $showEdit) {
            EditProfileSheet()
        }
        .alert("Account löschen?", isPresented: $showDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) { }
            Button("Unwiderruflich löschen", role: .destructive) {
                Task {
                    isDeleting = true
                    do {
                        try await appState.api.deleteAccount()
                    } catch {
                        #if DEBUG
                        print("Account-Löschung fehlgeschlagen.")
                        #endif
                    }
                    await MainActor.run {
                        appState.reset()
                        authState.clearTokens()
                        isDeleting = false
                    }
                }
            }
        } message: {
            Text("Dein Account und alle Trainingsdaten werden unwiderruflich gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.")
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
        VStack(spacing: CanovRTheme.spacingXS) {
            Text(value)
                .font(CanovRTheme.lato(16, weight: .bold))
                .foregroundStyle(CanovRTheme.textPrimary)
            Text(label)
                .font(CanovRTheme.lato(11))
                .foregroundStyle(CanovRTheme.textTertiary)
        }
    }
}
