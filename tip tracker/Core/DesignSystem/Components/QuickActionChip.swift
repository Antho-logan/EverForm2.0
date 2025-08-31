// QuickActionChip.swift
import SwiftUI

public struct QuickActionChip: View {
  let icon: String; let title: String; let action: ()->Void
  public init(icon: String, title: String, action: @escaping ()->Void) { self.icon = icon; self.title = title; self.action = action }
  public var body: some View {
    Button(action: action) {
      HStack(spacing: 8) { Image(systemName: icon); Text(title) }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: DS.Radius.chip).fill(DS.ColorToken.card))
        .overlay(RoundedRectangle(cornerRadius: DS.Radius.chip).stroke(DS.ColorToken.border, lineWidth: 1))
    }
    .buttonStyle(.plain)
  }
}

