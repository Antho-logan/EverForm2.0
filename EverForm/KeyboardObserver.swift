import Combine
import SwiftUI
import UIKit

/// Lightweight keyboard state for layout decisions (e.g., hide custom tab bar while typing).
@MainActor
final class KeyboardObserver: ObservableObject {
  @Published private(set) var height: CGFloat = 0
  @Published private(set) var isVisible: Bool = false
  @Published private(set) var animationDuration: Double = 0.25
  @Published private(set) var animationCurve: UIView.AnimationCurve = .easeInOut

  private var cancellables: Set<AnyCancellable> = []

  init(notificationCenter: NotificationCenter = .default) {
    let willChange = notificationCenter.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
    let willHide = notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)

    Publishers.Merge(willChange, willHide)
      .receive(on: RunLoop.main)
      .sink { [weak self] notification in
        self?.handle(notification)
      }
      .store(in: &cancellables)
  }

  var animation: SwiftUI.Animation {
    switch animationCurve {
    case .easeInOut:
      return .easeInOut(duration: animationDuration)
    case .easeIn:
      return .easeIn(duration: animationDuration)
    case .easeOut:
      return .easeOut(duration: animationDuration)
    case .linear:
      return .linear(duration: animationDuration)
    @unknown default:
      return .easeInOut(duration: animationDuration)
    }
  }

  private func handle(_ notification: Notification) {
    let userInfo = notification.userInfo ?? [:]

    animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
    if let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int,
      let curve = UIView.AnimationCurve(rawValue: curveRaw)
    {
      animationCurve = curve
    } else {
      animationCurve = .easeInOut
    }

    guard let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
      set(height: 0)
      return
    }

    // Keyboard frames are in screen coordinates. Compute overlap with the key window.
    let windowFrame = Self.keyWindowFrameInScreenCoordinates() ?? UIScreen.main.bounds
    let overlap = max(0, windowFrame.maxY - endFrame.minY)
    set(height: overlap)
  }

  private func set(height: CGFloat) {
    let clamped = max(0, height)
    self.height = clamped
    self.isVisible = clamped > 0
  }

  private static func keyWindowFrameInScreenCoordinates() -> CGRect? {
    guard
      let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene })
        as? UIWindowScene,
      let window = windowScene.windows.first(where: { $0.isKeyWindow })
    else {
      return nil
    }
    return window.convert(window.bounds, to: nil)
  }
}

