//
//  ScanView.swift
//  EverForm
//
//  Polished scan screen with EFCard styles and empty states
//

import SwiftUI
import PhotosUI

struct ScanView: View {
    @State private var selectedMode: ScanMode = .calorie
    @State private var scanHistory: [ScanHistoryItem] = []
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showingExplainer = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        VStack(spacing: 0) {
            // Header with segmented control and explain button
            VStack(spacing: Theme.Spacing.md) {
                HStack {
                    Text("Scan Food")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                    
                    Spacer()
                    
                    Button("Explain this mode") {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        showingExplainer = true
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.accent)
                }
                
                // Segmented control
                Picker("Scan Mode", selection: $selectedMode) {
                    ForEach(ScanMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.top, Theme.Spacing.sm)
            
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Mode info card
                    modeInfoCard
                    
                    // Action buttons card
                    actionButtonsCard
                    
                    // Recent scans card
                    recentScansCard
                    
                    // Bottom padding
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.lg)
            }
        }
        .background(palette.background)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingExplainer) {
            ExplainerView(mode: selectedMode)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Mode Info Card
    
    private var modeInfoCard: some View {
        EFCard {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: modeIcon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Theme.palette(colorScheme).accent)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(modeTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.palette(colorScheme).textPrimary)
                    
                    Text(modeSubtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.palette(colorScheme).textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Action Buttons Card
    
    private var actionButtonsCard: some View {
        EFCard {
            VStack(spacing: Theme.Spacing.md) {
                // Mock result button
                EFPillButton(
                    title: "Generate Mock Result",
                    style: .primary,
                    action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        generateMockResult()
                    }
                )
                
                // Photo picker
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "photo")
                            .font(.system(size: 16, weight: .medium))
                        Text("Import Photo")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(Theme.palette(colorScheme).accent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Theme.palette(colorScheme).accent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.pill)
                            .stroke(Theme.palette(colorScheme).accent, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .onChange(of: selectedPhoto) { _, newItem in
                    if newItem != nil {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        handlePhotoSelection()
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Scans Card
    
    private var recentScansCard: some View {
        EFCard {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Recent Scans")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.palette(colorScheme).textPrimary)
                
                if scanHistory.isEmpty {
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(Theme.palette(colorScheme).textSecondary)

                        VStack(spacing: 4) {
                            Text("Nothing scanned yet")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.palette(colorScheme).textPrimary)

                            Text("Try a mock result to see how it works")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Theme.palette(colorScheme).textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.xl)
                } else {
                    VStack(spacing: Theme.Spacing.sm) {
                        ForEach(scanHistory) { item in
                            HStack {
                                Text(item.title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Theme.palette(colorScheme).textPrimary)
                                
                                Spacer()
                                
                                Text(formatDate(item.date))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.palette(colorScheme).textSecondary)
                            }
                            .padding(.vertical, Theme.Spacing.xs)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var modeIcon: String {
        switch selectedMode {
        case .calorie: return "barcode.viewfinder"
        case .ingredients: return "list.bullet.rectangle"
        case .plateAI: return "camera.aperture"
        }
    }
    
    private var modeTitle: String {
        switch selectedMode {
        case .calorie: return "Calorie & Macros"
        case .ingredients: return "Ingredients Check"
        case .plateAI: return "Plate AI (beta)"
        }
    }
    
    private var modeSubtitle: String {
        switch selectedMode {
        case .calorie: return "Scan barcode or nutrition label for accurate calorie and macro information"
        case .ingredients: return "Assess additives and quality of packaged foods"
        case .plateAI: return "Estimate macros from a photo of your meal"
        }
    }
    
    // MARK: - Actions
    
    private func generateMockResult() {
        let mockItem = ScanHistoryItem(
            title: "Mock \(modeTitle) Result",
            date: Date()
        )
        scanHistory.insert(mockItem, at: 0)
    }
    
    private func handlePhotoSelection() {
        // Handle photo selection
        print("Photo selected for \(selectedMode)")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Components

private struct EFPillButton: View {
    let title: String
    let style: Style
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    enum Style {
        case primary, secondary
    }

    var body: some View {
        let palette = Theme.palette(colorScheme)

        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(style == .primary ? .white : palette.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(style == .primary ? palette.accent : palette.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.pill)
                        .stroke(style == .primary ? Color.clear : palette.accent, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ExplainerView: View {
    let mode: ScanMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let palette = Theme.palette(colorScheme)

        NavigationView {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    Text("How \(modeTitle) Works")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(palette.textPrimary)

                    Text(explanation)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(palette.textSecondary)
                        .lineSpacing(4)
                }

                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(palette.surfaceElevated)
            .navigationTitle("Scan Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(palette.accent)
                }
            }
        }
    }

    private var modeTitle: String {
        switch mode {
        case .calorie: return "Calorie & Macros"
        case .ingredients: return "Ingredients Check"
        case .plateAI: return "Plate AI"
        }
    }

    private var explanation: String {
        switch mode {
        case .calorie:
            return "Point your camera at a barcode or nutrition label to instantly get accurate calorie and macro information. This works with most packaged foods and provides the most reliable nutritional data."
        case .ingredients:
            return "Scan ingredient lists to get insights about food quality, additives, and potential allergens. We'll highlight concerning ingredients and provide healthier alternatives when possible."
        case .plateAI:
            return "Take a photo of your meal and our AI will estimate the calories and macros. This feature is in beta and works best with clearly visible, well-lit meals on a plate or bowl."
        }
    }
}

// MARK: - Supporting Types
// Using existing ScanMode and ScanHistoryItem from ScanModels.swift

#Preview {
    NavigationView {
        ScanView()
    }
}
