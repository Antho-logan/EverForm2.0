//
//  Components.swift
//  EverForm
//
//  Created by Assistant on 14/01/2025.
//  Premium UI Components - Reusable Design System Components
//

import SwiftUI

// MARK: - Bottom Dock (Single Source of Truth)
//
// Legacy helper (currently unused):
// - Older iterations used a root `.safeAreaInset(edge: .bottom)` and registered accessories here.
// - The current root layout contract overlays the custom tab bar and reserves space via padding,
//   allowing screens to safely use their own `.safeAreaInset(edge: .bottom)` for composers/CTAs.
//
@MainActor
final class BottomDock: ObservableObject {
  /// The currently registered accessory view (e.g. chat composer).
  @Published private(set) var accessory: AnyView?

  /// Ownership token for the accessory to prevent cross-tab onDisappear races clearing a newer accessory.
  private var ownerID: UUID?

  /// Registers an accessory view and returns an ownership token.
  @discardableResult
  func setAccessory(_ view: AnyView) -> UUID {
    let id = UUID()
    ownerID = id
    accessory = view
    return id
  }

  /// Clears the accessory only if the provided token matches the current owner.
  func clearAccessory(ownerID: UUID?) {
    guard let ownerID, ownerID == self.ownerID else { return }
    self.ownerID = nil
    accessory = nil
  }

  /// Force-clears the accessory (use sparingly).
  func clearAccessory() {
    ownerID = nil
    accessory = nil
  }
}

// MARK: - Button Components

struct ButtonPrimary: View {
  let title: String
  let action: () -> Void
  let isLoading: Bool
  let isDisabled: Bool

  @State private var isPressed = false

  init(
    _ title: String,
    isLoading: Bool = false,
    isDisabled: Bool = false,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.action = action
    self.isLoading = isLoading
    self.isDisabled = isDisabled
  }

  var body: some View {
    Button(action: {
      guard !isDisabled && !isLoading else { return }

      // Haptic feedback
      let impact = UIImpactFeedbackGenerator(style: .light)
      impact.impactOccurred()

      // Press animation
      withAnimation(DesignSystem.Animation.springFast) {
        isPressed = true
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        withAnimation(DesignSystem.Animation.springFast) {
          isPressed = false
        }
        action()
      }
    }) {
      HStack(spacing: DesignSystem.Spacing.sm) {
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(0.8)
        } else {
          Text(title)
            .font(EverFont.button)
            .fontWeight(.semibold)
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: DesignSystem.TouchTarget.minimum)
      .foregroundColor(isDisabled ? DesignSystem.Colors.neutral400 : Color.black)
      .background(
        RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
          .fill(isDisabled ? DesignSystem.Colors.neutral300 : Color.white)
          .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
              .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
          )
      )
      .scaleEffect(isPressed ? 0.96 : 1.0)
      .opacity(isDisabled ? 0.6 : 1.0)
      .animation(DesignSystem.Animation.springFast, value: isPressed)
      .animation(DesignSystem.Animation.easeInOut, value: isDisabled)
    }
    .disabled(isDisabled || isLoading)
    .accessibilityLabel(title)
    .accessibilityHint(isDisabled ? "Button is disabled" : "Tap to \(title.lowercased())")
  }
}

// MARK: - Card Components

struct CardDefault: View {
  let content: () -> AnyView
  let onTap: (() -> Void)?

  @State private var isPressed = false

  init<Content: View>(
    onTap: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.onTap = onTap
    self.content = { AnyView(content()) }
  }

  var body: some View {
    Group {
      if let onTap = onTap {
        Button(action: {
          let impact = UIImpactFeedbackGenerator(style: .light)
          impact.impactOccurred()

          withAnimation(DesignSystem.Animation.springFast) {
            isPressed = true
          }

          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(DesignSystem.Animation.springFast) {
              isPressed = false
            }
            onTap()
          }
        }) {
          cardContent
        }
        .buttonStyle(.plain)
      } else {
        cardContent
      }
    }
  }

  private var cardContent: some View {
    content()
      .padding(DesignSystem.Spacing.cardPadding)
      .background(DesignSystem.Colors.cardBackgroundElevated)
      .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
      .overlay(
        RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
          .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
      )
      .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 2)
      .scaleEffect(isPressed ? 0.98 : 1.0)
      .animation(DesignSystem.Animation.springFast, value: isPressed)
  }
}

