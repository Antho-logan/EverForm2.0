import SwiftUI

struct DrawerMenu: View {
    let onClose: () -> Void
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(systemName: "brain.head.profile").imageScale(.large)
                Text("EverForm").font(.title3.weight(.semibold))
                Spacer()
                Button("Close", action: onClose)
                    .font(.callout)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader("Navigation")
                    MenuRow(icon: "house", title: "Overview") { 
                        router.go(.overview)
                    }
                    MenuRow(icon: "brain.head.profile", title: "Coach") { 
                        router.go(.coach)
                    }
                    MenuRow(icon: "camera.viewfinder", title: "Scan") { 
                        router.go(.scan)
                    }
                    
                    SectionHeader("Quick Actions")
                    MenuRow(icon: "plus.circle", title: "Log Meal") { router.open(.logMeal) }
                    MenuRow(icon: "dumbbell", title: "Start Workout") { router.open(.startWorkout) }
                    MenuRow(icon: "figure.walk.motion", title: "Mobility") { router.open(.mobility) }
                    MenuRow(icon: "moon.stars", title: "Sleep") { router.open(.sleep) }
                    
                    SectionHeader("Data & History")
                    MenuRow(icon: "chart.line.uptrend.xyaxis", title: "Nutrition Trends") { router.open(.nutritionTrends) }
                    MenuRow(icon: "list.bullet.clipboard", title: "Workout History") { router.open(.workoutHistory) }
                    
                    SectionHeader("Settings")
                    MenuRow(icon: "person.circle", title: "Edit Profile") { router.open(.editProfile) }
                    MenuRow(icon: "gear", title: "Settings") { router.open(.settings) }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
            }
            
            Spacer(minLength: 0)
        }
        .background(.thinMaterial)
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



