import SwiftUI

struct FocusOverlayView: View {
  @Binding var selection: FocusTimeframe
  let items: [FocusItem]
  @Environment(ThemeManager.self) private var themeManager

  var body: some View {
    VStack(spacing: 16) {
      // Segmented Control
      HStack(spacing: 8) {
        ForEach(FocusTimeframe.allCases) { timeframe in
          Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
              selection = timeframe
            }
          } label: {
            Text(timeframe.label)
              .font(EverFont.bodySecondary)
              .foregroundStyle(
                selection == timeframe ? .white : themeManager.textPrimary.opacity(0.8)
              )
              .frame(maxWidth: .infinity)
              .padding(.vertical, 8)
              .background {
                if selection == timeframe {
                  Capsule()
                    .fill(DesignSystem.Colors.accent)
                    .matchedGeometryEffect(id: "activeSegment", in: animationNamespace)
                } else {
                  Capsule()
                    .fill(themeManager.backgroundSecondary.opacity(0.5))
                }
              }
          }
          .buttonStyle(.plain)
        }
      }
      .padding(8)
      .background(themeManager.backgroundSecondary.opacity(0.3))
      .clipShape(Capsule())

      // Scrollable List
      VStack(spacing: 12) {
        ForEach(items) { item in
          FocusItemRow(item: item, themeManager: themeManager)
        }

        // Footer
        Text("These focus points are generated from your goals and routine.")
          .font(EverFont.caption)
          .foregroundStyle(themeManager.textSecondary)
          .multilineTextAlignment(.center)
          .padding(.top, 8)
          .padding(.bottom, 12)
      }
    }
    .padding(16)
    .background(themeManager.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    .shadow(color: themeManager.cardShadow.opacity(0.15), radius: 20, x: 0, y: 10)
  }

  @Namespace private var animationNamespace
}

struct FocusItemRow: View {
  let item: FocusItem
  let themeManager: ThemeManager

  var body: some View {
    HStack(spacing: 16) {
      // Small icon circle
      ZStack {
        Circle()
          .fill(themeManager.backgroundSecondary)
          .frame(width: 40, height: 40)
        Image(systemName: item.iconName)
          .font(.system(size: 18))
          .foregroundStyle(DesignSystem.Colors.accent)
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(item.title)
          .font(EverFont.cardTitle)
          .foregroundStyle(themeManager.textPrimary)

        Text(item.detail)
          .font(EverFont.caption)
          .foregroundStyle(themeManager.textSecondary)
      }

      Spacer()

      // Completion indicator
      if item.isCompleted {
        Image(systemName: "checkmark.circle.fill")
          .font(.title2)
          .foregroundStyle(DesignSystem.Colors.success)
      } else {
        Image(systemName: "circle")
          .font(.title2)
          .foregroundStyle(themeManager.textSecondary.opacity(0.3))
      }
    }
    .padding(12)
    .background(themeManager.backgroundSecondary.opacity(0.5))
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .transition(.opacity.combined(with: .move(edge: .trailing)))
  }
}
