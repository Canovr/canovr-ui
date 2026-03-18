import SwiftUI

struct ServerConfigSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var url = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Server-URL") {
                    TextField("https://...", text: $url)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }

                Section {
                    Text("Die App verbindet sich mit dem CanovR-Backend. Gib die Server-URL ein.")
                        .font(CanovRTheme.captionFont)
                        .foregroundStyle(CanovRTheme.textSecondary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(CanovRTheme.background)
            .navigationTitle("Server")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        appState.api.baseURL = url
                        dismiss()
                    }
                }
            }
            .onAppear { url = appState.api.baseURL }
        }
    }
}
