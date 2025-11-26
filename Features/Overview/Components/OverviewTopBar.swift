
import SwiftUI

struct OverviewTopBar: View {
    let onProfileTap: () -> Void
    let onNotificationsTap: () -> Void
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack {
            Button(action: onProfileTap) {
                Circle()
                    .fill(themeManager.backgroundSecondary)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("AL")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(themeManager.textPrimary)
                    )
            }
            
            Spacer()
            
            Button(action: onNotificationsTap) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(themeManager.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(themeManager.backgroundSecondary)
                    .clipShape(Circle())
            }
        }
    }
}



