import SwiftUI

struct TodayCardView: View {
    let day: DayPlan
    let onComplete: () -> Void
    var isCompleted: Bool = false

    private var isHard: Bool {
        ["hard", "moderate", "long_run"].contains(day.sessionType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CanovRTheme.spacingMD) {
            // Header
            HStack {
                Text("Heute")
                    .font(CanovRTheme.lato(13, weight: .bold))
                    .foregroundStyle(CanovRTheme.textTertiary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                SessionTypeBadge(type: day.sessionType)
            }

            if day.sessionType == "rest" {
                // Rest day
                VStack(spacing: CanovRTheme.spacingSM) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(CanovRTheme.textTertiary)
                    Text("Ruhetag")
                        .font(CanovRTheme.headlineFont)
                        .foregroundStyle(CanovRTheme.textPrimary)
                    Text("Genieß die Pause")
                        .font(CanovRTheme.bodyFont)
                        .foregroundStyle(CanovRTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, CanovRTheme.spacingMD)
            } else {
                // Workout
                Text(day.workoutName ?? "Training")
                    .font(CanovRTheme.headlineFont)
                    .foregroundStyle(CanovRTheme.textPrimary)

                if let description = day.description {
                    Text(description)
                        .font(CanovRTheme.bodyFont)
                        .foregroundStyle(CanovRTheme.textSecondary)
                }

                HStack(spacing: CanovRTheme.spacingLG) {
                    if let zone = day.zone, let pace = day.pace {
                        HStack(spacing: CanovRTheme.spacingXS) {
                            Text(zone)
                                .font(CanovRTheme.lato(14, weight: .bold))
                                .foregroundStyle(
                                    CanovRTheme.zoneColor(percentage: day.percentage ?? 100)
                                )
                            PaceDisplay(pace: pace)
                        }
                    }

                    if let volume = day.volume {
                        Text(volume)
                            .font(CanovRTheme.captionFont)
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }

                    if day.estimatedKm > 0 {
                        Text("\(day.estimatedKm, specifier: "%.0f") km")
                            .font(CanovRTheme.captionFont)
                            .foregroundStyle(CanovRTheme.textSecondary)
                    }
                }

                if let zone = day.zone {
                    ZoneBar(
                        highlightedZone: zone,
                        zones: [:]
                    )
                    .frame(height: 28)
                }

                if isCompleted {
                    HStack(spacing: CanovRTheme.spacingSM) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(CanovRTheme.primary)
                        Text("Erledigt")
                            .font(CanovRTheme.lato(16, weight: .bold))
                            .foregroundStyle(CanovRTheme.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, CanovRTheme.spacingMD)
                } else {
                    Button(action: onComplete) {
                        Text("Erledigt")
                            .primaryButtonStyle()
                    }
                    .padding(.top, CanovRTheme.spacingXS)
                }
            }
        }
        .padding(.horizontal, CanovRTheme.spacingXL)
        .padding(.vertical, CanovRTheme.spacingLG)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CanovRTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusLG))
        .overlay(
            RoundedRectangle(cornerRadius: CanovRTheme.radiusLG)
                .stroke(CanovRTheme.border.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, CanovRTheme.spacingXL)
    }
}
