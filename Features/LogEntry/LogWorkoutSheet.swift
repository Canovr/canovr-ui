import SwiftUI

struct LogWorkoutSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date.now
    @State private var distanceKm: String = ""
    @State private var durationMinutes: String = ""
    @State private var notes: String = ""
    @State private var isSaving = false
    @State private var error: String?

    private var todayWorkout: DayPlan? { appState.todayWorkout }

    var body: some View {
        NavigationStack {
            Form {
                Section("Workout") {
                    if let workout = todayWorkout {
                        HStack {
                            Text(workout.workoutName ?? workout.workoutKey ?? "Training")
                                .font(CanovRTheme.bodyFont)
                                .foregroundStyle(CanovRTheme.textPrimary)
                            Spacer()
                            if let zone = workout.zone {
                                Text(zone)
                                    .font(CanovRTheme.lato(13, weight: .bold))
                                    .foregroundStyle(CanovRTheme.primary)
                            }
                        }
                    }

                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                        .tint(CanovRTheme.primary)
                }

                Section("Details (optional)") {
                    TextField("Distanz (km)", text: $distanceKm)
                        .keyboardType(.decimalPad)

                    TextField("Dauer (Minuten)", text: $durationMinutes)
                        .keyboardType(.decimalPad)

                    TextField("Notizen", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }

                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(CanovRTheme.error)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(CanovRTheme.background)
            .navigationTitle("Workout eintragen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                        .foregroundStyle(CanovRTheme.primary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        Task { await save() }
                    }
                    .disabled(isSaving || todayWorkout?.workoutKey == nil)
                    .foregroundStyle(CanovRTheme.primary)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() async {
        guard let athleteId = appState.athleteId,
              let workoutKey = todayWorkout?.workoutKey else { return }

        isSaving = true
        error = nil

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let data = CompleteWorkoutCreate(
            date: formatter.string(from: date),
            workoutKey: workoutKey,
            zone: todayWorkout?.zone,
            distanceKm: Double(distanceKm),
            durationMinutes: Double(durationMinutes),
            notes: notes.isEmpty ? nil : notes
        )

        do {
            _ = try await appState.api.completeWorkout(athleteId, data)
            appState.todayCompleted = true
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isSaving = false
    }
}
