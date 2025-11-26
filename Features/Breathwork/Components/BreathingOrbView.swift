//
//  BreathingOrbView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathingOrbView: View {
    let phase: BreathPhaseType
    let animationDuration: Double
    
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6
    @State private var innerRotation: Double = 0
    @State private var outerRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Outer Glow (Static/Ambient)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [phaseColor.opacity(0.3), phaseColor.opacity(0.0)],
                        center: .center,
                        startRadius: 100,
                        endRadius: 200
                    )
                )
                .scaleEffect(scale * 1.2)
                .opacity(opacity * 0.5)
            
            // Outer Ring
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [phaseColor.opacity(0.1), phaseColor.opacity(0.5), phaseColor.opacity(0.1)],
                        center: .center
                    ),
                    lineWidth: 20
                )
                .rotationEffect(.degrees(outerRotation))
                .frame(width: 280, height: 280)
                .scaleEffect(scale)
            
            // Middle Layer
            Circle()
                .fill(
                    LinearGradient(
                        colors: [phaseColor.opacity(0.6), phaseColor.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 220, height: 220)
                .scaleEffect(scale)
                .blur(radius: 20)
            
            // Core
            Circle()
                .fill(phaseColor)
                .frame(width: 160, height: 160)
                .scaleEffect(scale)
                .shadow(color: phaseColor.opacity(0.5), radius: 30)
            
            // Inner texture
            Circle()
                .fill(
                    AngularGradient(
                        colors: [.white.opacity(0.4), .clear, .white.opacity(0.1)],
                        center: .center
                    )
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(innerRotation))
                .scaleEffect(scale)
                .blendMode(.overlay)
        }
        .onAppear {
            startAmbientAnimation()
        }
        .onChange(of: phase) { _, newPhase in
            animateForPhase(newPhase)
        }
    }
    
    private var phaseColor: Color {
        switch phase {
        case .inhale: return Color.cyan
        case .hold: return Color.purple
        case .exhale: return Color.blue
        case .retention: return Color.indigo
        }
    }
    
    private func startAmbientAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            innerRotation = 360
        }
        withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
            outerRotation = -360
        }
    }
    
    private func animateForPhase(_ phase: BreathPhaseType) {
        switch phase {
        case .inhale:
            withAnimation(.easeInOut(duration: animationDuration)) {
                scale = 1.5
                opacity = 1.0
            }
        case .hold, .retention:
            withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                opacity = 0.8
            }
        case .exhale:
            withAnimation(.easeInOut(duration: animationDuration)) {
                scale = 1.0
                opacity = 0.6
            }
        }
    }
}