struct StatCard: View {
  let title: String
  let value: String
  let subtitle: String
  let accentColor: Color
  let onTap: (() -> Void)?

  @State private var isPressed = false
  @State private var isVisible = false

  init(
    title: String,
    value: String,
    subtitle: String,
    accentColor: Color = DesignSystem.Colors.accent,
    onTap: (() -> Void)? = nil
  ) {
    self.title = title
    self.value = value
    self.subtitle = subtitle
    self.accentColor = accentColor
    self.onTap = onTap
  }

  var body: some View {
    CardDefault(onTap: onTap) {
      VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
        Text(title)
          .font(EverFont.label)
          .foregroundColor(DesignSystem.Colors.textSecondary)
          .opacity(isVisible ? 1.0 : 0.0)
          .offset(y: isVisible ? 0 : 10)
          .animation(DesignSystem.Animation.springSlow.delay(0.1), value: isVisible)

        Text(value)
          .font(DesignSystem.Typography.monospacedNumber(size: 32, relativeTo: .title))
          .fontWeight(.bold)
          .foregroundColor(accentColor)
          .contentTransition(.numericText(countsDown: false))
          .opacity(isVisible ? 1.0 : 0.0)
          .offset(y: isVisible ? 0 : 10)
          .animation(DesignSystem.Animation.springSlow.delay(0.2), value: isVisible)

        Text(subtitle)
          .font(EverFont.smallCaption)
          .foregroundColor(DesignSystem.Colors.textTertiary)
          .opacity(isVisible ? 1.0 : 0.0)
          .offset(y: isVisible ? 0 : 10)
          .animation(DesignSystem.Animation.springSlow.delay(0.3), value: isVisible)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .onAppear {
      withAnimation {
        isVisible = true
      }
    }
    .accessibilityLabel("\(title): \(value) \(subtitle)")
  }
}

// MARK: - Navigation Components

struct NavBar: View {
  let title: String
  let subtitle: String?
  let showBackButton: Bool
  let onBackTap: (() -> Void)?
  let onSettingsTap: (() -> Void)?

  init(
    title: String,
    subtitle: String? = nil,
    showBackButton: Bool = false,
    onBackTap: (() -> Void)? = nil,
    onSettingsTap: (() -> Void)? = nil
  ) {
    self.title = title
    self.subtitle = subtitle
    self.showBackButton = showBackButton
    self.onBackTap = onBackTap
    self.onSettingsTap = onSettingsTap
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        // Left side - Back button or spacer
        if showBackButton {
          Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onBackTap?()
          }) {
            Image(systemName: "chevron.left")
              .font(.system(size: DesignSystem.IconSize.medium, weight: .medium))
              .foregroundColor(DesignSystem.Colors.textPrimary)
              .frame(
                width: DesignSystem.TouchTarget.minimum, height: DesignSystem.TouchTarget.minimum
              )
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Back")
        } else {
          Spacer()
            .frame(width: DesignSystem.TouchTarget.minimum)
        }

        Spacer()

        // Center - Title and subtitle
        VStack(spacing: DesignSystem.Spacing.xs) {
          Text(title)
            .font(DesignSystem.Typography.titleLarge())
            .fontWeight(.semibold)
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .multilineTextAlignment(.center)

          if let subtitle {
            Text(subtitle)
              .font(EverFont.smallCaption)
              .foregroundColor(DesignSystem.Colors.textSecondary)
              .multilineTextAlignment(.center)
          }
        }

        Spacer()

