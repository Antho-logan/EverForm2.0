import SwiftUI
import Combine

public enum EFAppearanceChoice: String, CaseIterable, Identifiable {
    case system, light, dark
    public var id: String { rawValue }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

final class AppAppearanceStore: ObservableObject {
    private let key = "ef.appearance.choice"
    @Published var choice: EFAppearanceChoice {
        didSet { UserDefaults.standard.set(choice.rawValue, forKey: key) }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: key),
           let c = EFAppearanceChoice(rawValue: raw) {
            self.choice = c
        } else {
            self.choice = .system
        }
    }
}
