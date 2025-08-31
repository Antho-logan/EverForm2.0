import SwiftUI

struct EFKPI: View {
    @Environment(\.colorScheme) private var scheme
    let icon: String
    let title: String
    let value: String

    var body: some View {
        let palette = Theme.palette(scheme)
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .frame(width: 18, height: 18)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(palette.accent)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .default))
                    .textCase(.uppercase)
                    .foregroundStyle(palette.textSecondary)
                    .lineLimit(1)
            }
            
            Text(value.isEmpty ? "—" : value)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 84)
        .padding(12)
        .efCardStyle(scheme: scheme)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value.isEmpty ? "No data" : value)
    }
}