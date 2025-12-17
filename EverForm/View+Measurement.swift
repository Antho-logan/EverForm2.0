import SwiftUI

private struct ViewHeightPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

extension View {
  /// Observes the view's rendered height.
  func onHeightChange(_ onChange: @escaping (CGFloat) -> Void) -> some View {
    background(
      GeometryReader { proxy in
        Color.clear.preference(key: ViewHeightPreferenceKey.self, value: proxy.size.height)
      }
    )
    .onPreferenceChange(ViewHeightPreferenceKey.self, perform: onChange)
  }
}

