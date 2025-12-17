import SwiftUI

enum EFVoiceState: Equatable {
    case idle
    case recording
    case transcribing
}

struct EFChatComposer: View {
    @Binding var text: String
    @Binding var voiceState: EFVoiceState
    var placeholder: String = "Message"
    var tint: Color = DesignSystem.Colors.accent
    var onSend: (() -> Void)? = nil
    var onStartRecording: (() -> Void)? = nil
    var onStopRecording: (() -> Void)? = nil
    var onTranscriptionReady: ((String) -> Void)? = nil
    var isFocused: FocusState<Bool>.Binding? = nil
    var isDisabled: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    init(
        text: Binding<String>,
        placeholder: String = "Message",
        tint: Color = DesignSystem.Colors.accent,
        voiceState: Binding<EFVoiceState> = .constant(.idle),
        onSend: (() -> Void)? = nil,
        onStartRecording: (() -> Void)? = nil,
        onStopRecording: (() -> Void)? = nil,
        onTranscriptionReady: ((String) -> Void)? = nil,
        isFocused: FocusState<Bool>.Binding? = nil,
        isDisabled: Bool = false
    ) {
        self._text = text
        self.placeholder = placeholder
        self.tint = tint
        self._voiceState = voiceState
        self.onSend = onSend
        self.onStartRecording = onStartRecording
        self.onStopRecording = onStopRecording
        self.onTranscriptionReady = onTranscriptionReady
        self.isFocused = isFocused
        self.isDisabled = isDisabled
    }

    private var placeholderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.55) : Color.black.opacity(0.60)
    }

    private var canSend: Bool {
        voiceState == .idle
            && !isDisabled
            && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            leftControl

            HStack(spacing: 10) {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(voiceState == .transcribing ? "Transcribing…" : placeholder)
                            .font(DesignSystem.Typography.bodyLarge())
                            .foregroundStyle(placeholderColor)
                    }
                    inputField
                }

                trailingControl
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 14)
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule(style: .continuous)
                            .fill(AppTheme.Colors.surface.opacity(colorScheme == .dark ? 0.70 : 0.86))
                    )
            }
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppTheme.Colors.separator.opacity(colorScheme == .dark ? 0.45 : 0.28), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.16 : 0.03),
                radius: 8,
                x: 0,
                y: 3
            )

            sendControl
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var inputField: some View {
        let field = TextField("", text: $text, axis: .vertical)
            .font(DesignSystem.Typography.bodyLarge())
            .foregroundStyle(AppTheme.Colors.textPrimary.opacity(isDisabled ? 0.6 : 1.0))
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(true)
            .submitLabel(.send)
            .lineLimit(1...4)
            .disabled(isDisabled || voiceState != .idle)
            .onSubmit {
                guard canSend else { return }
                onSend?()
            }

        if let isFocused {
            field.focused(isFocused)
        } else {
            field
        }
    }

    private var leftControl: some View {
        Button(action: handleLeftControlTap) {
            ZStack {
                if voiceState == .idle {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(tint)
                } else {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 40, height: 40)
            .background(voiceState == .idle ? AppTheme.Colors.surface : tint)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppTheme.Colors.separator.opacity(colorScheme == .dark ? 0.55 : 0.35), lineWidth: 1)
                    .opacity(voiceState == .idle ? 1 : 0)
            )
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.16 : 0.03),
                radius: 8,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || voiceState == .transcribing)
        .accessibilityLabel(voiceState == .idle ? "Attach" : "Stop")
    }

    @ViewBuilder
    private var trailingControl: some View {
        switch voiceState {
        case .idle:
            Button(action: handleMicTap) {
                Image(systemName: "mic.fill")
                    .foregroundStyle(tint.opacity(isDisabled ? 0.45 : 1.0))
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .accessibilityLabel("Start recording")

        case .recording:
            RecordingWaveform(tint: tint)
                .accessibilityLabel("Recording")

        case .transcribing:
            ActivityDots(color: AppTheme.Colors.textSecondary)
                .accessibilityLabel("Transcribing")
        }
    }

    private var sendControl: some View {
        Button(action: {
            guard canSend else { return }
            onSend?()
        }) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(
                    canSend
                        ? tint
                        : AppTheme.Colors.textSecondary.opacity(colorScheme == .dark ? 0.28 : 0.20)
                )
                .clipShape(Circle())
                .shadow(
                    color: tint.opacity(colorScheme == .dark ? 0.16 : 0.22),
                    radius: 8,
                    x: 0,
                    y: 3
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .accessibilityLabel("Send")
    }

    private func handleMicTap() {
        guard !isDisabled else { return }
        if let onStartRecording {
            onStartRecording()
            return
        }
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
            voiceState = (voiceState == .idle) ? .recording : .idle
        }
    }

    private func handleLeftControlTap() {
        guard !isDisabled else { return }
        if voiceState == .idle {
            return
        }
        if let onStopRecording {
            onStopRecording()
            return
        }
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
            voiceState = .idle
        }
    }
}

private struct RecordingWaveform: View {
    let tint: Color
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 2) {
                ForEach(0..<7, id: \.self) { i in
                    let phase = (t * 4.2) + (Double(i) * 0.65)
                    let level = 0.25 + 0.75 * (0.5 + 0.5 * sin(phase))
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(tint.opacity(colorScheme == .dark ? 0.85 : 0.95))
                        .frame(width: 3, height: 8 + (level * 16))
                }
            }
            .padding(.vertical, 2)
            .padding(.leading, 2)
        }
        .accessibilityHidden(true)
    }
}

private struct ActivityDots: View {
    let color: Color

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { i in
                    let phase = (t * 3.0) + (Double(i) * 0.85)
                    Circle()
                        .fill(color)
                        .frame(width: 4, height: 4)
                        .opacity(0.20 + 0.80 * (0.5 + 0.5 * sin(phase)))
                }
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    EFChatComposer(text: .constant(""))
        .background(DesignSystem.Colors.background)
}
