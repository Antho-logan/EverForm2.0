//
//  BreathworkSessionSummaryView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkSessionSummaryView: View {
    let pattern: BreathworkPattern
    let totalMinutes: Int
    let roundsCompleted: Int
    
    @Environment(BreathworkStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var note: String = ""
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Success Icon
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.accent.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
                .scaleEffect(1.0)
                .transition(.scale)
                
                VStack(spacing: 8) {
                    Text("Session Complete")
                        .font(DesignSystem.Typography.displaySmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text(pattern.displayName)
                        .font(DesignSystem.Typography.titleMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                
                // Stats Grid
                HStack(spacing: 32) {
                    StatSummaryItem(value: "\(totalMinutes) min", label: "Duration")
                    StatSummaryItem(value: "\(roundsCompleted)", label: "Rounds")
                    StatSummaryItem(value: "+5", label: "Streak")
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 32)
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a Note")
                        .font(DesignSystem.Typography.headline())
                    
                    TextField("How did you feel?", text: $note)
                        .padding()
                        .background(DesignSystem.Colors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Button {
                    saveAndClose()
                } label: {
                    Text("Save Session")
                        .font(DesignSystem.Typography.buttonLarge())
                        .foregroundStyle(DesignSystem.Colors.buttonForegroundDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(DesignSystem.Colors.buttonBackgroundDark)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func saveAndClose() {
        let log = BreathworkSessionLog(
            id: UUID(),
            date: Date(),
            templateId: nil, // Could be linked if started from template
            patternName: pattern.displayName,
            durationMinutes: totalMinutes,
            roundsCompleted: roundsCompleted,
            longestHoldSeconds: 0, // Placeholder
            notes: note.isEmpty ? nil : note
        )
        
        store.logSession(log)
        
        // Dismiss the summary (sheet)
        dismiss()
        
        // We also need to dismiss the underlying LiveSessionView. 
        // In the HomeView, showingLiveSession is bound. 
        // Since this summary is presented FROM LiveSessionView, dismissing this 
        // just reveals LiveSessionView again unless we handle the flow differently.
        // Best practice: LiveSessionView handles the "End" state by showing this view, 
        // and when this view dismisses, it tells LiveSessionView to dismiss itself.
        // For simplicity here, we might need a shared binding or a notification.
        // In LiveBreathworkSessionView, showingSummary is a local sheet.
        // When this dismisses, LiveBreathworkSessionView is still there.
        // We should pass a closure or binding to dismiss parent.
        
        NotificationCenter.default.post(name: .closeBreathworkSession, object: nil)
    }
}

struct StatSummaryItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(DesignSystem.Typography.title3())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            Text(label)
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
    }
}

extension Notification.Name {
    static let closeBreathworkSession = Notification.Name("closeBreathworkSession")
}

