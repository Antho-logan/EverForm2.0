import SwiftUI

struct ProfileHero: View {
    let profile: UserProfile
    let targets: UserTargets
    var onEditTapped: () -> Void

    private var initials: String {
        let trimmed = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmed.split(separator: " ")
        if components.count >= 2 {
            return components.prefix(2).compactMap { $0.first }.map { String($0).uppercased() }.joined()
        } else if let first = trimmed.first {
            return String(first).uppercased()
        } else {
            return "EF"
        }
    }

    var body: some View {
        EFCard(style: .gradient(LinearGradient(colors: [.indigo.opacity(0.85), .blue.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 16) {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Text(initials)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile.name.isEmpty ? "Set up your profile" : profile.name)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(profile.email.isEmpty ? "your.email@example.com" : profile.email)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer()

                    Button(action: onEditTapped) {
                        Label("Edit", systemImage: "pencil")
                            .font(.subheadline.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                }

                HStack(spacing: 12) {
                    ProfileHeroStat(icon: "figure.walk", value: targets.steps.formatted(.number.notation(.compactName)), label: "Steps Goal")
                    ProfileHeroStat(icon: "moon.stars.fill", value: String(format: "%.0f h", targets.sleepHours), label: "Sleep")
                    ProfileHeroStat(icon: "drop.fill", value: waterDisplay, label: "Hydration")
                }
            }
            .foregroundStyle(.white)
        }
    }
    
    private var waterDisplay: String {
        if profile.unitSystem == .metric {
            return "\(targets.hydrationMl) ml"
        } else {
            let oz = Double(targets.hydrationMl) * 0.033814
            return String(format: "%.0f oz", oz)
        }
    }
}

private struct ProfileHeroStat: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.9))
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
