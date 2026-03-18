import SwiftUI

struct DayCardView: View {
    let day: DayPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Tag + Session-Typ
            HStack {
                Text(day.dayName)
                    .font(.custom("Lato-Bold", size: 16))
                    .foregroundStyle(CanovRTheme.textPrimary)
                Spacer()
                SessionTypeBadge(type: day.sessionType)
            }

            if day.sessionType == "rest" {
                Text("Ruhetag")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)
            } else {
                // Workout Name
                if let name = day.workoutName {
                    Text(name)
                        .font(.custom("Lato-Regular", size: 15))
                        .foregroundStyle(CanovRTheme.textPrimary)
                }

                // Zone + Pace + Volume
                HStack(spacing: 12) {
                    if let zone = day.zone, let pace = day.pace {
                        HStack(spacing: 4) {
                            Text(zone)
                                .font(.custom("Lato-Bold", size: 13))
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
                            .font(.custom("Lato-Regular", size: 13))
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }

                    Spacer()

                    if day.estimatedKm > 0 {
                        Text(String(format: "%.0f km", day.estimatedKm))
                            .font(.custom("Lato-Bold", size: 13))
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }
                }
            }
        }
        .cardStyle()
    }
}
