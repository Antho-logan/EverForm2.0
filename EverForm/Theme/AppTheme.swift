//
//  AppTheme.swift
//  EverForm
//
//  Single semantic theme surface for the app.
//  Backed by Asset Catalog colors (Light/Dark variants).
//

import SwiftUI

enum AppTheme {
  enum Colors {
    // Surfaces
    static let appBackground = Color("AppBackground")
    static let surface = Color("Surface")
    static let surfaceSecondary = Color("Surface2")

    // Text
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")

    // Lines / depth
    static let separator = Color("EFSeparator")
    static let shadow = Color("Shadow")

    // Brand / status
    static let brandBlue = Color("BrandBlue")
    static let dangerBackground = Color("DangerBg")
    static let dangerText = Color("DangerText")
  }
}


