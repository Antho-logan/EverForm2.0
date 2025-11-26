import SwiftUI

struct EFCard<Content: View>: View {
    enum Style {
        case standard
        case tinted(Color)
        case gradient(LinearGradient)
    }

    @Environment(\.colorScheme) private var scheme
    private let style: Style
    private let content: () -> Content

    init(style: Style = .standard, @ViewBuilder content: @escaping () -> Content) {
        self.style = style
        self.content = content
    }

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
    }

    @ViewBuilder
    private var cardBackground: some View {
        let base = RoundedRectangle(cornerRadius: 18, style: .continuous)
        switch style {
        case .standard:
            base.fill(EFTheme.surface(scheme))
        case .tinted(let color):
            ZStack {
                base.fill(EFTheme.surface(scheme))
                base.fill(color.opacity(scheme == .light ? 0.12 : 0.25))
            }
        case .gradient(let gradient):
            ZStack {
                base.fill(EFTheme.surface(scheme))
                base.fill(gradient)
            }
        }
    }

    private var borderColor: Color {
        switch style {
        case .standard:
            return EFTheme.cardStroke(scheme)
        case .tinted(let color):
            return color.opacity(scheme == .light ? 0.45 : 0.7)
        case .gradient:
            return EFTheme.cardStroke(scheme).opacity(0.35)
        }
    }

    private var shadowColor: Color {
        switch scheme {
        case .dark:
            return .black.opacity(0.4)
        default:
            return .black.opacity(styleShadowOpacity)
        }
    }

    private var styleShadowOpacity: Double {
        switch style {
        case .standard:
            return 0.08
        case .tinted:
            return 0.12
        case .gradient:
            return 0.15
        }
    }
}

struct EFSectionHeader: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    var subtitle: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
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
