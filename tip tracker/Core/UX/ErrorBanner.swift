import SwiftUI
import OSLog

/// A top-floating error banner with auto-dismiss and optional retry
struct ErrorBanner: View {
    let message: String
    let retry: (() -> Void)?
    let onDismiss: () -> Void
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 16, weight: .medium))
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Spacer()
            
            if let retry = retry {
                Button("Retry", action: retry)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .padding(.horizontal, 16)
        .offset(y: isVisible ? 0 : -100)
        .opacity(isVisible ? 1 : 0)
        .animation(
            reduceMotion ? .easeInOut(duration: 0.3) : UX.Anim.snappy,
            value: isVisible
        )
        .onAppear {
            withAnimation {
                isVisible = true
            }
            
            // Auto-dismiss after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                dismiss()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
        .accessibilityHint(retry != nil ? "Double tap to retry" : "Double tap to dismiss")
    }
    
    private func dismiss() {
        withAnimation {
            isVisible = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

/// Error banner manager for showing banners globally
@MainActor
class ErrorBannerManager: ObservableObject {
    static let shared = ErrorBannerManager()
    
    @Published var currentBanner: ErrorBannerData?
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EverForm", category: "ErrorBanner")
    
    private init() {}
    
    func show(message: String, retry: (() -> Void)? = nil) {
        logger.info("Showing error banner: \(message)")
        
        currentBanner = ErrorBannerData(
            id: UUID(),
            message: message,
            retry: retry
        )
    }
    
    func dismiss() {
        currentBanner = nil
    }
}

/// Data model for error banners
struct ErrorBannerData: Identifiable {
    let id: UUID
    let message: String
    let retry: (() -> Void)?
}

/// View that displays the current error banner
struct ErrorBannerView: View {
    @StateObject private var manager = ErrorBannerManager.shared
    
    var body: some View {
        if let banner = manager.currentBanner {
            ErrorBanner(
                message: banner.message,
                retry: banner.retry,
                onDismiss: { manager.dismiss() }
            )
            .zIndex(999)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

/// Convenience extension for UX namespace
extension UX {
    enum Banner {
        @MainActor
        static func show(message: String, retry: (() -> Void)? = nil) {
            ErrorBannerManager.shared.show(message: message, retry: retry)
        }
        
        @MainActor
        static func dismiss() {
            ErrorBannerManager.shared.dismiss()
        }
    }
}

#Preview {
    VStack {
        Button("Show Error") {
            UX.Banner.show(message: "Failed to export data. Please try again.", retry: {
                print("Retrying...")
            })
        }
        
        Spacer()
    }
    .overlay(alignment: .top) {
        ErrorBannerView()
    }
}

