import SwiftUI

// Temporary stub to unblock builds & SweepPad run. We'll reintroduce the full form later.
public struct AdvancedProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ProfileStore.self) private var profileStore

    // Keep a default initializer to satisfy call sites that use no parameters
    public init() {}

    // Keep a binding initializer to satisfy call sites that pass a profile binding
    // We intentionally don't use the binding in the stub to avoid type-check blowups.
    public init(profile: Binding<ProfileAdvanced>) {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.text.rectangle")
                    .font(.system(size: 48, weight: .semibold))

                Text("Advanced Profile")
                    .font(.title2).bold()

                Text("Temporary placeholder. The detailed form will return in smaller, type-safe sections.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 12) {
                    Text("Current Status: \(profileStore.advanced.bloodType.rawValue) blood type, \(profileStore.advanced.chronotype.rawValue) chronotype")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button("Reset Profile") {
                        Task { @MainActor in
                            profileStore.resetAdvancedProfile()
                        }
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                Button("Close") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .sensoryFeedback(.selection, trigger: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            .navigationTitle("Advanced Profile")
        }
    }
}

#Preview {
    AdvancedProfileView()
}