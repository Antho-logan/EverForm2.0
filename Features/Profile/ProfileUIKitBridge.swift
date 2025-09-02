import SwiftUI

#if os(iOS)
import UIKit

/// If a UIKit Profile view controller exists, we present it safely.
/// Otherwise we fall back to a simple SwiftUI profile screen.
/// This version avoids any unsafe `perform(_:)` calls that can crash.
@objc protocol EFProfileViewControllerProtocol {
    @objc init(store: Any?)
}

// MARK: - Uses ProfileFallbackView from AccountScreens.swift

struct ProfileUIKitScreen: UIViewControllerRepresentable {

    // Try to instantiate a store object if one exists in the app
    private func makeStoreInstance(module: String) -> AnyObject? {
        let storeNames = [
            "\(module).ProfileStore",
            "ProfileStore",
            "\(module).UIKitProfileStore",
            "UIKitProfileStore"
        ]
        for name in storeNames {
            if let StoreType = NSClassFromString(name) as? NSObject.Type {
                #if DEBUG
                print("Profile bridge: using store '\(name)'")
                #endif
                return StoreType.init()
            }
        }
        return nil
    }

    // Try to instantiate a UIKit VC by several known class names
    private func makeUIKitProfileVC(module: String, store: AnyObject?) -> UIViewController? {
        let vcNames = [
            "\(module).ProfileViewController",
            "ProfileViewController",
            "\(module).UIKitProfileViewController",
            "UIKitProfileViewController"
        ]

        for vcName in vcNames {
            guard let anyType = NSClassFromString(vcName) else { continue }

            // 1) If it conforms to our protocol, call init(store:)
            if let ProtoType = anyType as? (UIViewController & EFProfileViewControllerProtocol).Type {
                #if DEBUG
                print("Profile bridge: using '\(vcName)' with init(store:)")
                #endif
                let vc = ProtoType.init(store: store)
                return vc
            }

            // 2) Else, if it is at least a UIViewController, try default init()
            if let VCType = anyType as? UIViewController.Type {
                #if DEBUG
                print("Profile bridge: using '\(vcName)' with default init()")
                #endif
                let vc = VCType.init()
                return vc
            }
        }

        return nil
    }

    // MARK: UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> UIViewController {
        let module = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""

        // Try UIKit path first (safe & crash-proof)
        let store = makeStoreInstance(module: module)
        if let profileVC = makeUIKitProfileVC(module: module, store: store) {
            let nav = UINavigationController(rootViewController: profileVC)
            nav.modalPresentationStyle = .formSheet
            return nav
        }

        // Fallback: SwiftUI profile
        let fallback = UIHostingController(rootView: NavigationStack { EFProfileView() })
        fallback.modalPresentationStyle = .formSheet
        return fallback
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

#else
// Non-iOS platforms: always show the SwiftUI fallback
struct ProfileUIKitScreen: View {
    var body: some View {
        NavigationStack { ProfileFallbackView() }
    }
}
#endif
