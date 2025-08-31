import SwiftUI

struct ChatListView: View {
    var messages: [ChatMessage]
    var isTyping: Bool = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageRow(
                            message: message,
                            onDelete: { },
                            onRegenerate: nil
                        )
                        .id(message.id)
                    }
                    
                    if isTyping {
                        HStack {
                            HStack(spacing: 4) {
                                ForEach(0..<3, id: \.self) { index in
                                    Circle()
                                        .fill(Color.secondary)
                                        .frame(width: 6, height: 6)
                                        .scaleEffect(isTyping ? 1.0 : 0.5)
                                        .animation(
                                            .easeInOut(duration: 0.6)
                                            .repeatForever()
                                            .delay(Double(index) * 0.2),
                                            value: isTyping
                                        )
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemGray6))
                            )
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
                .padding(.bottom, 140) // Space for chips + composer
            }
            .onChange(of: messages.count) { _, _ in
                if let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: messages.last?.text) { _, _ in
                if messages.last?.isStreaming == true, let lastMessage = messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}