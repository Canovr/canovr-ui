import SwiftUI
import Charts

struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("", selection: $selectedTab) {
                Text("Workouts").tag(0)
                Text("Rennen").tag(1)
                Text("Pace").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, CanovRTheme.spacingXL)
            .padding(.vertical, CanovRTheme.spacingMD)

            // Content
            ScrollView {
                switch selectedTab {
                case 0:
                    workoutsTab
                case 1:
                    racesTab
                case 2:
                    paceTab
                default:
                    EmptyView()
                }
            }
        }
        .background(CanovRTheme.background)
        .task {
            await appState.loadHistory()
        }
    }

    // MARK: - Workouts Tab

    private var workoutsTab: some View {
        LazyVStack(spacing: CanovRTheme.spacingMD) {
            if let workouts = appState.history?.workouts, !workouts.isEmpty {
                ForEach(workouts) { workout in
                    HStack {
                        VStack(alignment: .leading, spacing: CanovRTheme.spacingXS) {
                            Text(workout.workoutName)
                                .font(CanovRTheme.lato(15))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(workout.date)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textTertiary)
                        }
                        Spacer()
                        if let zone = workout.zone {
                            let pct = Int(zone.dropFirst()) ?? 100
                            Text(zone)
                                .font(CanovRTheme.lato(13, weight: .bold))
                                .foregroundStyle(CanovRTheme.zoneColor(percentage: pct))
                        }
                        if let km = workout.distanceKm {
                            Text(String(format: "%.0f km", km))
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                    }
                    .cardStyle()
                }
            } else {
                emptyState(text: "Noch keine Workouts eingetragen")
            }
        }
        .padding(.vertical, CanovRTheme.spacingSM)
    }

    // MARK: - Races Tab

    private var racesTab: some View {
        LazyVStack(spacing: CanovRTheme.spacingMD) {
            if let races = appState.history?.races, !races.isEmpty {
                ForEach(races) { race in
                    HStack {
                        VStack(alignment: .leading, spacing: CanovRTheme.spacingXS) {
                            Text(DistanceOption.all.first { $0.id == race.distance }?.label ?? race.distance)
                                .font(CanovRTheme.lato(15))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(race.date)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textTertiary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: CanovRTheme.spacingXS) {
                            Text(formatTime(race.timeSeconds))
                                .font(CanovRTheme.lato(15, weight: .bold))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(race.pace)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(CanovRTheme.primary)
                        }
                    }
                    .cardStyle()
                }
            } else {
                emptyState(text: "Noch keine Rennergebnisse")
            }
        }
        .padding(.vertical, CanovRTheme.spacingSM)
    }

    // MARK: - Pace Chart Tab

    private var paceTab: some View {
        VStack(spacing: CanovRTheme.spacingMD) {
            if let paces = appState.history?.paceHistory, !paces.isEmpty {
                Chart(paces) { entry in
                    PointMark(
                        x: .value("Datum", entry.date),
                        y: .value("Verbesserung", entry.improvementPct)
                    )
                    .foregroundStyle(CanovRTheme.primary)

                    LineMark(
                        x: .value("Datum", entry.date),
                        y: .value("Verbesserung", entry.improvementPct)
                    )
                    .foregroundStyle(CanovRTheme.primary.opacity(0.4))
                }
                .chartYAxisLabel("Verbesserung %")
                .frame(height: 200)
                .padding(.horizontal, CanovRTheme.spacingXL)

                ForEach(paces) { pace in
                    HStack {
                        VStack(alignment: .leading, spacing: CanovRTheme.spacingXS) {
                            Text(pace.strategy)
                                .font(CanovRTheme.lato(14))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(pace.date)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textTertiary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: CanovRTheme.spacingXS) {
                            HStack(spacing: CanovRTheme.spacingXS) {
                                Text(pace.oldPace)
                                    .foregroundStyle(CanovRTheme.textTertiary)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                                    .foregroundStyle(CanovRTheme.primary)
                                Text(pace.newPace)
                                    .foregroundStyle(CanovRTheme.textPrimary)
                            }
                            .font(.system(size: 13, design: .monospaced))

                            Text(String(format: "%+.1f%%", pace.improvementPct))
                                .font(CanovRTheme.lato(12, weight: .bold))
                                .foregroundStyle(pace.improvementPct > 0 ? CanovRTheme.primary : CanovRTheme.error)
                        }
                    }
                    .cardStyle()
                }
            } else {
                emptyState(text: "Noch keine Pace-Änderungen")
            }
        }
        .padding(.vertical, CanovRTheme.spacingSM)
    }

    // MARK: - Helpers

    private func emptyState(text: String) -> some View {
        VStack(spacing: CanovRTheme.spacingMD) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(CanovRTheme.textTertiary)
            Text(text)
                .font(CanovRTheme.bodyFont)
                .foregroundStyle(CanovRTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func formatTime(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
