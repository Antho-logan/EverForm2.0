import SwiftUI

struct KPITile: View {
    let icon: String
    let value: String
    let caption: String
    let onTap: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(icon: String, value: String, caption: String, onTap: (() -> Void)? = nil) {
        self.icon = icon
        self.value = value
        self.caption = caption
        self.onTap = onTap
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(palette.accent)
                        .frame(width: 20, height: 20)
                    
                    Spacer()
                }
                
                Text(value)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .allowsTightening(true)
                    .contentTransition(.numericText())
                
                Text(caption)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .textCase(.uppercase)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 90)
            .padding(12)
            .efCardStyle(scheme: colorScheme)
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(caption)
        .accessibilityValue(value)
    }
}

#Preview {
    let palette = Theme.palette(.light)
    LazyVGrid(columns: [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ], spacing: 12) {
        KPITile(
            icon: "figure.walk",
            value: "8.4K",
            caption: "Steps"
        ) {
            print("Steps tapped")
        }
        
        KPITile(
            icon: "flame.fill",
            value: "1.9K / 2.7K",
            caption: "Calories"
        ) {
            print("Calories tapped")
        }
        
        KPITile(
            icon: "bed.double.fill",
            value: "7h 30m",
            caption: "Sleep"
        ) {
            print("Sleep tapped")
        }
        
        KPITile(
            icon: "drop.fill",
            value: "0 ml",
            caption: "Hydration"
        ) {
            print("Hydration tapped")
        }
    }
    .padding()
    .background(palette.background)
}
