import SwiftUI

struct OverviewView: View {
    @Environment(DashboardViewModel.self) var viewModel: DashboardViewModel
    @Environment(ProfileStore.self) var profileStore: ProfileStore
    @EnvironmentObject var journalStore: JournalStore

    @State private var showBreathwork = false
    @State private var showFixPain = false

    private let outerPadding: CGFloat = 20
    private let sectionSpacing: CGFloat = 20
    private let gridSpacing: CGFloat = 16
    private let cardHeight: CGFloat = 162

    private var kpiColumns: [GridItem] {
        [GridItem(.flexible(), spacing: gridSpacing), GridItem(.flexible(), spacing: gridSpacing)]
    }
    private var planColumns: [GridItem] {
        [GridItem(.flexible(), spacing: gridSpacing), GridItem(.flexible(), spacing: gridSpacing)]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: sectionSpacing) {

                // Header
                HStack(spacing: 12) {
                    Button {
                        viewModel.profileTapped()
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    Text("Overview")
                        .font(.largeTitle.bold())
                    Spacer()
                    Button {
                        viewModel.moreTapped()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }

                // Mini dials row (keep as-is data wise)
                MiniDialsRow(
                    steps: viewModel.todaySteps,
                    calories: viewModel.todayCalories,
                    sleepHours: viewModel.todaySleepHours,
                    hydrationML: viewModel.todayHydrationGlasses * 250
                )

                // KPI grid (keep logic as-is, only layout)
                LazyVGrid(columns: kpiColumns, alignment: .leading, spacing: gridSpacing) {
                    KPITile(title: "STEPS", value: Self.formatK(viewModel.todaySteps), system: "figure.walk")
                        .frame(height: cardHeight)
                    KPITile(title: "CALORIES", value: Self.formatCalories(viewModel.todayCalories, profileStore.targets?.targetCalories), system: "flame.fill")
                        .frame(height: cardHeight)
                    KPITile(title: "SLEEP", value: Self.formatSleepMinutes(Int(viewModel.todaySleepHours * 60)), system: "bed.double.fill")
                        .frame(height: cardHeight)
                    KPITile(title: "HYDRATION", value: Self.formatHydration(viewModel.todayHydrationGlasses * 250), system: "drop.fill")
                        .frame(height: cardHeight)
                }

                // Today's Plan
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Plan")
                        .font(.headline)
                    LazyVGrid(columns: planColumns, alignment: .leading, spacing: gridSpacing) {
                        PlanCard(
                            title: "Training",
                            subtitle: "Upper Body",
                            system: "dumbbell.fill",
                            actionTitle: "Start Workout",
                            actionStyle: .tintGreen
                        ) {
                            // navigate to TrainingView
                            viewModel.presentTraining = true
                        }
                        .frame(height: cardHeight)

                        PlanCard(
                            title: "Nutrition",
                            subtitle: "\(profileStore.targets?.targetCalories ?? 2400) kcal target",
                            system: "fork.knife",
                            actionTitle: "Log Meal",
                            actionStyle: .tintOrange
                        ) {
                            viewModel.presentNutrition = true
                        }
                        .frame(height: cardHeight)

                        PlanCard(
                            title: "Recovery",
                            subtitle: "Bedtime \(viewModel.recommendedBedtimeText)",
                            system: "moon.fill",
                            actionTitle: "Open",
                            actionStyle: .tintBlue
                        ) {
                            viewModel.presentRecovery = true
                        }
                        .frame(height: cardHeight)

                        PlanCard(
                            title: "Mobility",
                            subtitle: "Hips & Shoulders · 8 min",
                            system: "figure.run",
                            actionTitle: "Start",
                            actionStyle: .tintPurple
                        ) {
                            viewModel.presentMobility = true
                        }
                        .frame(height: cardHeight)
                    }
                }

                // In-content Quick Actions row (no floating dock)
                QuickActionsRow(
                    onAddWater: {
                        viewModel.addWater(250)
                    },
                    onBreathwork: {
                        showBreathwork = true
                    },
                    onFixPain: {
                        showFixPain = true
                    },
                    onAskCoach: {
                        // switch to Coach tab via RootTabView notification
                        NotificationCenter.default.post(name: .switchToCoachTab, object: nil)
                    }
                )
            }
            .padding(.horizontal, outerPadding)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showBreathwork) {
            NavigationStack {
                BreathworkView()
            }
            .presentationDetents([.large]) // full page style sheet
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showFixPain) {
            NavigationStack {
                FixPainView()
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        // MARK: Navigation to feature pages from Today's Plan
        .sheet(isPresented: $viewModel.presentTraining) {
            NavigationStack { TrainingView().environmentObject(journalStore) }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.presentNutrition) {
            NavigationStack { NutritionView().environmentObject(journalStore) }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.presentRecovery) {
            NavigationStack { RecoveryView().environmentObject(journalStore) }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.presentMobility) {
            NavigationStack { MobilityView().environmentObject(journalStore) }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Formatting helpers (unchanged semantics)
    static func formatK(_ n: Int) -> String {
        if n >= 1000 { return String(format: "%.1fK", Double(n)/1000.0) }
        return "\(n)"
    }
    static func formatCalories(_ current: Int, _ target: Int?) -> String {
        if let t = target { return "\(current) / \(t)" }
        return "\(current)"
    }
    static func formatSleepMinutes(_ minutes: Int) -> String {
        let h = minutes / 60, m = minutes % 60
        return "\(h)h \(m)m"
    }
    static func formatHydration(_ ml: Int) -> String {
        "\(ml) ml"
    }
}

private struct MiniDialsRow: View {
    let steps: Int
    let calories: Int
    let sleepHours: Double
    let hydrationML: Int
    var body: some View {
        // keep visuals lightweight; logic unchanged
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            mini("figure.walk", label: Self.fmtK(steps))
            mini("flame.fill", label: Self.fmtK(calories))
            mini("bed.double.fill", label: Self.fmtTime(sleepHours))
            mini("drop.fill", label: "\(hydrationML) ml")
        }
    }
    func mini(_ system: String, label: String) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().strokeBorder(.secondary.opacity(0.25), lineWidth: 2)
                Image(systemName: system).font(.subheadline)
            }.frame(width: 44, height: 44)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
    static func fmtK(_ n: Int) -> String {
        n >= 1000 ? String(format: "%.1fK", Double(n)/1000.0) : "\(n)"
    }
    static func fmtTime(_ h: Double) -> String {
        let mins = Int(h * 60), H = mins/60, M = mins%60
        return "\(H)h \(M)m"
    }
}



private enum PlanActionStyle { case tintGreen, tintOrange, tintBlue, tintPurple }

private struct PlanCard: View {
    let title: String
    let subtitle: String
    let system: String
    let actionTitle: String
    let actionStyle: PlanActionStyle
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: system).font(.headline)
                Text(title).font(.title3.weight(.semibold))
                Spacer()
            }
            Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            Spacer(minLength: 8)
            Button(actionTitle, action: action)
                .buttonStyle(PillStyle(style: actionStyle))
                .accessibilityLabel(Text("\(actionTitle) for \(title)"))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.secondarySystemBackground)))
    }
}

private struct PillStyle: ButtonStyle {
    let style: PlanActionStyle
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule().fill(tint.opacity(configuration.isPressed ? 0.75 : 1.0))
            )
            .foregroundStyle(.white)
    }
    private var tint: Color {
        switch style {
        case .tintGreen:  return .green
        case .tintOrange: return .orange
        case .tintBlue:   return .blue
        case .tintPurple: return .purple
        }
    }
}
