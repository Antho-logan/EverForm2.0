import SwiftUI
import AVFoundation
import QuickLook

struct MessageRow: View {
    let message: ChatMessage
    let onDelete: () -> Void
    let onRegenerate: (() -> Void)?
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var showingQuickLook = false
    @State private var selectedImageData: Data?
    
    private var palette: Theme.Palette {
        Theme.palette(colorScheme)
    }
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
                messageContent
                    .contextMenu {
                        Button("Copy") {
                            UIPasteboard.general.string = message.text
                        }
                        
                        Button("Delete", role: .destructive) {
                            onDelete()
                        }
                        
                        if message.role == .assistant, let onRegenerate = onRegenerate {
                            Button("Regenerate") {
                                onRegenerate()
                            }
                        }
                    }
                
                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(palette.textSecondary)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.78, alignment: message.role == .user ? .trailing : .leading)
            
            if message.role == .assistant {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .sheet(isPresented: $showingQuickLook) {
            if let imageData = selectedImageData {
                QuickLookView(imageData: imageData)
            }
        }
    }
    
    @ViewBuilder
    private var messageContent: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
            // Images
            if !message.images.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 4) {
                    ForEach(message.images) { imageAsset in
                        if let uiImage = UIImage(data: imageAsset.data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    selectedImageData = imageAsset.data
                                    showingQuickLook = true
                                }
                        }
                    }
                }
                .padding(.bottom, 4)
            }
            
            // Audio
            if let audioURL = message.audioURL {
                AudioBubble(audioURL: audioURL, isPlaying: $isPlaying, audioPlayer: $audioPlayer)
                    .padding(.bottom, 4)
            }
            
            // Text
            if !message.text.isEmpty {
                HStack {
                    Text(message.text)
                        .font(.body)
                        .foregroundStyle(message.role == .user ? Color.white : palette.textPrimary)
                        .textSelection(.enabled)
                    
                    if message.isStreaming {
                        TypingIndicator()
                    }
                }
            } else if message.isStreaming {
                TypingIndicator()
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(message.role == .user ? palette.accent : palette.surfaceElevated)
                .overlay(
                    message.role == .assistant ?
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                    : nil
                )
                .shadow(
                    color: message.role == .assistant ? Color.black.opacity(0.08) : Color.clear,
                    radius: 2,
                    x: 0,
                    y: 1
                )
        )
    }
}

struct AudioBubble: View {
    let audioURL: URL
    @Binding var isPlaying: Bool
    @Binding var audioPlayer: AVAudioPlayer?
    
    @State private var duration: TimeInterval = 0
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Audio Message")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(formatTime(isPlaying ? currentTime : duration))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .onAppear {
            setupAudioPlayer()
        }
    }
    
    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            duration = audioPlayer?.duration ?? 0
        } catch {
            print("Failed to create audio player: \(error)")
        }
    }
    
    private func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
            timer?.invalidate()
            timer = nil
        } else {
            player.play()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                currentTime = player.currentTime
                if !player.isPlaying {
                    isPlaying = false
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
        
        isPlaying.toggle()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                    .opacity(animationPhase == index ? 1.0 : 0.5)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: false)) {
                animationPhase = 2
            }
        }
    }
}

struct QuickLookView: UIViewControllerRepresentable {
    let imageData: Data
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(imageData: imageData)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let imageData: Data
        
        init(imageData: Data) {
            self.imageData = imageData
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("preview_image.jpg")
            try? imageData.write(to: tempURL)
            return tempURL as QLPreviewItem
        }
    }
}
