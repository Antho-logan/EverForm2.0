import SwiftUI

/// Toolbar helpers for consistent back/dismiss actions
extension View {
    /// Adds a standard back button to the leading toolbar position
    func toolbarBackButton(action: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: action) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                }
                .accessibilityLabel("Back")
            }
        }
    }
    
    /// Adds a standard close button to the leading toolbar position
    func toolbarCloseButton(action: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close", action: action)
                    .accessibilityLabel("Close")
            }
        }
    }
    
    /// Adds a standard done button to the trailing toolbar position
    func toolbarDoneButton(action: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: action)
                    .fontWeight(.semibold)
                    .accessibilityLabel("Done")
            }
        }
    }
    
    /// Adds both close (leading) and done (trailing) buttons
    func toolbarCloseAndDone(onClose: @escaping () -> Void, onDone: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close", action: onClose)
                    .accessibilityLabel("Close")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done", action: onDone)
                    .fontWeight(.semibold)
                    .accessibilityLabel("Done")
            }
        }
    }
}

