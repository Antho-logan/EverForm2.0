//
//  FixPainAssessmentView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI
import PhotosUI

struct FixPainAssessmentFlowView: View {
    @Bindable var viewModel: FixPainViewModel
    @Binding var isPresented: Bool
    
    @State private var stepIndex = 0
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showResult = false
    
    // Define steps for cleaner logic
    private let totalSteps = 5
    
    var body: some View {
        NavigationStack {
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
                            .foregroundStyle(FixPainTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(FixPainTheme.cardBackgroundSecondary)
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
                // Disable swipe to enforce button navigation if desired, currently enabled for fluid feel
                
                // 3. Bottom Action Area
                VStack(spacing: 16) {
                    if stepIndex < totalSteps - 1 {
                        FixPainPrimaryButton(title: "Continue") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                stepIndex += 1
                            }
                        }
                    } else {
                        FixPainPrimaryButton(title: "Generate Plan") {
                            if let assessment = viewModel.currentAssessment {
                                viewModel.generatePlan(for: assessment)
                                showResult = true
                            }
                        }
                    }
                }
                .padding(.horizontal, FixPainTheme.paddingLarge)
                .padding(.top, 20)
                .padding(.bottom, 10) // Safe area handled by wrapper usually, but extra padding looks nice
            }
            .navigationBarHidden(true)
            .background(FixPainTheme.background.ignoresSafeArea())
            .navigationDestination(isPresented: $showResult) {
                if let plan = viewModel.generatedPlan {
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
                        }
                    }
                }
                .padding(.horizontal, FixPainTheme.paddingLarge)
                
                if let _ = assessment.region {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Which Side?")
                            .font(.headline)
                            .padding(.horizontal, FixPainTheme.paddingLarge)
                        
                        HStack(spacing: 12) {
                            ForEach(PainSide.allCases) { side in
                                FixPainChip(title: side.rawValue, isSelected: assessment.side == side) {
                                    assessment.side = side
                                }
                            }
                        }
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    }
                    .padding(.top, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.bottom, 100) // Spacing for bottom button
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
                            .font(.headline)
                        Spacer()
                        Text("\(Int(assessment.intensity))/10")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(intensityColor(assessment.intensity))
                    }
                    
                    Slider(value: $assessment.intensity, in: 0...10, step: 1)
                        .tint(intensityColor(assessment.intensity))
                    
                    HStack {
                        Text("Mild").font(.caption).foregroundStyle(.gray)
                        Spacer()
                        Text("Severe").font(.caption).foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, FixPainTheme.paddingLarge)
                
                // Quality
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sensation")
                        .font(.headline)
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(PainQuality.allCases) { quality in
                            FixPainChip(title: quality.rawValue, isSelected: assessment.quality == quality) {
                                assessment.quality = quality
                            }
                        }
                    }
                    .padding(.horizontal, FixPainTheme.paddingLarge)
                }
                
                // Onset
                VStack(alignment: .leading, spacing: 12) {
                    Text("When did it start?")
                        .font(.headline)
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    
                    HStack(spacing: 12) {
                        ForEach(PainOnset.allCases) { onset in
                            FixPainChip(title: onset.rawValue, isSelected: assessment.onset == onset) {
                                assessment.onset = onset
                            }
                        }
                    }
                    .padding(.horizontal, FixPainTheme.paddingLarge)
                }
            }
            .padding(.bottom, 100)
        }
    }
    
    func intensityColor(_ value: Double) -> Color {
        value > 7 ? .red : (value > 4 ? .orange : .green)
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
                .padding(.horizontal, FixPainTheme.paddingLarge)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Red Flags")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    
                    VStack(spacing: 12) {
                        FixPainToggleRow(title: "Recent Trauma / Fall", isOn: $assessment.recentTrauma)
                        FixPainToggleRow(title: "Numbness / Tingling", isOn: $assessment.numbnessOrTingling)
                        FixPainToggleRow(title: "Night Pain", isOn: $assessment.nightPain)
                    }
                    .padding(.horizontal, FixPainTheme.paddingLarge)
                }
            }
            .padding(.bottom, 100)
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
                            .fill(FixPainTheme.cardBackground)
                            .frame(height: 240)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                    .foregroundStyle(Color.gray.opacity(0.3))
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
                                    .foregroundStyle(FixPainTheme.primary)
                                Text("Tap to upload photo")
                                    .font(.subheadline)
                                    .foregroundStyle(FixPainTheme.textSecondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, FixPainTheme.paddingLarge)
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
                
                VStack(spacing: 16) {
                    SummaryCardRow(icon: "figure.stand", label: "Region", value: assessment.region?.rawValue ?? "-")
                    SummaryCardRow(icon: "exclamationmark.circle", label: "Intensity", value: "\(Int(assessment.intensity))/10")
                    SummaryCardRow(icon: "clock", label: "Onset", value: assessment.onset?.rawValue ?? "-")
                    
                    if assessment.recentTrauma || assessment.nightPain {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            Text("Red flags reported")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(20)
                .background(FixPainTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, FixPainTheme.paddingLarge)
            }
            .padding(.bottom, 100)
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
                .foregroundStyle(FixPainTheme.textSecondary)
                .frame(width: 24)
            Text(label)
                .foregroundStyle(FixPainTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(FixPainTheme.textPrimary)
        }
    }
}

