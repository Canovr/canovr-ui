import SwiftUI

struct NameStepView: View {
    @Binding var name: String
    let onNext: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: CanovRTheme.spacingXXL) {
            Spacer()

            Text("Wie heißt du?")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(CanovRTheme.textPrimary)

            TextField("Vorname", text: $name)
                .font(CanovRTheme.lato(28))
                .multilineTextAlignment(.center)
                .foregroundStyle(CanovRTheme.textPrimary)
                .focused($focused)
                .submitLabel(.continue)
                .onSubmit {
                    guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    onNext()
                }

            Spacer()

            let nameEmpty = name.trimmingCharacters(in: .whitespaces).isEmpty
            Button(action: onNext) {
                Text("Weiter")
                    .primaryButtonStyle(disabled: nameEmpty)
            }
            .disabled(nameEmpty)
            .padding(.horizontal, CanovRTheme.spacingXL)
            .padding(.bottom, 48)
        }
        .onAppear { focused = true }
    }
}
