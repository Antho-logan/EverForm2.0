import SwiftUI

struct KPIItem: Identifiable {
  let id = UUID()
  let icon: String
  let title: String
  let subtitle: String
  let caption: String
  let accent: Color
  let progress: Double

  static let mock: [KPIItem] = [
    .init(
      icon: "figure.walk", title: "8.4K", subtitle: "Steps", caption: "of 10K goal", accent: EverFormTheme.Colors.trainingGreen,
      progress: 0.68),
    .init(
      icon: "flame.fill", title: "1850", subtitle: "Calories", caption: "out of 2661",
      accent: EverFormTheme.Colors.nutritionOrange, progress: 0.69),
    .init(
      icon: "bed.double.fill", title: "7h 30m", subtitle: "Sleep", caption: "last night",
      accent: EverFormTheme.Colors.recoveryBlue, progress: 0.94),
    .init(
      icon: "drop.fill", title: "0 ml", subtitle: "Hydration", caption: "needs attention",
      accent: EverFormTheme.Colors.breathworkTeal, progress: 0.05),
  ]
}

struct KPICard: View {
  @Environment(\.colorScheme) private var scheme
  let item: KPIItem
  @State private var animatedProgress: CGFloat = 0

  var body: some View {
    EverFormCard {
      VStack(alignment: .leading, spacing: 0) {
        // Top Left Icon
        Image(systemName: item.icon)
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(item.accent)
          .padding(.bottom, 12)

        Spacer()

        // Big Number
        Text(item.title)
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(EverFormTheme.Colors.textPrimary)
          .lineLimit(1)
          .minimumScaleFactor(0.8)

        // Label
        Text(item.subtitle)
          .font(EverFormTheme.Typography.label)
          .foregroundStyle(EverFormTheme.Colors.textSecondary)
          .padding(.bottom, 12)

        // Unified Progress Bar
        GeometryReader { geo in
          ZStack(alignment: .leading) {
            Capsule()
              .fill(item.accent.opacity(0.15))
              .frame(height: 6)
            
            Capsule()
              .fill(item.accent)
              .frame(width: animatedProgress * geo.size.width, height: 6)
          }
        }
        .frame(height: 6)
      }
      .frame(height: 120) // Fixed height for visual consistency
    }
    .onAppear {
      animatedProgress = 0
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
        animatedProgress = CGFloat(item.progress)
      }
    }
    .onChange(of: item.progress) { _, newValue in
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
        animatedProgress = CGFloat(newValue)
      }
    }
  }
}
