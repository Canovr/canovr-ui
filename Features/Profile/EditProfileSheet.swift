import SwiftUI

struct EditProfileSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var weeklyKm: Double = 50
    @State private var phase = "general"
    @State private var weekInPhase = 1
    @State private var phaseWeeksTotal = 8
    @State private var restDay = 1
    @State private var longRunDay = 0
    @State private var daysToRace: String = ""
    @State private var isSaving = false
    @State private var error: String?

    private let phases = ["general", "supportive", "specific"]
    private let phaseLabels = ["General", "Supportive", "Specific"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Trainingsphase") {
                    Picker("Phase", selection: $phase) {
                        ForEach(Array(zip(phases, phaseLabels)), id: \.0) { id, label in
                            Text(label).tag(id)
                        }
                    }

                    Stepper("Woche \(weekInPhase) von \(phaseWeeksTotal)", value: $weekInPhase, in: 1...phaseWeeksTotal)
                    Stepper("Phasendauer: \(phaseWeeksTotal) Wochen", value: $phaseWeeksTotal, in: 1...24)
                }

                Section("Volumen") {
                    VStack(alignment: .leading) {
                        Text("\(Int(weeklyKm)) km/Woche")
                        Slider(value: $weeklyKm, in: 10...150, step: 5)
                            .tint(CanovRTheme.azure)
                    }
                }

                Section("Tage") {
                    Picker("Ruhetag", selection: $restDay) {
                        ForEach(0..<7) { i in
                            Text(["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"][i]).tag(i)
                        }
                    }
                    Picker("Langer Lauf", selection: $longRunDay) {
                        ForEach(0..<7) { i in
                            Text(["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"][i]).tag(i)
                        }
                    }
                }

                Section("Wettkampf") {
                    TextField("Tage bis Wettkampf (leer = kein Taper)", text: $daysToRace)
                        .keyboardType(.numberPad)
                }

                if let error {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(CanovRTheme.background)
            .navigationTitle("Profil bearbeiten")
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
            .onAppear { loadCurrent() }
        }
    }

    private func loadCurrent() {
        guard let a = appState.athlete else { return }
        weeklyKm = a.weeklyKm
        phase = a.currentPhase
        weekInPhase = a.weekInPhase
        phaseWeeksTotal = a.phaseWeeksTotal
        restDay = a.restDay ?? 1
        longRunDay = a.longRunDay ?? 0
        if let d = a.daysToRace { daysToRace = "\(d)" }
    }

    private func save() async {
        guard let athleteId = appState.athleteId else { return }
        isSaving = true
        error = nil

        let update = AthleteUpdate(
            weeklyKm: weeklyKm,
            currentPhase: phase,
            weekInPhase: weekInPhase,
            phaseWeeksTotal: phaseWeeksTotal,
            restDay: restDay,
            longRunDay: longRunDay,
            daysToRace: Int(daysToRace)
        )

        do {
            appState.athlete = try await appState.api.updateAthlete(athleteId, update)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isSaving = false
    }
}
