import SwiftUI

struct ProfileSection<Content: View>: View {
    let title: String
    var subtitle: String?
    let content: () -> Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EFSectionHeader(title: title, subtitle: subtitle)
            EFCard {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
            }
        }
    }
}

