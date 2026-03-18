import SwiftUI

struct RaceTimeStepView: View {
    let distance: String
    @Binding var minutes: Int
    @Binding var seconds: Int
    let onNext: () -> Void

    private var distanceLabel: String {
        DistanceOption.all.first { $0.id == distance }?.label ?? distance
    }

    private var distanceKm: Double {
        DistanceOption.all.first { $0.id == distance }?.km ?? 10.0
    }

    private var paceDisplay: String {
        let totalSec = Double(minutes * 60 + seconds)
        let paceSeconds = totalSec / distanceKm
        let m = Int(paceSeconds) / 60
        let s = Int(paceSeconds) % 60
        return String(format: "%d:%02d/km", m, s)
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Deine aktuelle Bestzeit")
                .font(CanovRTheme.titleFont)
                .foregroundStyle(CanovRTheme.textPrimary)

            Text(distanceLabel)
                .font(CanovRTheme.bodyFont)
                .foregroundStyle(CanovRTheme.azure)

            // Time Picker
            HStack(spacing: 4) {
                Picker("Minuten", selection: $minutes) {
                    ForEach(0..<300) { m in
                        Text("\(m) min").tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120)

                Text(":")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(CanovRTheme.textPrimary)

                Picker("Sekunden", selection: $seconds) {
                    ForEach(0..<60) { s in
                        Text(String(format: "%02d s", s)).tag(s)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120)
            }
            .frame(height: 150)

            // Live Pace
            HStack(spacing: 4) {
                Text("=")
                    .foregroundStyle(CanovRTheme.textSecondary)
                Text(paceDisplay)
                    .font(CanovRTheme.paceFont)
                    .foregroundStyle(CanovRTheme.azure)
            }

            Spacer()

            Button(action: onNext) {
                Text("Weiter")
                    .font(.system(size: 18, weight: .semibold))
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
