import SwiftUI

struct PreferencesStepView: View {
    @Binding var restDay: Int
    @Binding var longRunDay: Int
    @Binding var hasRace: Bool
    @Binding var raceDate: Date
    let onNext: () -> Void

    private let dayLabels = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"]

    var body: some View {
        VStack(spacing: 36) {
            Spacer()

            Text("Präferenzen")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(CanovRTheme.textPrimary)

            // Ruhetag
            VStack(spacing: 12) {
                Text("Ruhetag")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                DayBubbles(selected: $restDay, labels: dayLabels)
            }

            // Long Run
            VStack(spacing: 12) {
                Text("Langer Lauf")
                    .font(CanovRTheme.bodyFont)
                    .foregroundStyle(CanovRTheme.textSecondary)

                DayBubbles(selected: $longRunDay, labels: dayLabels)
            }

            // Wettkampf
            VStack(spacing: 12) {
                Toggle("Wettkampf geplant?", isOn: $hasRace)
                    .tint(CanovRTheme.azure)
                    .foregroundStyle(CanovRTheme.textPrimary)
                    .padding(.horizontal, 24)

                if hasRace {
                    DatePicker(
                        "Datum",
                        selection: $raceDate,
                        in: Date.now...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .tint(CanovRTheme.azure)
                    .foregroundStyle(CanovRTheme.textPrimary)
                    .padding(.horizontal, 24)
                }
            }

            Spacer()

            Button(action: onNext) {
                Text("Weiter")
                    .font(.custom("Lato-Bold", size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CanovRTheme.azure)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

// MARK: - Day Bubbles Component

struct DayBubbles: View {
    @Binding var selected: Int
    let labels: [String]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7, id: \.self) { index in
                Button {
                    selected = index
                } label: {
                    Text(labels[index])
                        .font(.custom("Lato-Bold", size: 14))
                        .foregroundStyle(selected == index ? .white : CanovRTheme.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(
                            selected == index
                                ? CanovRTheme.azure
                                : CanovRTheme.surface
                        )
                        .clipShape(Circle())
                }
            }
        }
    }
}
