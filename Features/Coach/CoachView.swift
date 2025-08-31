//
//  CoachView.swift
//  EverForm
//
//  Modern OpenAI-style chat interface with suggestions and input bar
//

import SwiftUI

struct CoachView: View {
    @State private var messages: [ChatMessage] = [
        ChatMessage(role: .assistant, text: "Hi! I'm your EverForm coach. How can I help you today?")
    ]
    @State private var inputText = ""
    @State private var isRecording = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let suggestions = [
        "Summarize my day",
        "Explain training",
        "Adjust macros",
        "Sleep tips",
        "Recovery advice"
    ]
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
                .background(palette.background)
                .onTapGesture {
                    hideKeyboard()
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Suggestions chips (above input bar)
            if !suggestions.isEmpty {
                SuggestionsChipsView(
                    suggestions: suggestions,
                    onSuggestionTapped: { suggestion in
                        inputText = suggestion
                    }
                )
            }
            
            // Input bar
            ChatInputBar(
                text: $inputText,
                onAttach: handleAttach,
                onMicToggle: handleMicToggle,
                onSend: handleSend
            )
        }
        .navigationTitle("Coach")
        .navigationBarTitleDisplayMode(.inline)
        .background(palette.background)
    }
    
    private func handleAttach() {
        // Stub for document picker
        print("Attach document - not implemented")
    }
    
    private func handleMicToggle(isRecording: Bool) {
        self.isRecording = isRecording
        // Stub for voice recording
        print("Mic toggle: \(isRecording)")
    }
    
    private func handleSend(_ text: String) {
        // Add user message
        let userMessage = ChatMessage(role: .user, text: text)
        messages.append(userMessage)

        // Simulate assistant response after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let assistantMessage = ChatMessage(role: .assistant, text: generateResponse(for: text))
            withAnimation(.easeInOut(duration: 0.3)) {
                messages.append(assistantMessage)
            }
        }
    }
    
    private func generateResponse(for input: String) -> String {
        // Simple response generation for demo
        switch input.lowercased() {
        case let text where text.contains("day"):
            return "Based on your data today, you've made great progress! You've completed 8.4K steps and logged 1.9K calories. Consider adding some hydration and getting quality sleep tonight."
        case let text where text.contains("training"):
            return "Your training plan focuses on progressive overload and balanced muscle development. Today's Upper Power session targets your chest, shoulders, and back with compound movements."
        case let text where text.contains("macro"):
            return "Your current macro targets are 2400 calories with 150g protein, 300g carbs, and 80g fats. This supports your training goals while maintaining energy balance."
        default:
            return "I understand you're asking about \"\(input)\". Let me help you with that based on your current health data and goals."
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ChatMessage
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        HStack {
            if message.role == .user {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(message.role == .user ? .white : palette.textPrimary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(
                        message.role == .user ?
                        palette.accent :
                        palette.surfaceElevated
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: Theme.Radius.card)
                    )

                Text(formatTimestamp(message.createdAt))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(palette.textSecondary)
                    .padding(.horizontal, Theme.Spacing.xs)
            }
            
            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Suggestions Chips

private struct SuggestionsChipsView: View {
    let suggestions: [String]
    let onSuggestionTapped: (String) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.xs) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        onSuggestionTapped(suggestion)
                    }) {
                        Text(suggestion)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(palette.textPrimary)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(palette.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Radius.pill)
                                    .stroke(palette.stroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
        .padding(.vertical, Theme.Spacing.xs)
        .background(palette.background.opacity(0.8))
    }
}

// MARK: - Chat Message Model
// Using existing ChatMessage from ChatTypes.swift

#Preview {
    NavigationView {
        CoachView()
    }
}
