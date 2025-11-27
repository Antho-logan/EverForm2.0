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
      icon: "figure.walk", title: "8.4K", subtitle: "Steps", caption: "of 10K goal", accent: .green,
      progress: 0.68),
    .init(
      icon: "flame.fill", title: "1850", subtitle: "Calories", caption: "out of 2661",
      accent: .orange, progress: 0.69),
    .init(
      icon: "bed.double.fill", title: "7h 30m", subtitle: "Sleep", caption: "last night",
      accent: .blue, progress: 0.94),
    .init(
      icon: "drop.fill", title: "0 ml", subtitle: "Hydration", caption: "needs attention",
      accent: .teal, progress: 0.05),
  ]
}

struct KPICard: View {
  @Environment(\.colorScheme) private var scheme
  let item: KPIItem
  @State private var animatedProgress: CGFloat = 0

  var body: some View {
    EFCard(style: .tinted(item.accent)) {
      VStack(alignment: .leading, spacing: 12) {
        Image(systemName: item.icon)
          .font(.app(.heading))
          .foregroundStyle(item.accent)

        VStack(alignment: .leading, spacing: 4) {
          Text(item.subtitle.uppercased())
            .font(.app(.label))
            .foregroundStyle(EFTheme.muted(scheme))

          Text(item.title)
            .font(.app(.title))
            .foregroundStyle(EFTheme.text(scheme))

          Text(item.caption)
            .font(.app(.caption))
            .foregroundStyle(EFTheme.muted(scheme))
        }

        GeometryReader { geo in
          ZStack(alignment: .leading) {
            Capsule()
              .fill(item.accent.opacity(0.2))

            Capsule()
              .fill(item.accent)
              .frame(width: animatedProgress * geo.size.width)
          }
        }
        .frame(height: 6)
        .padding(.top, 4)
      }
    }
    .onAppear {
      // Reset first to ensure animation plays if view was kept in memory but not fully disappeared
      animatedProgress = 0
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
        animatedProgress = CGFloat(item.progress)
      }
    }
    .onDisappear {
      animatedProgress = 0
    }
    .onChange(of: item.progress) { _, newValue in
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
        animatedProgress = CGFloat(newValue)
      }
    }
  }
}
