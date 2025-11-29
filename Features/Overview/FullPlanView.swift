import SwiftUI

struct FullPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    private let planItems = PlanItem.mock
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Today's Plan", showBack: true)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(planItems) { item in
                            OverviewPlanCard(item: item)
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

