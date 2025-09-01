//
//  CenteredLayout.swift
//  EverForm
//
//  Centering helper for consistent content width and spacing
//

import SwiftUI

public struct CenteredContent<Content: View>: View {
    let maxWidth: CGFloat
    let horizontalPadding: CGFloat
    @ViewBuilder var content: Content

    public init(maxWidth: CGFloat = 640,
                horizontalPadding: CGFloat = 20,
                @ViewBuilder content: () -> Content) {
        self.maxWidth = maxWidth
        self.horizontalPadding = horizontalPadding
        self.content = content()
    }

    public var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                content
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity)
                    .contentMargins(.horizontal, horizontalPadding)
            } else {
                content
                    .frame(maxWidth: maxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
            }
        }
    }
}
