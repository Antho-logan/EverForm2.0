import SwiftUI

// MARK: - Tab Item Model
enum EverFormTab: Int, CaseIterable, Identifiable {
  case overview = 0
  case coach = 1
  case scan = 2
  case progress = 3

  var id: Int { rawValue }

  var title: String {
    switch self {
    case .overview: return "Overview"
    case .coach: return "Coach"
    case .scan: return "Scan"
    case .progress: return "Progress"
    }
  }

  var icon: String {
    switch self {
    case .overview: return "house.fill"
    case .coach: return "brain.head.profile"
    case .scan: return "camera.viewfinder"
    case .progress: return "chart.bar.fill"
    }
  }
}

// MARK: - Custom Tab Bar
struct EverFormTabBar: View {
  @Binding var selection: Int
  @Environment(ThemeManager.self) private var themeManager
  @Environment(\.colorScheme) private var colorScheme

  private let tabs = EverFormTab.allCases

  // MARK: - Dynamic Theme Colors

  private var tabBarBackground: Color {
    // Use themeManager beige background for consistency
    themeManager.beigeBackground
  }

  private var activeColor: Color {
    DesignSystem.Colors.accent
  }

  private var inactiveColor: Color {
    DesignSystem.Colors.textSecondary
  }

  private var activePillColor: Color {
    activeColor.opacity(colorScheme == .dark ? 0.22 : 0.12)
  }

  private var separatorColor: Color {
    colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.05)
  }

  // MARK: - Body

  var body: some View {
    VStack(spacing: 0) {
      // Top Separator
      Rectangle()
        .fill(separatorColor)
        .frame(height: 1)

      HStack(spacing: 0) {
        ForEach(tabs) { tab in
          let isSelected = selection == tab.rawValue

          Button {
            if !isSelected {
              // Preserved snappy spring animation for selection
              withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                selection = tab.rawValue
              }
              UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
          } label: {
            VStack(spacing: 2) {
              // Icon Container
              ZStack {
                // Active Indicator Pill
                if isSelected {
                  Capsule()
                    .fill(activePillColor)
                    .frame(width: 44, height: 26)
                    .matchedGeometryEffect(id: "TabBackground", in: namespace)
                }

                Image(systemName: tab.icon)
                  .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                  .foregroundStyle(isSelected ? activeColor : inactiveColor)
                  .scaleEffect(isSelected ? 1.05 : 1.0)
              }
              .frame(width: 44, height: 26)

              // Label
              Text(tab.title)
                .font(DesignSystem.Typography.labelSmall())
                .foregroundStyle(isSelected ? activeColor : inactiveColor)
                .scaleEffect(isSelected ? 1.02 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.vertical, 2)
    }
    .frame(maxWidth: .infinity, alignment: .bottom)
    // Anchor to bottom: Background extends into safe area (home indicator)
    // Theme: Uses DesignSystem.Colors.background (Overview tone) for both Light/Dark modes
    .background(
      tabBarBackground
        .ignoresSafeArea(edges: .bottom)
    )
  }

  @Namespace private var namespace
}