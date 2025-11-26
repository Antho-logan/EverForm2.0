//
//  FixPainSheet.swift
//  EverForm
//
//  Body region selection for AI physio consultation
//  Assumptions: Routes to Coach with prefilled message
//

import SwiftUI

struct FixPainBodyRegion {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let description: String
}

struct FixPainSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onRegionSelected: (String) -> Void
    
    private let bodyRegions = [
        FixPainBodyRegion(name: "Neck", icon: "figure.walk", color: .red, description: "Tension, stiffness, headaches"),
        FixPainBodyRegion(name: "Shoulders", icon: "figure.arms.open", color: .orange, description: "Impingement, tightness, pain"),
        FixPainBodyRegion(name: "Elbows", icon: "figure.flexibility", color: .yellow, description: "Tennis elbow, golfer's elbow"),
        FixPainBodyRegion(name: "Wrists", icon: "hand.raised", color: .green, description: "Carpal tunnel, strain"),
        FixPainBodyRegion(name: "Upper Back", icon: "figure.walk", color: .blue, description: "Thoracic spine, posture"),
        FixPainBodyRegion(name: "Lower Back", icon: "figure.stand", color: .indigo, description: "Lumbar spine, sciatica"),
        FixPainBodyRegion(name: "Hips", icon: "figure.walk", color: .purple, description: "Hip flexors, glutes, SI joint"),
        FixPainBodyRegion(name: "Knees", icon: "figure.walk", color: .pink, description: "Patella, meniscus, ligaments"),
        FixPainBodyRegion(name: "Ankles", icon: "figure.walk", color: .brown, description: "Sprains, Achilles, mobility"),
        FixPainBodyRegion(name: "Feet", icon: "figure.walk", color: .gray, description: "Plantar fasciitis, arches")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Fix Pain")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Get personalized advice for your discomfort")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                            
                            Text("Select the area where you're experiencing discomfort")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Our AI physio will provide natural movement-based solutions and create a personalized recovery plan.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Body Region Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Problem Area")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ForEach(bodyRegions, id: \.id) { region in
                                RegionCard(region: region) {
                                    selectRegion(region)
                                }
                            }
                        }
                    }
                    
                    // Disclaimer
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            
                            Text("Important")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        
                        Text("This is not a substitute for professional medical advice. For severe or persistent pain, please consult a healthcare provider.")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(12)
                    .background(.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func selectRegion(_ region: FixPainBodyRegion) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
        onRegionSelected(region.name)
        
        DebugLog.info("Selected pain region: \(region.name)")
        TelemetryService.shared.track("fix_pain_region_selected", properties: ["region": region.name])
    }
}

// MARK: - Region Card
struct RegionCard: View {
    let region: FixPainBodyRegion
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(region.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: region.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(region.color)
                }
                
                // Content
                VStack(spacing: 4) {
                    Text(region.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(region.description)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(region.color.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Preview
#Preview {
    FixPainSheet { region in
        print("Selected region: \(region)")
    }
}
