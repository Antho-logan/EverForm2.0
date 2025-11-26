import SwiftUI

public struct EFScreenContainer<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            DesignSystem.Colors.background
                .ignoresSafeArea()

            content
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
