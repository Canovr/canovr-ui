import SwiftUI

struct DashboardView: View {
    @Environment(AppState.self) private var appState
    @State private var showLogWorkout = false
    @State private var showLogRace = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CanovRTheme.spacingMD) {
                    // Error Banner
                    if let error = appState.error {
                        ErrorBanner(message: error.localizedDescription) {
                            appState.error = nil
                        }
                        .padding(.horizontal, CanovRTheme.spacingXL)
                    }

                    // Loading
                    if appState.isLoading {
                        ProgressView()
                            .tint(CanovRTheme.primary)
                            .padding(.top, CanovRTheme.spacingSM)
                    }

                    // Header
                    if let athlete = appState.athlete {
                        VStack(alignment: .leading, spacing: CanovRTheme.spacingSM) {
                            Text("Hallo, \(athlete.name)!")
                                .font(CanovRTheme.titleFont)
                                .foregroundStyle(CanovRTheme.textPrimary)

                            PhaseIndicator(
                                phase: athlete.currentPhase,
                                week: athlete.weekInPhase,
                                total: athlete.phaseWeeksTotal
                            )
                        }
                        .cardStyle()
                    }

                    // Plan loading state
                    if appState.isLoadingWeek && appState.currentWeek == nil {
                        VStack(spacing: CanovRTheme.spacingMD) {
                            ProgressView()
                                .tint(CanovRTheme.primary)
                            Text("Wochenplan wird erstellt...")
                                .font(CanovRTheme.bodyFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                            Text("PyReason berechnet deinen optimalen Plan")
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, CanovRTheme.spacingXXL)
                        .cardStyle()
                    }

                    // Today Card
                    if let today = appState.todayWorkout {
                        TodayCardView(
                            day: today,
                            onComplete: { showLogWorkout = true },
                            isCompleted: appState.todayCompleted
                        )
                    }

                    // Week Overview
                    if let week = appState.currentWeek {
                        VStack(alignment: .leading, spacing: CanovRTheme.spacingMD) {
                            HStack {
                                Text("Wochenplan")
                                    .font(CanovRTheme.lato(16, weight: .bold))
                                    .foregroundStyle(CanovRTheme.textPrimary)
                                Spacer()
                                Text("\(week.totalKm, specifier: "%.0f") km")
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
                                    .foregroundStyle(CanovRTheme.primary)
                            }
                        }
                        .cardStyle()

                        // Recommendations
                        if !week.recommendations.isEmpty {
                            VStack(alignment: .leading, spacing: CanovRTheme.spacingSM) {
                                Text("Hinweise")
                                    .font(CanovRTheme.lato(14, weight: .bold))
                                    .foregroundStyle(CanovRTheme.textPrimary)

                                ForEach(week.recommendations, id: \.self) { rec in
                                    HStack(alignment: .top, spacing: CanovRTheme.spacingSM) {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.system(size: 12))
                                            .foregroundStyle(CanovRTheme.warning)
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
                            .font(CanovRTheme.lato(14, weight: .bold))
                            .foregroundStyle(CanovRTheme.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, CanovRTheme.spacingMD)
                            .background(CanovRTheme.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusMD))
                            .overlay(
                                RoundedRectangle(cornerRadius: CanovRTheme.radiusMD)
                                    .stroke(CanovRTheme.primary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, CanovRTheme.spacingXL)
                }
                .padding(.vertical, CanovRTheme.spacingLG)
            }
            .background(CanovRTheme.background)
            .task {
                if appState.currentWeek == nil {
                    await appState.loadWeek(retries: 3)
                }
            }
            .refreshable {
                appState.todayCompleted = false
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
