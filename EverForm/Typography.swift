//
//  Typography.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//  Unified Typography System
//
//  USAGE:
//  Use `Font.app(.style)` for all text in the app.
//  - Headers (Science Gothic): .largeTitle, .title, .heading
//  - Body (Open Sans): .body, .caption, .label
//
//  Example:
//  Text("Title").font(.app(.largeTitle))
//  Text("Body").font(.app(.body))
//

import SwiftUI

/// Defines the semantic typography styles for the app.
enum AppFontStyle {
  /// Large screen titles (e.g. "Overview", "Training") - Science Gothic
  case largeTitle
  /// Section headers (e.g. "Key Metrics") - Science Gothic
  case title
  /// Card titles or subsections - Science Gothic
  case heading

  /// Standard body text - Open Sans
  case body
  /// Secondary text, descriptions - Open Sans
  case bodySecondary
  /// Small labels, timestamps - Open Sans
  case caption
  /// Button text - Open Sans
  case button
  /// Form labels - Open Sans
  case label
}

extension Font {
  /// Returns the custom font for the given style.
  static func app(_ style: AppFontStyle) -> Font {
    switch style {
    case .largeTitle:
      return Font.custom("ScienceGothic-SemiBold", size: 34)
        .weight(.semibold)
    case .title:
      return Font.custom("ScienceGothic-Medium", size: 24)
        .weight(.medium)
    case .heading:
      return Font.custom("ScienceGothic-Medium", size: 20)
        .weight(.medium)

    case .body:
      return Font.custom("OpenSans-Regular", size: 16)
    case .bodySecondary:
      return Font.custom("OpenSans-Regular", size: 14)
    case .caption:
      return Font.custom("OpenSans-Regular", size: 12)
    case .button:
      return Font.custom("OpenSans-SemiBold", size: 16)
        .weight(.semibold)
    case .label:
      return Font.custom("OpenSans-Medium", size: 12)
        .weight(.medium)
    }
  }

  // Fallback/Helper to register fonts if needed (Optional, but good for debugging)
  static func printAvailableFonts() {
    for family in UIFont.familyNames.sorted() {
      let names = UIFont.fontNames(forFamilyName: family)
      print("Family: \(family) Font names: \(names)")
    }
  }
}

// MARK: - Deprecated/Compatibility Layer
// Keeping the EverFont enum for backward compatibility during refactor,
// but mapping it to the new system where possible.

enum EverFont {
  static let body = Font.app(.body)
  static let bodySecondary = Font.app(.bodySecondary)
  static let button = Font.app(.button)
  static let caption = Font.app(.caption)
  static let smallCaption = Font.custom("OpenSans-Regular", size: 10)
  static let label = Font.app(.label)

  static var largeTitle: Font { Font.app(.largeTitle) }
  static var sectionTitle: Font { Font.app(.title) }
  static var cardTitle: Font { Font.app(.heading) }
  static var navTitle: Font { Font.app(.title) }
}

// MARK: - View Modifiers

struct EverBodyText: ViewModifier {
  func body(content: Content) -> some View {
    content.font(.app(.body))
  }
}

struct EverBodySecondaryText: ViewModifier {
  func body(content: Content) -> some View {
    content.font(.app(.bodySecondary))
  }
}

extension View {
  func everBody() -> some View {
    self.modifier(EverBodyText())
  }

  func everBodySecondary() -> some View {
    self.modifier(EverBodySecondaryText())
  }
}
