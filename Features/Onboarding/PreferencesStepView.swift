import SwiftUI

struct PreferencesStepView: View {
    @Binding var restDay: Int
    @Binding var longRunDay: Int
    @Binding var hasRace: Bool
    @Binding var raceDate: Date
    let onNext: () -> Void

    private var dayLabels: [String] {
        Calendar.current.shortWeekdaySymbols.map { $0.replacingOccurrences(of: ".", with: "") }
    }

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            Text("Präferenzen")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(CanovRTheme.textPrimary)

            // Rest day
            VStack(spacing: CanovRTheme.spacingMD) {
                Text("Ruhetag")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                DayBubbles(selected: $restDay, labels: dayLabels)
            }

            // Long Run
            VStack(spacing: CanovRTheme.spacingMD) {
                Text("Langer Lauf")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                DayBubbles(selected: $longRunDay, labels: dayLabels)
            }

            // Race
            VStack(spacing: CanovRTheme.spacingMD) {
                Toggle("Wettkampf geplant?", isOn: $hasRace)
                    .tint(CanovRTheme.primary)
                    .foregroundStyle(CanovRTheme.textPrimary)
                    .padding(.horizontal, CanovRTheme.spacingXL)

                if hasRace {
                    DatePicker(
                        "Datum",
                        selection: $raceDate,
                        in: Date.now...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .tint(CanovRTheme.primary)
                    .foregroundStyle(CanovRTheme.textPrimary)
                    .padding(.horizontal, CanovRTheme.spacingXL)
                }
            }

            Spacer()

            Button(action: onNext) {
                Text("Weiter")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, CanovRTheme.spacingXL)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Day Bubbles Component

struct DayBubbles: View {
    @Binding var selected: Int
    let labels: [String]

    var body: some View {
        HStack(spacing: CanovRTheme.spacingSM) {
            ForEach(0..<7, id: \.self) { index in
                Button {
                    selected = index
                } label: {
                    Text(labels[index])
                        .font(CanovRTheme.lato(14, weight: .bold))
                        .foregroundStyle(selected == index ? .white : CanovRTheme.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(
                            selected == index
                                ? CanovRTheme.primary
                                : CanovRTheme.surface
                        )
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    selected == index ? Color.clear : CanovRTheme.border,
                                    lineWidth: 1
                                )
                        )
                }
            }
        }
    }
}
