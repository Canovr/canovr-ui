import SwiftUI

struct TodayCardView: View {
    let day: DayPlan
    let onComplete: () -> Void

    private var isHard: Bool {
        ["hard", "moderate", "long_run"].contains(day.sessionType)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Heute")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CanovRTheme.textSecondary)
                Spacer()
                SessionTypeBadge(type: day.sessionType)
            }

            if day.sessionType == "rest" {
                // Ruhetag
                VStack(spacing: 8) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(CanovRTheme.textSecondary)
                    Text("Ruhetag")
                        .font(CanovRTheme.headlineFont)
                        .foregroundStyle(CanovRTheme.textPrimary)
                    Text("Genieß die Pause")
                        .font(CanovRTheme.bodyFont)
                        .foregroundStyle(CanovRTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
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

                HStack(spacing: 16) {
                    if let zone = day.zone, let pace = day.pace {
                        HStack(spacing: 4) {
                            Text(zone)
                                .font(.system(size: 14, weight: .bold))
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
                        Text(String(format: "%.0f km", day.estimatedKm))
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

                Button(action: onComplete) {
                    Text("Erledigt")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CanovRTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(CanovRTheme.azure.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isHard
                ? AnyShapeStyle(CanovRTheme.azureGradient.opacity(0.15))
                : AnyShapeStyle(CanovRTheme.surface)
        )
    }
}
