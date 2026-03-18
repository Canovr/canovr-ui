import SwiftUI

struct LogRaceSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var distance = "10k"
    @State private var minutes = 50
    @State private var seconds = 0
    @State private var notes = ""
    @State private var isSaving = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Rennen") {
                    DatePicker("Datum", selection: $date, displayedComponents: .date)

                    Picker("Distanz", selection: $distance) {
                        ForEach(DistanceOption.all) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                }

                Section("Zeit") {
                    HStack {
                        Picker("Min", selection: $minutes) {
                            ForEach(0..<300) { m in
                                Text("\(m) min").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 120, height: 120)

                        Text(":")
                            .font(.custom("Lato-Bold", size: 20))

                        Picker("Sek", selection: $seconds) {
                            ForEach(0..<60) { s in
                                Text(String(format: "%02d s", s)).tag(s)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 120, height: 120)
                    }
                }

                Section("Notizen (optional)") {
                    TextField("z.B. Streckenprofil, Wetter", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(CanovRTheme.background)
            .navigationTitle("Rennergebnis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task { await save() }
                    }
                    .disabled(isSaving)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func save() async {
        guard let athleteId = appState.athleteId else { return }

        isSaving = true
        error = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let data = RaceResultCreate(
            date: formatter.string(from: date),
            distance: distance,
            timeSeconds: Double(minutes * 60 + seconds),
            notes: notes.isEmpty ? nil : notes
        )

        do {
            _ = try await appState.api.addRace(athleteId, data)
            await appState.loadAthlete()  // Pace könnte sich geändert haben
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isSaving = false
    }
}
