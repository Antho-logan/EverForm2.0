//
//  QuickActionsRow.swift
//  EverForm
//
//  Quick actions row with uniform tiles and reorder functionality
//

import SwiftUI

// A simple, in-content, single-row Quick Actions section (no floating dock).
struct QuickActionsRow: View {
    var onAddWater: () -> Void
    var onBreathwork: () -> Void
    var onFixPain: () -> Void
    var onAskCoach: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Actions")
                    .font(.headline)
                Spacer()
                Button("Reorder") {
                    // leave hook for future reordering UI
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                actionTile(title: "Add Water", system: "drop.fill") { onAddWater() }
                actionTile(title: "Breathwork", system: "wind") { onBreathwork() }
                actionTile(title: "Fix Pain", system: "cross.case.fill") { onFixPain() }
                actionTile(title: "Ask Coach", system: "brain.head.profile") { onAskCoach() }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func actionTile(title: String, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: system)
                    .font(.title3.weight(.semibold))
                Text(title)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 72)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color(.tertiarySystemFill)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}
