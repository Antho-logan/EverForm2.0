//
//  FixPainView.swift
//  EverForm
//
//  Full-screen pain relief with body region selection
//

import SwiftUI

struct FixPainView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedRegion: PainRegion?
    @State private var showingDetail = false
    
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
        let semantic = Theme.semantic(colorScheme)
        
        NavigationView {
            VStack(spacing: Theme.Spacing.xl) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Fix Pain")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                    
                    Text("Select the area where you're experiencing discomfort")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Body region grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: Theme.Spacing.md),
                    GridItem(.flexible(), spacing: Theme.Spacing.md)
                ], spacing: Theme.Spacing.md) {
                    ForEach(PainRegion.allCases, id: \.self) { region in
                        Button(action: {
                            selectedRegion = region
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }) {
                            EFCard {
                                VStack(spacing: Theme.Spacing.md) {
                                    Image(systemName: region.icon)
                                        .font(.system(size: 32, weight: .medium))
                                        .foregroundStyle(
                                            selectedRegion == region ?
                                            .white : semantic.danger
                                        )
                                        .frame(width: 48, height: 48)
                                    
                                    VStack(spacing: 4) {
                                        Text(region.rawValue)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(
                                                selectedRegion == region ?
                                                .white : palette.textPrimary
                                            )
                                        
                                        Text(region.description)
                                            .font(.system(size: 12, weight: .regular))
                                            .foregroundStyle(
                                                selectedRegion == region ?
                                                .white.opacity(0.8) : palette.textSecondary
                                            )
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2)
                                    }
                                }
                                .frame(height: 120)
                            }
                            .background(
                                selectedRegion == region ?
                                semantic.danger : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
                
                // Continue button
                if let selectedRegion = selectedRegion {
                    Button(action: {
                        showingDetail = true
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                    }) {
                        Text("Get Relief Plan")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(semantic.danger)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(Theme.Spacing.lg)
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(palette.accent)
                }
            }
        }
        .interactiveDismissDisabled(false)
        .fullScreenCover(isPresented: $showingDetail) {
            if let region = selectedRegion {
                FixPainDetailView(region: region)
            }
        }
    }
}

#Preview {
    FixPainView()
}
