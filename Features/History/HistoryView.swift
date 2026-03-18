import SwiftUI
import Charts

struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("", selection: $selectedTab) {
                    Text("Workouts").tag(0)
                    Text("Rennen").tag(1)
                    Text("Pace").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

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
            .navigationTitle("Verlauf")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await appState.loadHistory()
            }
            .refreshable {
                await appState.loadHistory()
            }
        }
    }

    // MARK: - Workouts Tab

    private var workoutsTab: some View {
        LazyVStack(spacing: 8) {
            if let workouts = appState.history?.workouts, !workouts.isEmpty {
                ForEach(workouts) { workout in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.workoutName)
                                .font(.custom("Lato-Regular", size: 15))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(workout.date)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                        Spacer()
                        if let zone = workout.zone {
                            let pct = Int(zone.dropFirst()) ?? 100
                            Text(zone)
                                .font(.custom("Lato-Bold", size: 13))
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
        .padding(.vertical, 8)
    }

    // MARK: - Races Tab

    private var racesTab: some View {
        LazyVStack(spacing: 8) {
            if let races = appState.history?.races, !races.isEmpty {
                ForEach(races) { race in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(DistanceOption.all.first { $0.id == race.distance }?.label ?? race.distance)
                                .font(.custom("Lato-Regular", size: 15))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(race.date)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(formatTime(race.timeSeconds))
                                .font(.custom("Lato-Bold", size: 15))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(race.pace)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundStyle(CanovRTheme.azure)
                        }
                    }
                    .cardStyle()
                }
            } else {
                emptyState(text: "Noch keine Rennergebnisse")
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Pace Chart Tab

    private var paceTab: some View {
        VStack(spacing: 16) {
            if let paces = appState.history?.paceHistory, !paces.isEmpty {
                Chart(paces) { entry in
                    PointMark(
                        x: .value("Datum", entry.date),
                        y: .value("Verbesserung", entry.improvementPct)
                    )
                    .foregroundStyle(CanovRTheme.azure)

                    LineMark(
                        x: .value("Datum", entry.date),
                        y: .value("Verbesserung", entry.improvementPct)
                    )
                    .foregroundStyle(CanovRTheme.azure.opacity(0.5))
                }
                .chartYAxisLabel("Verbesserung %")
                .frame(height: 200)
                .padding(.horizontal, 20)

                ForEach(paces) { pace in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pace.strategy)
                                .font(.custom("Lato-Regular", size: 14))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(pace.date)
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 4) {
                                Text(pace.oldPace)
                                    .foregroundStyle(CanovRTheme.textSecondary)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10))
                                    .foregroundStyle(CanovRTheme.azure)
                                Text(pace.newPace)
                                    .foregroundStyle(CanovRTheme.textPrimary)
                            }
                            .font(.system(size: 13, design: .monospaced))

                            Text(String(format: "%+.1f%%", pace.improvementPct))
                                .font(.custom("Lato-Bold", size: 12))
                                .foregroundStyle(pace.improvementPct > 0 ? CanovRTheme.longRun : .red)
                        }
                    }
                    .cardStyle()
                }
            } else {
                emptyState(text: "Noch keine Pace-Änderungen")
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helpers

    private func emptyState(text: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 36))
                .foregroundStyle(CanovRTheme.textSecondary)
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
