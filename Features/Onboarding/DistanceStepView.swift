import SwiftUI

struct DistanceStepView: View {
    @Binding var selected: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: CanovRTheme.spacingXXL) {
            Spacer()

            Text("Deine Zieldistanz")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(CanovRTheme.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()),
            ], spacing: CanovRTheme.spacingMD) {
                ForEach(DistanceOption.all) { option in
                    Button {
                        selected = option.id
                    } label: {
                        VStack(spacing: 6) {
                            Text(option.label)
                                .font(CanovRTheme.lato(18, weight: .bold))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(String(format: "%.1f km", option.km))
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            selected == option.id
                                ? CanovRTheme.primaryLight
                                : CanovRTheme.surface
                        )
                        .clipShape(RoundedRectangle(cornerRadius: CanovRTheme.radiusMD))
                        .overlay(
                            RoundedRectangle(cornerRadius: CanovRTheme.radiusMD)
                                .stroke(
                                    selected == option.id ? CanovRTheme.primary : CanovRTheme.border,
                                    lineWidth: selected == option.id ? 2 : 1
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, CanovRTheme.spacingXL)

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
