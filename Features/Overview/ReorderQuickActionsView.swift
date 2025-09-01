//
//  ReorderQuickActionsView.swift
//  EverForm
//
//  Reorder quick actions with drag and drop
//

import SwiftUI

struct ReorderQuickActionsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("quickActionsOrder") private var quickActionsOrder: String = "water,breathwork,fixpain,coach"
    
    @State private var actions: [QuickActionItem] = []
    
    struct QuickActionItem: Identifiable, Codable {
        let id: String
        let icon: String
        let title: String
        let style: QuickActionTile.SemanticStyle
        
        static let defaultActions = [
            QuickActionItem(id: "water", icon: "drop.fill", title: "Add Water", style: .water),
            QuickActionItem(id: "breathwork", icon: "wind", title: "Breathwork", style: .success),
            QuickActionItem(id: "fixpain", icon: "cross.case", title: "Fix Pain", style: .danger),
            QuickActionItem(id: "coach", icon: "brain.head.profile", title: "Ask Coach", style: .info)
        ]
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        NavigationView {
            VStack(spacing: Theme.Spacing.lg) {
                // Instructions
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Reorder Quick Actions")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                    
                    Text("Drag to reorder your quick action tiles")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Reorderable list
                List {
                    ForEach(actions) { action in
                        HStack(spacing: Theme.Spacing.md) {
                            // Tile preview
                            ZStack {
                                Circle()
                                    .fill(action.style.color(for: colorScheme).opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: action.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(action.style.color(for: colorScheme))
                            }
                            
                            // Title
                            Text(action.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(palette.textPrimary)
                            
                            Spacer()
                            
                            // Drag handle
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        }
                        .padding(.vertical, Theme.Spacing.xs)
                        .listRowBackground(palette.surface)
                        .listRowSeparator(.hidden)
                    }
                    .onMove(perform: moveActions)
                }
                .listStyle(.plain)
                .environment(\.editMode, .constant(.active))
                
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveOrder()
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                            dismiss()
                        }
                    }
                    .foregroundStyle(palette.accent)
                }
            }
        }
        .onAppear {
            loadActions()
        }
    }
    
    private func loadActions() {
        let orderIds = quickActionsOrder.split(separator: ",").map(String.init)
        let defaultActions = QuickActionItem.defaultActions
        
        if orderIds.isEmpty {
            actions = defaultActions
        } else {
            var orderedActions: [QuickActionItem] = []
            let actionsDict = Dictionary(uniqueKeysWithValues: defaultActions.map { ($0.id, $0) })
            
            // Add actions in saved order
            for id in orderIds {
                if let action = actionsDict[id] {
                    orderedActions.append(action)
                }
            }
            
            // Add any missing actions
            for defaultAction in defaultActions {
                if !orderedActions.contains(where: { $0.id == defaultAction.id }) {
                    orderedActions.append(defaultAction)
                }
            }
            
            actions = orderedActions
        }
    }
    
    private func moveActions(from source: IndexSet, to destination: Int) {
        actions.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveOrder() {
        let orderString = actions.map { $0.id }.joined(separator: ",")
        quickActionsOrder = orderString
    }
}

#Preview {
    ReorderQuickActionsView()
}
