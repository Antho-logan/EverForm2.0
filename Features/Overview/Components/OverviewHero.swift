import SwiftUI

struct OverviewHero: View {

  @Binding var isFocusPanelVisible: Bool
  @Binding var selectedPeriod: FocusTimeframe

  @State private var heroHeight: CGFloat = 0

  private var greeting: String {
    let hour = Calendar.current.component(.hour, from: .now)
    switch hour {
    case 0..<12: return "Good morning"
    case 12..<17: return "Good afternoon"
    default: return "Good evening"
    }
  }

  private var dateText: String {
    Date().formatted(.dateTime.weekday(.wide).month().day())
  }

  var body: some View {
    // Main Hero Card
    EFCard(
      style: .gradient(
        LinearGradient(
          colors: [.blue.opacity(0.55), .purple.opacity(0.5)], startPoint: .topLeading,
          endPoint: .bottomTrailing))
    ) {
      VStack(spacing: 0) {
        // Centered content
        VStack(alignment: .leading, spacing: 8) {
          VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
              .font(.app(.bodySecondary))
              .foregroundStyle(.white.opacity(0.8))

            Text("Overview")
              .font(.app(.largeTitle))
              .foregroundStyle(.white)

            Text(dateText)
              .font(.app(.caption))
              .foregroundStyle(.white.opacity(0.8))
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)

        // Focus Selector
        HStack {
          Text("Today's focus")
            .font(.app(.body))
            .foregroundStyle(.white.opacity(0.9))
          
          Spacer()
          
          Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
              isFocusPanelVisible.toggle()
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
          } label: {
            HStack(spacing: 6) {
              Text(selectedPeriod.label)
                .font(.system(size: 14, weight: .bold))
              Image(systemName: "chevron.down")
                .font(.system(size: 12, weight: .bold))
                .rotationEffect(.degrees(isFocusPanelVisible ? 180 : 0))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white)
            .foregroundStyle(EverFormTheme.Colors.primaryBlue)
            .clipShape(Capsule())
          }
          .buttonStyle(.plain)
        }
        .padding(.bottom, 20)
      }
      .frame(height: 180)
      .foregroundStyle(.white)
    }
    .background(
      GeometryReader { geo in
        Color.clear.preference(key: BoundsPreferenceKey.self, value: geo.frame(in: .global))
      }
    )
  }
}
