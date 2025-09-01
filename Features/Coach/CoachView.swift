//
//  CoachView.swift
//  EverForm
//
//  Modern OpenAI-style chat interface with suggestions and input bar
//

import SwiftUI

struct CoachView: View {
    @State private var messages: [Message] = [
        .init(id: UUID(), isUser: false, text: "Hi! I'm your EverForm coach. How can I help you today?")
    ]
    @State private var draft: String = ""
    @State private var showRecording: Bool = false

    struct Message: Identifiable, Equatable {
        var id: UUID
        var isUser: Bool
        var text: String
    }

    @Environment(\.colorScheme) private var colorScheme
    
    private let suggestions = [
        "Summarize my day",
        "Explain training",
        "Adjust macros",
        "Sleep tips",
        "Recovery advice"
    ]
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    CenteredContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Coach")
                                .font(.largeTitle.weight(.bold))
                                .padding(.top, 6)

                            ForEach(messages) { msg in
                                HStack {
                                    if msg.isUser { Spacer(minLength: 40) }
                                    Text(msg.text)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(msg.isUser ? Color.accentColor.opacity(0.2) : Color(uiColor: .secondarySystemBackground))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.06), lineWidth: 1)
                                        )
                                        .frame(maxWidth: 320, alignment: msg.isUser ? .trailing : .leading)
                                    if !msg.isUser { Spacer(minLength: 40) }
                                }
                                .id(msg.id)
                            }
                            Color.clear.frame(height: 100)
                        }
                        .padding(.vertical, 10)
                    }
                }
                .onChange(of: messages) { _ in
                    if let last = messages.last {
                        withAnimation(.snappy) { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) { Composer() }
    }

    @ViewBuilder
    private func Composer() -> some View {
        VStack(spacing: 10) {
            // Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(suggestions, id: \.self) { s in
                        Button(s) { draft = s }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal, 24)
            }

            // Input bar
            HStack(spacing: 10) {
                Button { /* placeholder for file picker */ } label: {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                }

                TextField("Message", text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)

                Button {
                    showRecording.toggle()
                } label: {
                    Image(systemName: showRecording ? "waveform.circle.fill" : "mic.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(10)
                }
                .contentTransition(.symbolEffect)
                .animation(.snappy, value: showRecording)

                Button {
                    guard !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    messages.append(.init(id: UUID(), isUser: true, text: draft))
                    draft = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .padding(.leading, 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.horizontal, 24)
            .padding(.bottom, 10)
        }
        .background(.clear)
    }
}

#Preview {
    NavigationView {
        CoachView()
    }
}
