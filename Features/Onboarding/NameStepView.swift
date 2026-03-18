import SwiftUI

struct NameStepView: View {
    @Binding var name: String
    let onNext: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Wie heißt du?")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(.white)

            TextField("Vorname", text: $name)
                .font(.system(size: 28, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .focused($focused)
                .submitLabel(.continue)
                .onSubmit {
                    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    onNext()
                }

            Spacer()

            Button(action: onNext) {
                Text("Weiter")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color.gray.opacity(0.3)
                            : CanovRTheme.azure
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .onAppear { focused = true }
    }
}
