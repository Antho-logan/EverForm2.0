//
//  FixPainAssessmentView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI
import PhotosUI

struct FixPainAssessmentFlowView: View {
    @ObservedObject var viewModel: FixPainViewModel
    @Binding var isPresented: Bool
    
    @State private var stepIndex = 0
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showResult = false
    
    // Define steps for cleaner logic
    private let totalSteps = 5
    
    var body: some View {
        NavigationStack {
            EFScreenContainer {
                VStack(spacing: 0) {
                    // 1. Top Bar
                    HStack {
                        Button {
                            if stepIndex > 0 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    stepIndex -= 1
                                }
                            } else {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(EverFormTheme.Colors.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(EverFormTheme.Colors.cardBackground)
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        FixPainProgressBar(progress: Double(stepIndex + 1) / Double(totalSteps))
                            .frame(width: 100)
                        
                        Spacer()
                        
                        // Placeholder to balance layout
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // 2. Main Content (Wizard)
                    TabView(selection: $stepIndex) {
                        // Step 1: Body Region
                        BodyRegionStep(assessment: Binding(get: { viewModel.currentAssessment ?? FixPainAssessment() }, set: { viewModel.currentAssessment = $0 }))
                            .tag(0)
                        
                        // Step 2: Pain Details
                        PainDetailsStep(assessment: Binding(get: { viewModel.currentAssessment ?? FixPainAssessment() }, set: { viewModel.currentAssessment = $0 }))
                            .tag(1)
                        
                        // Step 3: Context
                        TriggersStep(assessment: Binding(get: { viewModel.currentAssessment ?? FixPainAssessment() }, set: { viewModel.currentAssessment = $0 }))
                            .tag(2)
                        
                        // Step 4: Media
                        MediaStep(assessment: Binding(get: { viewModel.currentAssessment ?? FixPainAssessment() }, set: { viewModel.currentAssessment = $0 }), selectedPhoto: $selectedPhoto)
                            .tag(3)
                            
                        // Step 5: Summary
                        SummaryStep(assessment: Binding(get: { viewModel.currentAssessment ?? FixPainAssessment() }, set: { viewModel.currentAssessment = $0 }))
                            .tag(4)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarHidden(true)
            // Bottom action is a true safe-area inset so content doesn't need magic bottom padding.
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 16) {
                    if stepIndex < totalSteps - 1 {
                        Button("Continue") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                stepIndex += 1
                            }
                        }
                        .primaryStyle()
                    } else {
                        if viewModel.isLoadingPlan {
                            ProgressView("Generating Plan...")
                        } else {
                            Button("Generate Plan") {
                                Task {
                                    await viewModel.submitAssessmentAndLoadPlan()
                                    if viewModel.plan != nil {
                                        showResult = true
                                    }
                                }
                            }
                            .primaryStyle()
                        }

                        if let error = viewModel.submitErrorMessage {
                            Text(error)
                                .font(EverFormTheme.Typography.caption)
                                .foregroundColor(EverFormTheme.Colors.errorRed)
                                .padding(.top, 4)
                        }
                    }
                }
                .screenPadding()
                .padding(.vertical, 16)
                .background(EverFormTheme.Colors.appBackground.ignoresSafeArea(edges: .bottom))
            }
            .fullScreenCover(isPresented: $showResult) {
                if let plan = viewModel.plan {
                    FixPainResultView(plan: plan, isPresented: $isPresented)
                }
            }
        }
    }
}

// MARK: - Refactored Steps

struct BodyRegionStep: View {
    @Binding var assessment: FixPainAssessment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FixPainStepHeader(
                    step: 1,
                    totalSteps: 5,
                    title: "Where does it hurt?",
                    subtitle: "Select the area that is bothering you the most right now."
                )
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(PainRegion.allCases) { region in
                        FixPainChip(title: region.rawValue, isSelected: assessment.region == region) {
                            assessment.region = region
                            // Reset side if invalid for new region
                            if !availableSides(for: region).contains(assessment.side ?? .left) {
                                assessment.side = nil
                            }
                        }
                    }
                }
                .screenPadding()
                
                if let region = assessment.region {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Which Side?")
                            .sectionTitle()
                            .screenPadding()
                        
                        HStack(spacing: 12) {
                            ForEach(availableSides(for: region)) { side in
                                FixPainChip(title: side.rawValue, isSelected: assessment.side == side) {
                                    assessment.side = side
                                }
                            }
                        }
                        .screenPadding()
                    }
                    .padding(.top, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func availableSides(for region: PainRegion) -> [PainSide] {
        switch region {
        case .neck, .upperBack, .lowerBack:
            return [.left, .right, .both, .central]
        default:
            return [.left, .right, .both]
        }
    }
}

struct PainDetailsStep: View {
    @Binding var assessment: FixPainAssessment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                FixPainStepHeader(
                    step: 2,
                    totalSteps: 5,
                    title: "How does it feel?",
                    subtitle: "Help us understand the intensity and nature of your pain."
                )
                
                // Intensity Slider
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Intensity")
                            .sectionTitle()
                        Spacer()
                        Text("\(Int(assessment.intensity))/10")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(intensityColor(assessment.intensity))
                    }
                    
                    Slider(value: $assessment.intensity, in: 0...10, step: 1)
                        .tint(intensityColor(assessment.intensity))
                        .padding(.vertical, 8) // More tap area
                    
