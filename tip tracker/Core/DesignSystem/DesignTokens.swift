// DesignTokens.swift
import SwiftUI

public enum DS {
  public enum ColorToken {
    public static let bg = Color(.systemBackground)
    public static let card = Color(.secondarySystemBackground).opacity(0.98)
    public static let border = Color.black.opacity(0.06)
    public static let shadow = Color.black.opacity(0.12)
    public static let accent = Color(#colorLiteral(red:0.10, green:0.45, blue:0.98, alpha:1))
    public static let good = Color(#colorLiteral(red:0.12, green:0.68, blue:0.37, alpha:1))
    public static let warn = Color(#colorLiteral(red:0.98, green:0.66, blue:0.15, alpha:1))
    public static let bad  = Color(#colorLiteral(red:0.95, green:0.23, blue:0.20, alpha:1))
    public static let muted = Color.secondary
  }
  public enum Radius {
    public static let card: CGFloat = 16
    public static let chip: CGFloat = 12
  }
  public enum Spacing {
    public static let xxs: CGFloat = 6
    public static let xs:  CGFloat = 8
    public static let sm:  CGFloat = 12
    public static let md:  CGFloat = 16
    public static let lg:  CGFloat = 20
    public static let xl:  CGFloat = 24
  }
  public enum Anim {
    public static let fast = Animation.easeOut(duration: 0.20)
    public static let med  = Animation.easeOut(duration: 0.30)
  }
  public enum Shadow {
    public static let card = ShadowStyle(color: ColorToken.shadow, radius: 10, y: 6)
  }
}

public struct ShadowStyle {
  public let color: Color; public let radius: CGFloat; public let x: CGFloat; public let y: CGFloat
  public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
    self.color = color; self.radius = radius; self.x = x; self.y = y
  }
}

public extension View {
  func efCardBackground() -> some View {
    self
      .background(DS.ColorToken.card)
      .overlay(RoundedRectangle(cornerRadius: DS.Radius.card).stroke(DS.ColorToken.border, lineWidth: 1))
      .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
      .shadow(color: DS.ColorToken.shadow, radius: DS.Shadow.card.radius, x: DS.Shadow.card.x, y: DS.Shadow.card.y)
  }
}

