import SwiftUI

/// Horizontal bar showing all 8 pace zones. Optionally highlights one zone.
struct ZoneBar: View {
    var highlightedZone: String? = nil
    let zones: [String: String]

    private let zoneOrder = [80, 85, 90, 95, 100, 105, 110, 115]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(zoneOrder, id: \.self) { pct in
                let label = "z\(pct)"
                let isHighlighted = highlightedZone == label

                RoundedRectangle(cornerRadius: 4)
                    .fill(CanovRTheme.zoneColor(percentage: pct))
                    .opacity(highlightedZone == nil || isHighlighted ? 1.0 : 0.3)
                    .frame(height: isHighlighted ? 28 : 18)
                    .overlay {
                        if isHighlighted {
                            Text(label)
                                .font(CanovRTheme.lato(9, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            }
        }
    }
}
