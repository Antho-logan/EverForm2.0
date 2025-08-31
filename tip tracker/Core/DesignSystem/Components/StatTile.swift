// StatTile.swift
import SwiftUI

public struct StatTile: View {
  public var icon: String; public var title: String; public var value: String; public var sub: String? = nil
  public init(icon: String, title: String, value: String, sub: String? = nil) { self.icon = icon; self.title = title; self.value = value; self.sub = sub }
  public var body: some View {
    HStack(spacing: DS.Spacing.md) {
      ZStack { Circle().fill(DS.ColorToken.accent.opacity(0.12)) ; Image(systemName: icon).foregroundStyle(DS.ColorToken.accent) }
        .frame(width: 36, height: 36)
      VStack(alignment: .leading, spacing: 2) {
        Text(title).font(.footnote).foregroundStyle(DS.ColorToken.muted)
        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text(value).font(.title3).fontWeight(.semibold)
          if let sub { Text(sub).font(.footnote).foregroundStyle(DS.ColorToken.muted) }
        }
      }
      Spacer()
    }
    .padding(DS.Spacing.md)
    .efCardBackground()
  }
}

