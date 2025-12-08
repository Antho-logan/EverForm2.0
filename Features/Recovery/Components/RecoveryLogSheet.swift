import SwiftUI

struct RecoveryLogSheet: View {
    @Binding var selectedTypes: Set<RecoveryType>
    @Binding var note: String
    var onSave: (Set<RecoveryType>, String) -> Void
    var onCancel: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    @FocusState private var isNoteFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chips / Selected Items
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(selectedTypes).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { type in
                            Text(type.rawValue)
                                .font(.app(.caption))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DesignSystem.Colors.accent.opacity(0.1))
                                .foregroundStyle(DesignSystem.Colors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                .frame(height: 50)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Note Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.app(.bodySecondary))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                            
                            ZStack(alignment: .topLeading) {
                                if note.isEmpty {
                                    Text("How did it go? (optional)")
                                        .font(.app(.body))
                                        .foregroundStyle(DesignSystem.Colors.textSecondary.opacity(0.7))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                }
                                
                                TextEditor(text: $note)
                                    .font(.app(.body))
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .frame(minHeight: 120)
                                    .focused($isNoteFocused)
                            }
                            .background(DesignSystem.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
                            )
                            
                            Text("Logging this will add it to your daily recovery stats.")
                                .font(.app(.caption))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .font(.app(.button))
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    
                    Button {
                        onSave(selectedTypes, note)
                    } label: {
                        Text("Save log")
                            .font(.app(.button))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                selectedTypes.isEmpty
                                ? Color.gray.opacity(0.3)
                                : DesignSystem.Colors.accent
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .disabled(selectedTypes.isEmpty)
                }
                .padding(20)
                .background(DesignSystem.Colors.background)
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("Log Recovery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave(selectedTypes, note) }
                        .disabled(selectedTypes.isEmpty)
                }
            }
        }
    }
}

// Helper for Type Toggle logic is now in the dashboard grid
