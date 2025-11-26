import SwiftUI

struct PlanItem: Identifiable {
  enum CTAStyle {
    case filled
    case outline
  }

  let id = UUID()
  let icon: String
  let title: String
  let subtitle: String
  let accent: Color
  let duration: String
  let ctaTitle: String
  let ctaStyle: CTAStyle

  static let mock: [PlanItem] = [
    .init(
      icon: "dumbbell.fill", title: "Training", subtitle: "Upper Body", accent: .green,
      duration: "Start 09:00", ctaTitle: "Start Workout", ctaStyle: .filled),
    .init(
      icon: "fork.knife", title: "Nutrition", subtitle: "2661 kcal", accent: .orange,
      duration: "Log 3 meals", ctaTitle: "Log Meal", ctaStyle: .outline),
    .init(
      icon: "moon.stars.fill", title: "Recovery", subtitle: "Bedtime 22:30", accent: .blue,
      duration: "Wind down", ctaTitle: "Open", ctaStyle: .outline),
    .init(
      icon: "figure.run", title: "Mobility", subtitle: "Hips & Shoulders", accent: .purple,
      duration: "Completed", ctaTitle: "Review", ctaStyle: .outline),
  ]
}

struct OverviewPlanCard: View {
  let item: PlanItem
  var action: (() -> Void)? = nil

  var body: some View {
    EFCard(style: .tinted(item.accent)) {
      VStack(alignment: .leading, spacing: 6) {
        HStack(alignment: .top, spacing: 12) {
          Image(systemName: item.icon)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(item.accent)

          VStack(alignment: .leading, spacing: 2) {
            Text(item.title)
              .font(EverFont.cardTitle)
            Text(item.subtitle)
              .font(EverFont.bodySecondary)
              .foregroundStyle(.secondary)
          }
        }

        Text(item.duration)
          .font(EverFont.caption)
          .foregroundStyle(.secondary)

        Spacer(minLength: 6)

        CTAButton(
          title: item.ctaTitle,
          style: item.ctaStyle,
          tint: item.accent,
          action: action
        )
      }
      .frame(minHeight: 120, alignment: .topLeading)
    }
  }
}

private struct CTAButton: View {
  let title: String
  let style: PlanItem.CTAStyle
  let tint: Color
  var action: (() -> Void)?

  var body: some View {
    Button(action: { action?() }) {
      Text(title)
        .font(EverFont.label)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    .buttonStyle(.plain)
    .background(background)
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(tint.opacity(style == .filled ? 0 : 0.4), lineWidth: 1)
    )
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    .foregroundStyle(foreground)
  }

  private var background: some View {
    Group {
      switch style {
      case .filled:
        tint.opacity(0.9)
      case .outline:
        tint.opacity(0.12)
      }
    }
  }

  private var foreground: Color {
    switch style {
    case .filled: return .white
    case .outline: return tint
    }
  }
}
