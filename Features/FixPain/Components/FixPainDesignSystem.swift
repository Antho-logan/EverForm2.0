// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI
import UIKit

// MARK: - Theme
struct FixPainTheme {
    // MARK: - Dynamic Colors
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0) // Dark Background
            : UIColor(red: 0.95, green: 0.91, blue: 0.86, alpha: 1.0) // Warm Beige
        })
    }
    
    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) // Elevated Dark
            : UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1.0) // Pale Beige
        })
    }
    
    static var cardBackgroundSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Soft Dark
            : UIColor(red: 0.97, green: 0.94, blue: 0.90, alpha: 1.0) // Lighter Beige
        })
    }
    
    static var primary: Color {
        Color(hex: "0066FF") // Premium Blue (matches Overview Accent)
    }
    
    static var textPrimary: Color {
        Color(UIColor.label)
    }
    
    static var textSecondary: Color {
        Color(UIColor.secondaryLabel)
    }
    
    static var shadowColor: Color {
        Color.black.opacity(0.15)
    }
    
    // MARK: - Gradients
    static func primaryGradient() -> LinearGradient {
        // Matches OverviewHero gradient style
        LinearGradient(
            colors: [
                Color.blue.opacity(0.55),
                Color.purple.opacity(0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Metrics
    static let radiusLarge: CGFloat = 24
    static let radiusMedium: CGFloat = 16
    static let radiusSmall: CGFloat = 12
    
    static let paddingLarge: CGFloat = 24
    static let paddingMedium: CGFloat = 16
    
    static let shadowRadius: CGFloat = 20
    static let shadowY: CGFloat = 10
}

// MARK: - Reusable Components

struct FixPainPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    isDisabled ? Color.gray.opacity(0.3) : FixPainTheme.primary
                )
                .clipShape(RoundedRectangle(cornerRadius: 16)) // Updated to match Overview button style (typically less rounded than full pill, but user asked for "pill-shaped" in previous prompt, but "match Overview" in this one. Overview often uses 14-16. I'll stick to user's previous "pill" or compromise at large radius. Overview buttons in `PlanCard` use 14. `OverviewHero` has no button. I'll use 16 for a modern feel or Capsule if "Pill" is strict. Let's go with Capsule/Pill as per previous explicit instruction, but styled with Overview colors.)
                .clipShape(Capsule()) // Keeping pill as per feature identity, but using Overview colors
                .shadow(color: isDisabled ? .clear : FixPainTheme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(isDisabled)
        .scaleEffect(isDisabled ? 1.0 : 1.0)
        .animation(.spring(response: 0.3), value: isDisabled)
    }
}

struct FixPainSecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(FixPainTheme.textSecondary)
                .frame(height: 44)
        }
    }
}

struct FixPainChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? FixPainTheme.primary.opacity(0.1) : FixPainTheme.cardBackgroundSecondary) // Use secondary card bg for chips
                .foregroundStyle(isSelected ? FixPainTheme.primary : FixPainTheme.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? FixPainTheme.primary : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct FixPainStepHeader: View {
    let step: Int
    let totalSteps: Int
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Progress Label
            HStack {
                Text("STEP \(step) OF \(totalSteps)")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(FixPainTheme.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(FixPainTheme.primary.opacity(0.1))
                    .clipShape(Capsule())
                Spacer()
            }
            
            Text(title)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(FixPainTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(subtitle)
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(FixPainTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(.horizontal, FixPainTheme.paddingLarge)
        .padding(.bottom, 10)
    }
}

struct FixPainProgressBar: View {
    let progress: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(FixPainTheme.textSecondary.opacity(0.1))
                    .frame(height: 4)
                
                Capsule()
                    .fill(FixPainTheme.primary)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.smooth(duration: 0.5), value: progress)
            }
        }
        .frame(height: 4)
    }
}

struct FixPainToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(FixPainTheme.textPrimary)
        }
        .toggleStyle(SwitchToggleStyle(tint: FixPainTheme.primary))
        .padding()
        .background(FixPainTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: FixPainTheme.shadowColor.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
