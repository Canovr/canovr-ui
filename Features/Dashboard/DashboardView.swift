import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var showLogWorkout = false
    @State private var showLogRace = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    if let athlete = appState.athlete {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hallo, \(athlete.name)")
                                .font(CanovRTheme.titleFont)
                                .foregroundStyle(.white)

                            PhaseIndicator(
                                phase: athlete.currentPhase,
                                week: athlete.weekInPhase,
                                total: athlete.phaseWeeksTotal
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    }

                    // Today Card
                    if let today = appState.todayWorkout {
                        TodayCardView(day: today) {
                            showLogWorkout = true
                        }
                        .padding(.horizontal, 20)
                    }

                    // Week Overview
                    if let week = appState.currentWeek {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Wochenplan")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(String(format: "%.0f km", week.totalKm))
                                    .font(CanovRTheme.captionFont)
                                    .foregroundStyle(CanovRTheme.textSecondary)
                            }

                            WeekOverviewBar(
                                days: week.days,
                                todayIndex: appState.todayIndex
                            )

                            NavigationLink {
                                WeekPlanView()
                            } label: {
                                Text("Wochenplan anzeigen")
                                    .font(CanovRTheme.captionFont)
                                    .foregroundStyle(CanovRTheme.azure)
                            }
                        }
                        .cardStyle()
                        .padding(.horizontal, 20)

                        // Recommendations
                        if !week.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hinweise")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white)

                                ForEach(week.recommendations, id: \.self) { rec in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(CanovRTheme.azure)
                                            .padding(.top, 2)
                                        Text(rec)
                                            .font(CanovRTheme.captionFont)
                                            .foregroundStyle(CanovRTheme.textSecondary)
                                    }
                                }
                            }
                            .cardStyle()
                            .padding(.horizontal, 20)
                        }
                    }

                    // Quick Actions
                    HStack(spacing: 12) {
                        Button {
                            Task { await appState.loadWeek() }
                        } label: {
                            Label("Neuer Plan", systemImage: "arrow.clockwise")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(CanovRTheme.azure)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(CanovRTheme.azure.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        Button {
                            showLogRace = true
                        } label: {
                            Label("Rennen", systemImage: "trophy.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(CanovRTheme.longRun)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(CanovRTheme.longRun.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
            }
            .background(CanovRTheme.background)
            .refreshable {
                await appState.loadAthlete()
                await appState.loadWeek()
            }
            .sheet(isPresented: $showLogWorkout) {
                LogWorkoutSheet()
            }
            .sheet(isPresented: $showLogRace) {
                LogRaceSheet()
            }
        }
    }
}