        // Right side - Settings button or spacer
        if let onSettingsTap = onSettingsTap {
          Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onSettingsTap()
          }) {
            Image(systemName: "gear")
              .font(.system(size: DesignSystem.IconSize.medium, weight: .medium))
              .foregroundColor(DesignSystem.Colors.textPrimary)
              .frame(
                width: DesignSystem.TouchTarget.minimum, height: DesignSystem.TouchTarget.minimum
              )
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .accessibilityLabel("Settings")
        } else {
          Spacer()
            .frame(width: DesignSystem.TouchTarget.minimum)
        }
      }
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
      .frame(height: DesignSystem.TouchTarget.large)
      .background(.ultraThinMaterial)

      // Bottom border
      Rectangle()
        .frame(height: 1)
        .foregroundColor(DesignSystem.Colors.border)
    }
  }
}

// MARK: - Tab Bar Components

struct TabBarPrimary: View {
  let tabs: [TabItem]
  @Binding var selectedTab: Int

  struct TabItem {
    let title: String
    let icon: String
    let accessibilityHint: String
  }

  var body: some View {
    HStack(spacing: 0) {
      ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
        TabBarItemPrimary(
          title: tab.title,
          icon: tab.icon,
          isSelected: selectedTab == index,
          accessibilityHint: tab.accessibilityHint
        ) {
          let impact = UIImpactFeedbackGenerator(style: .light)
          impact.impactOccurred()

          withAnimation(DesignSystem.Animation.springFast) {
            selectedTab = index
          }
        }
      }
    }
    .padding(.horizontal, DesignSystem.Spacing.sm)
    .padding(.vertical, DesignSystem.Spacing.sm)
    .background(.ultraThinMaterial)
    .overlay(
      Rectangle()
        .frame(height: 1)
        .foregroundColor(DesignSystem.Colors.border),
      alignment: .top
    )
  }
}

struct TabBarItemPrimary: View {
  let title: String
  let icon: String
  let isSelected: Bool
  let accessibilityHint: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: DesignSystem.Spacing.xs) {
        ZStack {
          // Background indicator for selected state
          Circle()
            .fill(DesignSystem.Colors.accent.opacity(0.1))
            .frame(width: 32, height: 32)
            .scaleEffect(isSelected ? 1.0 : 0.01)
            .animation(DesignSystem.Animation.spring, value: isSelected)

          Image(systemName: icon)
            .font(
              .system(size: DesignSystem.IconSize.small, weight: isSelected ? .semibold : .medium)
            )
            .foregroundColor(
              isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(DesignSystem.Animation.springFast, value: isSelected)
        }

        Text(title)
          .font(EverFont.smallCaption)
          .foregroundColor(
            isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary
          )
          .scaleEffect(isSelected ? 1.05 : 1.0)
          .animation(DesignSystem.Animation.springFast, value: isSelected)
      }
      .frame(maxWidth: .infinity)
      .frame(minHeight: DesignSystem.TouchTarget.minimum)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel(title)
    .accessibilityHint(accessibilityHint)
  }
}

// MARK: - Restored Components (for Overview rollback)

public struct EFCard<Content: View>: View {
    public enum Style {
        case standard
        case tinted(Color)
        case gradient(LinearGradient)
    }

    @Environment(\.colorScheme) private var scheme
    private let style: Style
    private let content: () -> Content

    public init(style: Style = .standard, @ViewBuilder content: @escaping () -> Content) {
        self.style = style
        self.content = content
    }

    public var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

    @ViewBuilder
    private var cardBackground: some View {
        let base = RoundedRectangle(cornerRadius: 20, style: .continuous)
        switch style {
        case .standard:
            base.fill(EverFormTheme.Colors.cardBackground)
        case .tinted(let color):
            ZStack {
                base.fill(EverFormTheme.Colors.cardBackground)
                base.fill(color.opacity(0.12))
            }
        case .gradient(let gradient):
            ZStack {
                base.fill(EverFormTheme.Colors.cardBackground)
                base.fill(gradient)
            }
        }
    }
}

public struct EFSectionHeader: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    public init(title: String, subtitle: String? = nil, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(EFTheme.text(scheme))

                Spacer()

                if let actionTitle, let action {
                    Button(actionTitle, action: action)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .buttonStyle(.borderless)
                }
            }

            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(EFTheme.muted(scheme))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

