import SwiftUI

struct DistanceStepView: View {
    @Binding var selected: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Deine Zieldistanz")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(CanovRTheme.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()),
            ], spacing: 12) {
                ForEach(DistanceOption.all) { option in
                    Button {
                        selected = option.id
                    } label: {
                        VStack(spacing: 6) {
                            Text(option.label)
                                .font(.custom("Lato-Bold", size: 18))
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Text(String(format: "%.1f km", option.km))
                                .font(CanovRTheme.captionFont)
                                .foregroundStyle(CanovRTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            selected == option.id
                                ? CanovRTheme.azure.opacity(0.2)
                                : CanovRTheme.surface
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    selected == option.id ? CanovRTheme.azure : Color.clear,
                                    lineWidth: 2
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding(.horizontal, 24)

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
