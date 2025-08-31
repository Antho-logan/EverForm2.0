import SwiftUI

struct SideMenuDrawer: View {
    @Environment(AppMenuCoordinator.self) private var menu
    @Environment(NutritionStore.self) private var nutritionStore
    @Environment(WorkoutStore.self) private var workoutStore

    private let width: CGFloat = UIScreen.main.bounds.width * 0.82

    var body: some View {
        ZStack(alignment: .leading) {
            // Dim overlay
            Color.black.opacity(menu.isOpen ? 0.25 : 0)
                .ignoresSafeArea()
                .onTapGesture { menu.close() }

            // Drawer panel
            VStack(alignment: .leading, spacing: 0) {
                header
                Divider()
                ScrollView { content.padding(.vertical, 12).padding(.horizontal, 12) }
                Spacer(minLength: 0)
            }
            .frame(width: width)
            .background(.thinMaterial)
            .offset(x: menu.isOpen ? 0 : -width)
            .shadow(radius: 10)
            .animation(.snappy, value: menu.isOpen)
        }
        .allowsHitTesting(menu.isOpen)
        .zIndex(menu.isOpen ? 2 : 0)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.head.profile").imageScale(.large)
            Text("EverForm").font(.title3.weight(.semibold))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader("Quick")
            MenuRow(icon: "list.bullet.rectangle", title: "View Today's Diary") { menu.openDiary() }
            MenuRow(icon: "plus.circle", title: "Quick Add Meal") { menu.openQuickAddMeal() }
            MenuRow(icon: "barcode.viewfinder", title: "Scan Food") { menu.goScan() }
            if workoutStore.hasActiveWorkout {
                MenuRow(icon: "repeat.circle", title: "Resume Workout") { menu.openTodayPlan() }
            } else {
                MenuRow(icon: "dumbbell", title: "Start Workout") { menu.openTodayPlan() }
            }
            MenuRow(icon: "figure.walk.motion", title: "Mobility Routines") { menu.openMobilityRoutine() }
            MenuRow(icon: "moon.stars", title: "Sleep Routine") { menu.openSleepRoutine() }

            SectionHeader("Insights")
            MenuRow(icon: "chart.line.uptrend.xyaxis", title: "Nutrition Trends") { menu.openNutritionTrends() }
            MenuRow(icon: "clock.badge.checkmark", title: "Workout History") { menu.openWorkoutHistory() }

            SectionHeader("Profile & Settings")
            MenuRow(icon: "person.crop.circle", title: "Edit Profile") { menu.openEditProfile() }
            MenuRow(icon: "brain", title: "Ask the Coach") { menu.goCoach() }
            MenuRow(icon: "gear", title: "Settings") { menu.openSettings() }
        }
    }
}

private struct MenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).frame(width: 22)
                Text(title).font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background.secondary)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct SectionHeader: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.top, 12)
    }
}
