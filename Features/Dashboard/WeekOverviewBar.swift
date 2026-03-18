import SwiftUI

struct WeekOverviewBar: View {
    let days: [DayPlan]
    let todayIndex: Int

    private let dayLabels = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                VStack(spacing: 6) {
                    // Punkt
                    Circle()
                        .fill(CanovRTheme.sessionColor(day.sessionType))
                        .frame(width: 32, height: 32)
                        .overlay {
                            if day.sessionType == "rest" {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(CanovRTheme.textSecondary)
                            } else if let zone = day.zone {
                                Text(zone.replacingOccurrences(of: "z", with: ""))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .overlay {
                            if day.dayIndex == todayIndex {
                                Circle()
                                    .stroke(CanovRTheme.azure, lineWidth: 2)
                                    .frame(width: 38, height: 38)
                            }
                        }

                    // Tag-Label
                    Text(dayLabels[day.dayIndex])
                        .font(.system(size: 11, weight: day.dayIndex == todayIndex ? .bold : .regular))
                        .foregroundStyle(
                            day.dayIndex == todayIndex
                                ? CanovRTheme.azure
                                : CanovRTheme.textSecondary
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
