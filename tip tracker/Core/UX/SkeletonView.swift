import SwiftUI

/// A simple skeleton loading view with pulsing animation
struct SkeletonView: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var isAnimating = false
    
    init(width: CGFloat? = nil, height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: height)
            .opacity(isAnimating ? 0.5 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

/// Skeleton variants for common UI patterns
extension SkeletonView {
    /// Small skeleton for list items
    static var listItem: some View {
        VStack(alignment: .leading, spacing: 8) {
            SkeletonView(width: 120, height: 16)
            SkeletonView(width: 200, height: 12)
        }
    }
    
    /// Card skeleton for dashboard tiles
    static var card: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkeletonView(width: 80, height: 14)
            SkeletonView(width: 140, height: 20)
            SkeletonView(width: 100, height: 12)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    /// Text line skeleton
    static func textLine(width: CGFloat = 150) -> some View {
        SkeletonView(width: width, height: 16, cornerRadius: 4)
    }
}

#Preview {
    VStack(spacing: 20) {
        SkeletonView.listItem
        SkeletonView.card
        SkeletonView.textLine()
        SkeletonView(width: 200, height: 40)
    }
    .padding()
}

