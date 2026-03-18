import SwiftUI

struct WeekPlanView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ScrollView {
            if let week = appState.currentWeek {
                VStack(spacing: 16) {
                    // Summary Header
                    HStack {
                        PhaseIndicator(
                            phase: week.phase,
                            week: week.weekInPhase,
                            total: week.phaseWeeksTotal
                        )
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.0f km", week.totalKm))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text("\(week.hardSessions) harte Einheiten")
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Day Cards
                    ForEach(week.days) { day in
                        DayCardView(day: day)
                    }

                    // Reasoning Trace (expandable)
                    DisclosureGroup {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(week.reasoningTrace, id: \.self) { line in
                                Text(line)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(CanovRTheme.textSecondary)
                            }
                        }
                    } label: {
                        Text("PyReason-Details")
                            .font(CanovRTheme.captionFont)
                            .foregroundStyle(CanovRTheme.azure)
                    }
                    .tint(CanovRTheme.azure)
                    .cardStyle()
                }
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(CanovRTheme.azure)
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
