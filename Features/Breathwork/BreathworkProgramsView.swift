//
//  BreathworkProgramsView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkProgramsView: View {
    @Environment(BreathworkStore.self) private var store
    @State private var selectedProgram: BreathworkProgram?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Active Program Hero
                if let activeProgram = store.activeProgram() {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Active Program")
                            .font(DesignSystem.Typography.sectionHeader())
                            .padding(.horizontal, 20)
                        
                        Button {
                            selectedProgram = activeProgram
                        } label: {
                            ActiveProgramHero(program: activeProgram)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // All Programs
                VStack(alignment: .leading, spacing: 16) {
                    Text("Browse Programs")
                        .font(DesignSystem.Typography.sectionHeader())
                        .padding(.horizontal, 20)
                    
                    ForEach(store.programs) { program in
                        Button {
                            selectedProgram = program
                        } label: {
                            BreathworkProgramCard(program: program, progress: 0.2) // Mock progress
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 20)
        }
        .sheet(item: $selectedProgram) { program in
            ProgramDetailView(program: program)
        }
    }
}

struct ActiveProgramHero: View {
    let program: BreathworkProgram
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [DesignSystem.Colors.neutral800, DesignSystem.Colors.neutral900],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CONTINUE DAY 5")
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.Colors.accent.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Text(program.name)
                        .font(DesignSystem.Typography.titleMedium())
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    
                    Text("Next: Box Breathing • 10 min")
                        .font(DesignSystem.Typography.bodySmall())
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.1), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: 0.23)
                        .stroke(DesignSystem.Colors.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text("23%")
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(.white)
                }
                .frame(width: 50, height: 50)
            }
            .padding(20)
        }
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, y: 4)
    }
}