                    HStack {
                        Text("Mild").font(EverFormTheme.Typography.caption).foregroundStyle(EverFormTheme.Colors.textSecondary)
                        Spacer()
                        Text("Severe").font(EverFormTheme.Typography.caption).foregroundStyle(EverFormTheme.Colors.textSecondary)
                    }
                }
                .screenPadding()
                
                // Quality
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sensation")
                        .sectionTitle()
                        .screenPadding()
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(PainQuality.allCases) { quality in
                            FixPainChip(title: quality.rawValue, isSelected: assessment.quality == quality) {
                                assessment.quality = quality
                            }
                        }
                    }
                    .screenPadding()
                }
                
                // Onset
                VStack(alignment: .leading, spacing: 12) {
                    Text("When did it start?")
                        .sectionTitle()
                        .screenPadding()
                    
                    HStack(spacing: 12) {
                        ForEach(PainOnset.allCases) { onset in
                            FixPainChip(title: onset.rawValue, isSelected: assessment.onset == onset) {
                                assessment.onset = onset
                            }
                        }
                    }
                    .screenPadding()
                }
            }
        }
    }
    
    func intensityColor(_ value: Double) -> Color {
        value > 7 ? EverFormTheme.Colors.errorRed : (value > 4 ? EverFormTheme.Colors.warningAmber : EverFormTheme.Colors.successGreen)
    }
}

struct TriggersStep: View {
    @Binding var assessment: FixPainAssessment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FixPainStepHeader(
                    step: 3,
                    totalSteps: 5,
                    title: "Context",
                    subtitle: "Details about what makes it better or worse help refine the plan."
                )
                
                VStack(spacing: 12) {
                    FixPainToggleRow(title: "Worse with movement?", isOn: $assessment.movementWorse)
                    FixPainToggleRow(title: "Worse with rest?", isOn: $assessment.restWorse)
                    FixPainToggleRow(title: "Desk/Phone Strain?", isOn: $assessment.postureStrain)
                }
                .screenPadding()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Red Flags")
                        .sectionTitle()
                        .foregroundStyle(EverFormTheme.Colors.errorRed)
                        .screenPadding()
                    
                    VStack(spacing: 12) {
                        FixPainToggleRow(title: "Recent Trauma / Fall", isOn: $assessment.recentTrauma)
                        FixPainToggleRow(title: "Numbness / Tingling", isOn: $assessment.numbnessOrTingling)
                        FixPainToggleRow(title: "Night Pain", isOn: $assessment.nightPain)
                    }
                    .screenPadding()
                }
            }
        }
    }
}

struct MediaStep: View {
    @Binding var assessment: FixPainAssessment
    @Binding var selectedPhoto: PhotosPickerItem?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FixPainStepHeader(
                    step: 4,
                    totalSteps: 5,
                    title: "Show us (Optional)",
                    subtitle: "Add a photo if you have visible swelling or bruising."
                )
                
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(EverFormTheme.Colors.cardBackground)
                            .frame(height: 240)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundStyle(EverFormTheme.Colors.textSecondary.opacity(0.3))
                            )
                        
                        if let data = assessment.attachedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(EverFormTheme.Colors.primaryBlue)
                                Text("Tap to upload photo")
                                    .font(EverFormTheme.Typography.body)
                                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
                .screenPadding()
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            assessment.attachedImageData = data
                        }
                    }
                }
            }
        }
    }
}

struct SummaryStep: View {
    @Binding var assessment: FixPainAssessment
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                FixPainStepHeader(
                    step: 5,
                    totalSteps: 5,
                    title: "Summary",
                    subtitle: "Review your details before we generate your recovery plan."
                )
                
                EverFormCard {
                    VStack(spacing: 16) {
                        SummaryCardRow(icon: "figure.stand", label: "Region", value: assessment.region?.rawValue ?? "-")
                        SummaryCardRow(icon: "exclamationmark.circle", label: "Intensity", value: "\(Int(assessment.intensity))/10")
                        SummaryCardRow(icon: "clock", label: "Onset", value: assessment.onset?.rawValue ?? "-")
                        
                        if assessment.recentTrauma || assessment.nightPain {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(EverFormTheme.Colors.errorRed)
                                Text("Red flags reported")
                                    .font(EverFormTheme.Typography.caption)
                                    .foregroundStyle(EverFormTheme.Colors.errorRed)
                                Spacer()
                            }
                            .padding()
                            .background(EverFormTheme.Colors.errorRed.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .screenPadding()
            }
        }
    }
}

struct SummaryCardRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                .frame(width: 24)
            Text(label)
                .font(EverFormTheme.Typography.body)
                .foregroundStyle(EverFormTheme.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(EverFormTheme.Typography.body.weight(.semibold))
                .foregroundStyle(EverFormTheme.Colors.textPrimary)
        }
    }
}

// Helper Chip Component
struct FixPainChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(EverFormTheme.Typography.body)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? EverFormTheme.Colors.textOnAccent : EverFormTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? EverFormTheme.Colors.fixPainIndigo : EverFormTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(EverFormTheme.Colors.cardStroke, lineWidth: isSelected ? 0 : 1)
                )
                .shadow(color: isSelected ? EverFormTheme.Colors.fixPainIndigo.opacity(0.3) : Color.clear, radius: 4, y: 2)
        }
    }
}
