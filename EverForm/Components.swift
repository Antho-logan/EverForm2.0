//
//  Components.swift
//  EverForm
//
//  Created by Assistant on 14/01/2025.
//  Premium UI Components - Reusable Design System Components
//

import SwiftUI

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
                        .font(DesignSystem.Typography.buttonLarge())
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

struct ButtonSecondary: View {
    let title: String
    let action: () -> Void
    let isDisabled: Bool
    
    @State private var isPressed = false
    
    init(
        _ title: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: {
            guard !isDisabled else { return }
            
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
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
            Text(title)
                .font(DesignSystem.Typography.buttonLarge())
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: DesignSystem.TouchTarget.minimum)
                .foregroundColor(isDisabled ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.accent)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                        .fill(DesignSystem.Colors.backgroundSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                                .stroke(isDisabled ? DesignSystem.Colors.neutral200 : DesignSystem.Colors.border, lineWidth: 1)
                        )
                )
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(DesignSystem.Animation.springFast, value: isPressed)
        }
        .disabled(isDisabled)
        .accessibilityLabel(title)
    }
}

// MARK: - Input Components

struct TextFieldPrimary: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let isSecure: Bool
    
    @FocusState private var isFocused: Bool
    @State private var hasError = false
    
    init(
        _ label: String,
        placeholder: String = "",
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        isSecure: Bool = false
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.isSecure = isSecure
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(label)
                .font(DesignSystem.Typography.labelMedium())
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(DesignSystem.Typography.bodyLarge())
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .keyboardType(keyboardType)
            .textContentType(textContentType)
            .autocorrectionDisabled(keyboardType == .emailAddress)
            .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .sentences)
            .focused($isFocused)
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                            .stroke(
                                isFocused ? DesignSystem.Colors.accent : 
                                hasError ? DesignSystem.Colors.error : DesignSystem.Colors.border,
                                lineWidth: isFocused ? 2 : 1
                            )
                    )
            )
            .animation(DesignSystem.Animation.easeInOut, value: isFocused)
        }
        .accessibilityLabel(label)
        .accessibilityHint("Enter your \(label.lowercased())")
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
                    .font(DesignSystem.Typography.labelMedium())
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
                    .font(DesignSystem.Typography.caption())
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
                            .frame(width: DesignSystem.TouchTarget.minimum, height: DesignSystem.TouchTarget.minimum)
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
                            .font(DesignSystem.Typography.caption())
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
                            .frame(width: DesignSystem.TouchTarget.minimum, height: DesignSystem.TouchTarget.minimum)
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
                        .font(.system(size: DesignSystem.IconSize.small, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(DesignSystem.Animation.springFast, value: isSelected)
                }
                
                Text(title)
                    .font(DesignSystem.Typography.labelSmall())
                    .foregroundColor(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
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
