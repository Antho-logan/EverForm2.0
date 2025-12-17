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
  @Environment(\.colorScheme) private var colorScheme

  private let tabs = EverFormTab.allCases

  // MARK: - Dynamic Theme Colors

  private var tabBarTint: Color {
    AppTheme.Colors.surfaceSecondary.opacity(colorScheme == .dark ? 0.78 : 0.92)
  }

  private var activeColor: Color {
    AppTheme.Colors.brandBlue
  }

  private var inactiveColor: Color {
    AppTheme.Colors.textSecondary
  }

  private var activePillColor: Color {
    activeColor.opacity(colorScheme == .dark ? 0.22 : 0.12)
  }

  private var topFadeOpacity: Double {
    colorScheme == .dark ? 0.28 : 0.10
  }

  // MARK: - Body

  var body: some View {
    tabRow
      .frame(maxWidth: .infinity, alignment: .bottom)
      // Background extends under the home-indicator region (no visible gap).
      .background {
        Rectangle()
          .fill(.ultraThinMaterial)
          .overlay(tabBarTint)
          .overlay(alignment: .top) {
            LinearGradient(
              colors: [
                Color.black.opacity(topFadeOpacity),
                .clear
              ],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 14)
            .allowsHitTesting(false)
          }
          .ignoresSafeArea(edges: .bottom)
      }
      .shadow(
        color: Color.black.opacity(colorScheme == .dark ? 0.26 : 0.08),
        radius: 12,
        x: 0,
        y: -4
      )
      // Keep height stable when the keyboard appears (RootTabView hides the bar).
      .ignoresSafeArea(.keyboard, edges: .bottom)
  }

  @Namespace private var namespace

  private var tabRow: some View {
    HStack(spacing: 0) {
      ForEach(tabs) { tab in
        let isSelected = selection == tab.rawValue

        Button {
          if !isSelected {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
              selection = tab.rawValue
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
          }
        } label: {
          VStack(spacing: 2) {
            ZStack {
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

            Text(tab.title)
              .font(DesignSystem.Typography.labelSmall())
              .foregroundStyle(isSelected ? activeColor : inactiveColor)
              .scaleEffect(isSelected ? 1.02 : 1.0)
          }
          .frame(maxWidth: .infinity)
          .padding(.top, 6)
          .padding(.bottom, 6)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
      }
    }
  }
}
