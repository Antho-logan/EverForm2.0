//
//  PainHelperSheet.swift
//  EverForm
//
//  Pain helper bottom sheet with body region selector
//

import SwiftUI

struct PainHelperSheet: View {
    let onCoachRoute: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedRegion: PainRegion?
    
    enum PainRegion: String, CaseIterable {
        case back = "Back"
        case neck = "Neck"
        case knees = "Knees"
        case shoulders = "Shoulders"
        case hips = "Hips"
        case wrists = "Wrists"
        
        var icon: String {
            switch self {
            case .back: return "figure.stand"
            case .neck: return "head.profile"
            case .knees: return "figure.walk"
            case .shoulders: return "figure.arms.open"
            case .hips: return "figure.flexibility"
            case .wrists: return "hand.raised"
            }
        }
        
        var description: String {
            switch self {
            case .back: return "Lower or upper back discomfort"
            case .neck: return "Neck tension or stiffness"
            case .knees: return "Knee pain or soreness"
            case .shoulders: return "Shoulder tension or pain"
            case .hips: return "Hip tightness or discomfort"
            case .wrists: return "Wrist pain or strain"
            }
        }
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        NavigationView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Fix Pain")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                    
                    Text("Select the area where you're experiencing discomfort")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Region selection grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Theme.Spacing.sm),
                    GridItem(.flexible(), spacing: Theme.Spacing.sm)
                ], spacing: Theme.Spacing.sm) {
                    ForEach(PainRegion.allCases, id: \.self) { region in
                        Button(action: {
                            selectedRegion = region
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }) {
                            VStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: region.icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(
                                        selectedRegion == region ?
                                        .white :
                                        palette.textPrimary
                                    )
                                    .frame(width: 40, height: 40)
                                
                                VStack(spacing: 4) {
                                    Text(region.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(
                                            selectedRegion == region ?
                                            .white :
                                            palette.textPrimary
                                        )
                                    
                                    Text(region.description)
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundStyle(
                                            selectedRegion == region ?
                                            .white.opacity(0.8) :
                                            palette.textSecondary
                                        )
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .frame(height: 120)
                            .background(
                                selectedRegion == region ?
                                Color.red :
                                palette.surface
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.card)
                                    .stroke(
                                        selectedRegion == region ?
                                        Color.red :
                                        palette.stroke,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Get help button
                Button(action: {
                    guard let region = selectedRegion else { return }
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onCoachRoute(region.rawValue)
                }) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("Get Help from Coach")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md)
                    .background(selectedRegion != nil ? Color.red : palette.textSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                }
                .buttonStyle(.plain)
                .disabled(selectedRegion == nil)
                
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(palette.accent)
                }
            }
        }
    }
}