public struct EFScreenContainer<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            EverFormTheme.Colors.appBackground
                .ignoresSafeArea()

            content
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Compatibility Components (for other features)

public struct EFPrimaryButton: View {
    let title: String
    let icon: String?
    let color: Color?
    let action: () -> Void
    
    public init(_ title: String, icon: String? = nil, color: Color? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                }
                Text(title)
                    .font(EverFormTheme.Fonts.buttonText())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: backgroundColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    private var backgroundColor: Color {
        color ?? EverFormTheme.Colors.primaryBlue
    }
}

public struct EFSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    public init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                  }
                  Text(title)
                      .font(EverFormTheme.Typography.button)
              }
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(Color.clear)
              .foregroundStyle(EverFormTheme.Colors.textPrimary)
              .overlay(
                  RoundedRectangle(cornerRadius: EverFormTheme.Radius.pill)
                      .stroke(EverFormTheme.Colors.textPrimary.opacity(0.3), lineWidth: 1)
              )
          }
    }
}

public struct EFPillChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    public init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
          Button(action: action) {
              Text(title)
                  .font(EverFormTheme.Typography.label)
                  .padding(.horizontal, 16)
                  .padding(.vertical, 8)
                  .background(isSelected ? EverFormTheme.Colors.textPrimary : EverFormTheme.Colors.card)
                  .foregroundStyle(isSelected ? EverFormTheme.Colors.background : EverFormTheme.Colors.textPrimary)
                  .clipShape(Capsule())
                  .overlay(
                      Capsule()
                          .stroke(EverFormTheme.Colors.cardStroke, lineWidth: isSelected ? 0 : 1)
                  )
          }
    }
}

public struct EFSegmentedControl<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T
    let titleFor: (T) -> String
    
    public init(items: [T], selection: Binding<T>, titleFor: @escaping (T) -> String) {
        self.items = items
        self._selection = selection
        self.titleFor = titleFor
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = item
                    }
                  } label: {
                      Text(titleFor(item))
                          .font(EverFormTheme.Typography.label)
                          .fontWeight(selection == item ? .semibold : .medium)
                          .foregroundStyle(selection == item ? EverFormTheme.Colors.textPrimary : EverFormTheme.Colors.textSecondary)
                          .frame(maxWidth: .infinity)
                          .padding(.vertical, 8)
                          .background(
                              ZStack {
                                  if selection == item {
                                      RoundedRectangle(cornerRadius: EverFormTheme.Radius.segmented - 2)
                                          .fill(EverFormTheme.Colors.card)
                                          .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                          .padding(2)
                                  }
                              }
                          )
                  }
                  .buttonStyle(PlainButtonStyle())
              }
          }
          .padding(2)
          .background(EverFormTheme.Colors.surface.opacity(0.5))
          .clipShape(RoundedRectangle(cornerRadius: EverFormTheme.Radius.segmented))
          .overlay(
              RoundedRectangle(cornerRadius: EverFormTheme.Radius.segmented)
                  .stroke(EverFormTheme.Colors.cardStroke, lineWidth: 0.5)
          )
      }
}

// MARK: - Legacy Header Compatibility

public struct EFHeader: View {
    private let title: String
    private let showBack: Bool
    private let action: (() -> Void)?
    private let extraTop: CGFloat = 6
    
    @Environment(\.dismiss) private var dismiss

    public init(title: String, showBack: Bool = false, action: (() -> Void)? = nil) {
        self.title = title
        self.showBack = showBack
        self.action = action
    }

    public var body: some View {
        HStack {
            if showBack {
                Button(action: {
                    if let action { action() } else { dismiss() }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(EverFormTheme.Colors.textPrimary)
                }
                .padding(.trailing, 8)
            }
            
            Text(title)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .kerning(-0.5)
                .foregroundStyle(EverFormTheme.Colors.textPrimary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, extraTop)
        .accessibilityAddTraits(.isHeader)
        .safeAreaPadding(.top)
    }
}

public typealias EFScreenHeader = EFHeader
