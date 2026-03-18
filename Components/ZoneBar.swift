import SwiftUI

/// Horizontaler Balken mit allen 8 Pace-Zonen. Optional eine Zone hervorgehoben.
struct ZoneBar: View {
    var highlightedZone: String? = nil
    let zones: [String: String]   // z.B. ["z80": "5:37/km", ...]

    private let zoneOrder = [80, 85, 90, 95, 100, 105, 110, 115]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(zoneOrder, id: \.self) { pct in
                let label = "z\(pct)"
                let isHighlighted = highlightedZone == label

                RoundedRectangle(cornerRadius: 3)
                    .fill(CanovRTheme.zoneColor(percentage: pct))
                    .opacity(highlightedZone == nil || isHighlighted ? 1.0 : 0.25)
                    .frame(height: isHighlighted ? 28 : 20)
                    .overlay {
                        if isHighlighted {
                            Text(label)
                                .font(.custom("Lato-Bold", size: 9))
                                .foregroundStyle(CanovRTheme.textPrimary)
                        }
                    }
            }
        }
    }
}
