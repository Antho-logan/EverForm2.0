import SwiftUI

struct OverviewView: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Overview")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(EFTheme.text(scheme))
                    .frame(maxWidth: .infinity, alignment: .leading)

                // KPI grid (4 tiles)
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    KPICard(icon: "figure.walk", title: "8.4K", subtitle: "STEPS")
                    KPICard(icon: "drop.fill", title: "1850 / 2661", subtitle: "CALORIES")
                    KPICard(icon: "bed.double.fill", title: "7h 30m", subtitle: "SLEEP")
                    KPICard(icon: "drop", title: "0 ml", subtitle: "HYDRATION")
                }

                EFSectionHeader(title: "Today's Plan")

                // Plan 2x2
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    PlanCard(color: .green,  sf: "dumbbell.fill",   title: "Training",  subtitle: "Upper Body",    buttonTitle: "Start Workout")
                    PlanCard(color: .orange, sf: "fork.knife",      title: "Nutrition", subtitle: "2661 kcal target", buttonTitle: "Log Meal")
                    PlanCard(color: .blue,   sf: "moon.stars.fill", title: "Recovery",  subtitle: "Bedtime 22:30", buttonTitle: "Open")
                    PlanCard(color: .purple, sf: "figure.run",      title: "Mobility",  subtitle: "Hips & Shoulders • 8 min", buttonTitle: "Start")
                }

                EFSectionHeader(title: "Quick Actions")

                // Actions row (single row, same vibe)
                HStack(spacing: 16) {
                    QuickActionCard(icon: "drop.fill",     title: "Add Water", tint: .cyan)
                    QuickActionCard(icon: "wind",           title: "Breathwork", tint: .green)
                    QuickActionCard(icon: "cross.case.fill",title: "Fix Pain",  tint: .red)
                    QuickActionCard(icon: "brain.head.profile", title: "Ask Coach", tint: .blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(EFTheme.background(scheme).ignoresSafeArea())
    }
}

private struct KPICard: View {
    @Environment(\.colorScheme) private var scheme
    let icon: String, title: String, subtitle: String
    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.green)
                Text(title).font(.title3.weight(.semibold)).foregroundStyle(EFTheme.text(scheme))
                Text(subtitle).font(.caption).foregroundStyle(EFTheme.muted(scheme))
            }
        }
    }
}

private struct PlanCard: View {
    @Environment(\.colorScheme) private var scheme
    let color: Color, sf: String, title: String, subtitle: String, buttonTitle: String
    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: sf).foregroundStyle(color).font(.system(size: 18, weight: .bold))
                    Text(title).font(.headline).foregroundStyle(EFTheme.text(scheme))
                }
                Text(subtitle).font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                Button(buttonTitle) {}
                    .font(.subheadline.weight(.semibold))
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .background(color.opacity(0.15))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.4)))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundStyle(color)
            }
        }
    }
}

private struct QuickActionCard: View {
    @Environment(\.colorScheme) private var scheme
    let icon: String, title: String, tint: Color
    var body: some View {
        EFCard {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 18, weight: .bold)).foregroundStyle(tint)
                Text(title).font(.caption).foregroundStyle(EFTheme.text(scheme))
            }.frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}