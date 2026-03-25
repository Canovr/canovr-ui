import SwiftUI

struct WeekPlanView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            if let week = appState.currentWeek {
                VStack(spacing: CanovRTheme.spacingMD) {
                    // Summary Header
                    HStack {
                        PhaseIndicator(
                            phase: week.phase,
                            week: week.weekInPhase,
                            total: week.phaseWeeksTotal
                        )
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(week.totalKm, specifier: "%.0f") km")
                                .font(CanovRTheme.lato(18, weight: .bold))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text("\(week.hardSessions) harte Einheiten")
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, CanovRTheme.spacingXL)

                    // Day Cards
                    ForEach(week.days) { day in
                        DayCardView(day: day)
                    }

                    // Reasoning Trace (expandable)
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: CanovRTheme.spacingXS) {
                            ForEach(week.reasoningTrace, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(CanovRTheme.textTertiary)
                            }
                        }
                    } label: {
                        Text("PyReason-Details")
                            .font(CanovRTheme.captionFont)
                            .foregroundStyle(CanovRTheme.primary)
                    }
                    .tint(CanovRTheme.primary)
                    .cardStyle()
                }
                .padding(.vertical, CanovRTheme.spacingLG)
            } else {
                VStack(spacing: CanovRTheme.spacingLG) {
                    ProgressView()
                        .tint(CanovRTheme.primary)
                    Text("Wochenplan wird geladen...")
                        .font(CanovRTheme.bodyFont)
                        .foregroundStyle(CanovRTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 100)
            }
        }
        .background(CanovRTheme.background)
        .navigationTitle("Wochenplan")
        .navigationBarTitleDisplayMode(.inline)
    }
}
