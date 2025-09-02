import SwiftUI

/// A small rounded triangular arrow used to visually link a floating popover to its anchor.
struct PopoverArrow: Shape {
    enum Edge { case top, bottom, leading, trailing }
    var edge: Edge = .top
    let width: CGFloat = 16
    let height: CGFloat = 8
    let corner: CGFloat = 3

    func path(in rect: CGRect) -> Path {
        var path = Path()
        switch edge {
        case .top:
            let midX = rect.midX
            path.move(to: CGPoint(x: midX - width/2, y: rect.minY + height))
            path.addQuadCurve(to: CGPoint(x: midX, y: rect.minY),
                              control: CGPoint(x: midX - width/2 + corner, y: rect.minY + height/4))
            path.addQuadCurve(to: CGPoint(x: midX + width/2, y: rect.minY + height),
                              control: CGPoint(x: midX + width/2 - corner, y: rect.minY + height/4))
        case .bottom:
            let midX = rect.midX
            path.move(to: CGPoint(x: midX - width/2, y: rect.maxY - height))
            path.addQuadCurve(to: CGPoint(x: midX, y: rect.maxY),
                              control: CGPoint(x: midX - width/2 + corner, y: rect.maxY - height/4))
            path.addQuadCurve(to: CGPoint(x: midX + width/2, y: rect.maxY - height),
                              control: CGPoint(x: midX + width/2 - corner, y: rect.maxY - height/4))
        case .leading:
            let midY = rect.midY
            path.move(to: CGPoint(x: rect.minX + height, y: midY - width/2))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: midY),
                              control: CGPoint(x: rect.minX + height/4, y: midY - width/2 + corner))
            path.addQuadCurve(to: CGPoint(x: rect.minX + height, y: midY + width/2),
                              control: CGPoint(x: rect.minX + height/4, y: midY + width/2 - corner))
        case .trailing:
            let midY = rect.midY
            path.move(to: CGPoint(x: rect.maxX - height, y: midY - width/2))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: midY),
                              control: CGPoint(x: rect.maxX - height/4, y: midY - width/2 + corner))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - height, y: midY + width/2),
                              control: CGPoint(x: rect.maxX - height/4, y: midY + width/2 - corner))
        }
        return path
    }
}
