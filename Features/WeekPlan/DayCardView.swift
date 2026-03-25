import SwiftUI

struct DayCardView: View {
    let day: DayPlan

    var body: some View {
        VStack(alignment: .leading, spacing: CanovRTheme.spacingSM) {
            // Header: Day + Session type
            HStack {
                Text(day.dayName)
                    .font(CanovRTheme.lato(16, weight: .bold))
                    .foregroundStyle(CanovRTheme.textPrimary)
                Spacer()
                SessionTypeBadge(type: day.sessionType)
            }

            if day.sessionType == "rest" {
                Text("Ruhetag")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textTertiary)
            } else {
                // Workout Name
                if let name = day.workoutName {
                    Text(name)
                        .font(CanovRTheme.lato(15))
                        .foregroundStyle(CanovRTheme.textPrimary)
                }

                // Zone + Pace + Volume
                HStack(spacing: CanovRTheme.spacingMD) {
                    if let zone = day.zone, let pace = day.pace {
                        HStack(spacing: CanovRTheme.spacingXS) {
                            Text(zone)
                                .font(CanovRTheme.lato(13, weight: .bold))
                                .foregroundStyle(
                                    CanovRTheme.zoneColor(percentage: day.percentage ?? 100)
                                )
                            Text(pace)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                    }

                    if let volume = day.volume {
                        Text(volume)
                            .font(CanovRTheme.lato(13))
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }

                    Spacer()

                    if day.estimatedKm > 0 {
                        Text("\(day.estimatedKm, specifier: "%.0f") km")
                            .font(CanovRTheme.lato(13, weight: .bold))
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }
                }
            }
        }
        .cardStyle()
    }
}
