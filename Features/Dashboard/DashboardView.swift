import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var showLogWorkout = false
    @State private var showLogRace = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Error Banner
                    if let error = appState.error {
                        ErrorBanner(message: error.localizedDescription) {
                            appState.error = nil
                        }
                        .padding(.horizontal, 20)
                    }

                    // Loading
                    if appState.isLoading {
                        ProgressView()
                            .tint(CanovRTheme.azure)
                            .padding(.top, 8)
                    }

                    // Header
                    if let athlete = appState.athlete {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hallo, \(athlete.name)")
                                .font(CanovRTheme.titleFont)
                                .foregroundStyle(CanovRTheme.textPrimary)

                            PhaseIndicator(
                                phase: athlete.currentPhase,
                                week: athlete.weekInPhase,
                                total: athlete.phaseWeeksTotal
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    }

                    // Plan loading state
                    if appState.isLoadingWeek && appState.currentWeek == nil {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(CanovRTheme.azure)
                            Text("Wochenplan wird erstellt...")
                                .font(CanovRTheme.bodyFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                            Text("PyReason berechnet deinen optimalen Plan")
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .cardStyle()
                    }

                    // Today Card
                    if let today = appState.todayWorkout {
                        TodayCardView(day: today) {
                            showLogWorkout = true
                        }
                    }

                    // Week Overview
                    if let week = appState.currentWeek {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Wochenplan")
                                    .font(.custom("Lato-Bold", size: 16))
                                    .foregroundStyle(CanovRTheme.textPrimary)
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

                        // Recommendations
                        if !week.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Hinweise")
                                    .font(.custom("Lato-Bold", size: 14))
                                    .foregroundStyle(CanovRTheme.textPrimary)

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
                        }
                    }

                    // Quick Actions
                    Button {
                        showLogRace = true
                    } label: {
                        Label("Rennen eintragen", systemImage: "trophy.fill")
                            .font(.custom("Lato-Bold", size: 14))
                            .foregroundStyle(CanovRTheme.longRun)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(CanovRTheme.longRun.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 16)
            }
            .background(CanovRTheme.background)
            .refreshable {
                await appState.loadAthlete()
                await appState.loadWeek(retries: 2)
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
