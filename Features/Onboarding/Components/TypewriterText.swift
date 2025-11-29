import SwiftUI

struct TypewriterText: View {
    let text: String
    let font: Font
    var delay: TimeInterval = 0.04
    var startDelay: TimeInterval = 0.5
    var onComplete: (() -> Void)?
    
    @State private var displayedText: String = ""
    @State private var isTyping = false
    
    var body: some View {
        Text(displayedText)
            .font(font)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
            .onAppear {
                startTyping()
            }
            .onChange(of: text) { _, newValue in
                // Reset if text changes
                displayedText = ""
                startTyping()
            }
    }
    
    private func startTyping() {
        guard !isTyping else { return }
        isTyping = true
        displayedText = ""
        
        // Initial start delay
        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            var currentIndex = 0
            let chars = Array(text)
            
            Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { timer in
                if currentIndex < chars.count {
                    displayedText.append(chars[currentIndex])
                    currentIndex += 1
                } else {
                    timer.invalidate()
                    isTyping = false
                    onComplete?()
                }
            }
        }
    }
}

