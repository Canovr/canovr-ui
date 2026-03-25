import SwiftUI

struct WeekOverviewBar: View {
    let days: [DayPlan]
    let todayIndex: Int

    private var dayLabels: [String] {
        Calendar.current.shortWeekdaySymbols.map { $0.replacingOccurrences(of: ".", with: "") }
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(days) { day in
                VStack(spacing: 6) {
                    Circle()
                        .fill(day.dayIndex == todayIndex ? CanovRTheme.primary : CanovRTheme.primaryLight)
                        .frame(width: 32, height: 32)
                        .overlay {
                            if day.sessionType == "rest" {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(
                                        day.dayIndex == todayIndex
                                            ? CanovRTheme.primaryBtnText
                                            : CanovRTheme.textTertiary
                                    )
                            } else if let zone = day.zone {
                                Text(zone.replacingOccurrences(of: "z", with: ""))
                                    .font(CanovRTheme.lato(10, weight: .bold))
                                    .foregroundStyle(
                                        day.dayIndex == todayIndex
                                            ? CanovRTheme.primaryBtnText
                                            : CanovRTheme.textPrimary
                                    )
                            }
                        }

                    Text(dayLabels[day.dayIndex])
                        .font(CanovRTheme.lato(11, weight: day.dayIndex == todayIndex ? .bold : .regular))
                        .foregroundStyle(
                            day.dayIndex == todayIndex
                                ? CanovRTheme.primary
                                : CanovRTheme.textTertiary
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
